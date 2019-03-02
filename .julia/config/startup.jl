if haskey(ENV, "JULIA_REVISE")
    atreplinit() do repl
        try
            @eval using Revise
            @async Revise.wait_steal_repl_backend()
        catch
        end
    end
end

"Generate a package."
macro generate(pkg::String, kwargs...)
    kwargs = Dict(ex.args[1] => eval(ex.args[2]) for ex in kwargs)

    quote
        # The reason that this is a macro is so that we can avoid load time at startup.
        import PkgTemplates

        # Merge any keyword arguments with the defaults.
        let t = PkgTemplates.Template(; merge(Dict(
            :dir => "~/code",
            :julia_version => v"1.0",
            :ssh => true,
            :manifest => true,
            :plugins => [
                PkgTemplates.TravisCI(joinpath(@__DIR__, "travis.yml")),
                PkgTemplates.GitHubPages(),
            ],
        ), $kwargs)...)
            PkgTemplates.generate($pkg, t)

            # Replace the README with "# $pkg <travis badge>".
            dir = joinpath(t.dir, $pkg)
            lines = readlines(joinpath(dir, "README.md"))
            write(joinpath(dir, "README.md"), lines[1], " ", lines[end], "\n")
            run(`git -C $dir commit --all --amend --no-edit`)
        end
    end
end

"Parse and return the given expression."
macro ex(ex)
    QuoteNode(ex)
end

"Parse and return the given expressions."
macro exs(exs...)
    exs
end
