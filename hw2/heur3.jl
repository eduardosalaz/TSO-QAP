using DelimitedFiles

function main()
    file_name = ARGS[1]
    try
        input_array = readdlm(file_name, ' ', Int, '\n') # reads a 2d array from file
    catch
        @error "Input file does not exist"
        return
    end # try
    input_array = readdlm(file_name, ' ', Int, '\n')
    n = input_array[1, 1]
    W = input_array[1, 2]
    values = input_array[2:end, 1]
    weights = input_array[2:end, 2]
    input_array = nothing
    ratio = values./weights # gets ratio of vᵢ/wᵢ
    M = hcat(values, weights, ratio) # concatenates Three Vectors on a 2D Array
    Φ = sortslices(M,dims=1,by=x->(x[3],x[1],x[2]),rev=true)
    # sort first by col3, the others aren't relevant
    # biggest ratios go on top
    M = nothing
    Φ = Φ[:]
    len = length(Φ)
    len = floor(Int64, len/3) # get the 1/3rd point
    V̄ = Φ[1:len]
    # obviously the first third of the 1d array represents the values
    Weights = Φ[len+1:2*len] # second third is weights
    Φ = nothing
    V̄ = round.(Int, V̄) # faster while working with integers
    Weights = round.(Int, Weights)
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
