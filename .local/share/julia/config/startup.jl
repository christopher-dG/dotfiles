if !haskey(ENV, "JULIA_NOREVISE")
    atreplinit() do repl
        try
            @eval using Revise
            @async Revise.wait_steal_repl_backend()
        catch
            @warn "Couldn't start Revise"
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

function TEMPLATE()
    @eval begin
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
end
