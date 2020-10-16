atreplinit() do repl
    try
        @eval begin
            using OhMyREPL: OhMyREPL, Crayon
            using OhMyREPL.Passes: SyntaxHighlighter
            OhMyREPL.enable_pass!("RainbowBrackets", false)
            let cs = SyntaxHighlighter.ColorScheme()
                SyntaxHighlighter.symbol!(cs, Crayon(; foreground=0xc7c795))
                SyntaxHighlighter.comment!(cs, Crayon(; foreground=0x747c84))
                SyntaxHighlighter.string!(cs, Crayon(; foreground=0x95c7ae))
                SyntaxHighlighter.string!(cs, Crayon(; foreground=0x95c7ae))
                SyntaxHighlighter.call!(cs, Crayon(; foreground=0xdfe2e5))
                SyntaxHighlighter.op!(cs, Crayon(; foreground=0xdfe2e5))
                SyntaxHighlighter.keyword!(cs, Crayon(; foreground=0xc795ae))
                SyntaxHighlighter.function_def!(cs, Crayon(; foreground=0xae95c7))
                SyntaxHighlighter.argdef!(cs, Crayon(; foreground=0xaec795))
                SyntaxHighlighter.macro!(cs, Crayon(; foreground=0xae95c7))
                SyntaxHighlighter.number!(cs, Crayon(; foreground=0xdfe2e5))
                SyntaxHighlighter.text!(cs, Crayon(; foreground=0xdfe2e5))
                SyntaxHighlighter.add!("base16-ashes", cs)
                OhMyREPL.colorscheme!("base16-ashes")
            end
            @async begin
                # OhMyREPL.jl#166
                sleep(1)
                OhMyREPL.Prompt.insert_keybindings()
            end
        end
    catch err
        @warn "Couldn't start OhMyREPL" ex=(err, catch_backtrace())
    end

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

const DEFAULT_PACKAGES = [:BenchmarkTools, :Debugger, :OhMyREPL, :Revise]

sysimage(packages=DEFAULT_PACKAGES) = @eval begin
    using PackageCompiler: create_sysimage
    kwargs = Dict{Symbol, Any}(:replace_default => true)
    file = joinpath(ENV["JULIA_DEPOT_PATH"], "config", "precompile.jl")
    if isfile(file)
        kwargs[:precompile_statements_file] = file
        @info "Using existing precompile file"
    else
        @warn "No precompile file found, consider generating one"
    end
    create_sysimage($(QuoteNode(packages)); kwargs...)
end

template() = @eval begin
    using PkgTemplates
    PkgTemplates.badges(::Documenter{GitHubActions}) = [PkgTemplates.Badge(
        "Docs",
        "https://img.shields.io/badge/docs-stable-blue.svg",
        "https://docs.cdg.dev/{{{PKG}}}.jl",
    )]
    PkgTemplates.user_view(::GitHubActions, ::Template, ::AbstractString) =
        Dict("VERSIONS" => ["1.0", "1", "nightly"])
    Template(; plugins=[
        Documenter{GitHubActions}(; canonical_url=(t, pkg) -> "https://docs.cdg.dev/$pkg.jl"),
        Git(; gpgsign=true, ssh=true),
        GitHubActions(; osx=false, windows=false),
    ])
end

end

using .Locals
