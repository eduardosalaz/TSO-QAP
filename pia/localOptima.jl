using Plots

X = 1:10
Y = Float64[]

for x ∈ X
    y = x * cos(3.1416 * x)
    push!(Y, y)
end

println(X)
println(Y)
plot(X, Y, xlabel = "X", ylabel = "Y", label = "Value of f(x)", )
title = "Stuff.pdf"
savefig(title)