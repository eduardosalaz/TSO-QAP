using DelimitedFiles

function main()
    file_name = ARGS[1]
    try
        input_array = readdlm(file_name, ' ', Int, '\n') # reads a 2d array from file
    catch
        @error "Input file does not exist"
        return
    end # try
    n = input_array[1, 1]
    W = input_array[1, 2]
    values = input_array[2:end, 1]
    weights = input_array[2:end, 2]
    input_array = nothing
    M = hcat(values, weights)
    Φ = sortslices(M,dims=1,by=x->(-x[2],x[1]),rev=true)
    # sort first by col2 then col1
    # this is done to tiebreak same weights
    M = nothing
    Φ = Φ[:]
    len = length(Φ)
    len = floor(Int64, len/2)
    V̄ = Φ[1:len]
    Weights = Φ[len+1:end]
    Φ = nothing
    global W̄ = W
    global X = 0
    while !isempty(V̄)
        Vᵢ = V̄[1]
        popfirst!(V̄)
        Wᵢ = Weights[1]
        popfirst!(Weights)
        if Wᵢ ≤ W̄
            global X += Vᵢ
            global W̄ =  W̄ - Wᵢ
        end # if
    end # while
    println("Knapsack value of: ", X)
    println("Residual Weight of: ", W̄)
    end # function

@time main()
