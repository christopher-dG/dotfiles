atreplinit() do repl
    try
        @eval using Revise: Revise
        @async Revise.wait_steal_repl_backend()
    catch err
        @warn "Couldn't start Revise" ex=(err, catch_backtrace())
    end
end

module Locals

export @ex, @exs

"Parse and return the given expression."
macro ex(ex)
    QuoteNode(ex)
end

"Parse and return the given expressions."
macro exs(exs...)
    exs
end

sysimage(packages=:Revise) = @eval begin
    using PackageCompiler: create_sysimage
    create_sysimage($(QuoteNode(packages)); replace_default=true)
end

template() = @eval begin
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

using .Locals
