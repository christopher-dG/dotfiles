atreplinit() do repl
    try
        @eval using Revise: Revise
        @async Revise.wait_steal_repl_backend()
    catch
        @warn "Couldn't start Revise"
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

make_sysimage(packages=:Revise) = @eval begin
    using PackageCompiler: create_sysimage
    create_sysimage($packages; replace_default=true)
end

TEMPLATE() = @eval begin
    using PkgTemplates
    Template(
        dir="~/code",
        plugins=[
            Documenter{TravisCI}(),
            Git(; gpgsign=true, manifest=true, ssh=true),
            TravisCI(; osx=false, windows=false),
        ],
    )
end
