if haskey(ENV, "JULIA_REVISE")
    atreplinit() do repl
        try
            @eval using Revise
            @async Revise.wait_steal_repl_backend()
        catch
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
