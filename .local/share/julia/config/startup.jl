using Revise

macro ex(ex)
    QuoteNode(ex)
end

macro exs(exs...)
    exs
end
