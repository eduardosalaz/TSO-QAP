using DelimitedFiles # readdlm

function main()
    file_name = ARGS[1] # Julia is a 1-index based language
    # file_name = "10\\KpInstance1.dat"
    input_array = readdlm(file_name, ' ', Int, '\n') # reads a 2d array from file
    n = input_array[1, 1] # self explanatory
    W = input_array[1, 2]
    values = input_array[2:end, 1] # generates a Vector from 2nd row to end
    # of only the first column
    weights = input_array[2:end, 2] # second column
    # The reason we work with vectors is because Julia does NOT allow to remove
    # elements from 2d arrays. There is a hack with slices but it is not
    # efficient
    input_array = nothing # cleans up memory
    M = hcat(values, weights) # concatenates both Vectors on a 2D Array
    both = sortslices(M,dims=1,by=x->(x[1],-x[2]),rev=true)
    # sort first by col1 then col2
    # this is done to tiebreak same values
    M = nothing
    both_flattened = both[:] # flattens the 2d array to a 1d
    both = nothing
    len = length(both_flattened)
    len = floor(Int64, len/2) # get the half point
    V̄ = both_flattened[1:len]
    # obviously the first half of the 1d array represents the values
    Weights = both_flattened[len+1:end] # second half is weights
    both_flattened = nothing
    global W̄ = W # so they can be used inside the while
    global X = 0
    while !isempty(V̄)
        Vᵢ = V̄[1]
        popfirst!(V̄) # the ! allows us to modify the array in place
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

@time main() # to benchmark performance
