using SparseArrays, DelimitedFiles

# pseudocódigo del algoritmo
# 1.- Input: matriz de costos, número de iteración
# 2.- Output: matriz de decisión, Σ
# 3.- Mientras número de iteración < numero de localizaciones
#   4.- value, indices [x,y] <- argmin(costos)
#   5.- Eliminar a la fila x, columna y de la matriz
#   6.- Hacer a la matriz de decisión en [x,y] = 1
#   7.- Σ += value
#   8.- número de iteración += 1
# 9.- Return matriz de decisión, Σ

function heuristic(cost, X, iter, sum,verbose=false)
    value, index = findmin(cost) # análogo al paso 4
    x = index[1] # paso 4
    y = index[2] # paso 4
    cost[:,y] .= 9999999 # paso 5, no se eliminan como tal pero se dejan unfeasible
    cost[x,:] .= 9999999 # paso 5
    X[x,y] = 1 # paso 6
    sum += value # paso 7
    if verbose
        printCost = sparse(cost) # todo esto es para imprimir la matriz de costos actualizada
        replace!(printCost, 9999999=>0)
        dropzeros!(printCost)
        print("\nCheapest cost: ", value, " found at: ", x, ",", y)
        print("\nDecision matrix: ")
        show(stdout, "text/plain", X)
        println("\nUpdated cost matrix: ")
        show(stdout, "text/plain", printCost)
        println()
    end
    iter += 1 # paso 8
    return cost,X,iter,sum # paso 9
end

try
    file = ARGS[1]
    verbose = false
    saveTo = false
    argumentos = length(ARGS)
    if argumentos > 1
        verbose = true
    elseif argumentos > 2
        saveTo = true
    end
    
    stream = open(file, "r")
    contents = read(stream, String)
    numLocations, distString, flowString = split(contents, "\n") # cada salto de linea representa un valor nuevo
    numLocations = parse(Int, numLocations)
    distances = [parse(Int, distance) for distance in split(distString)] # pasamos el string que leimos a un arreglo 
    distanceM = reshape(distances, (numLocations, numLocations)) # al arreglo le damos la forma de la matriz tomando en cuenta numLocations 
    flows = [parse(Int, flow) for flow in split(flowString)]
    flowM = reshape(flows, (numLocations, numLocations))
    × = * # mejor notación
    costM = distanceM × flowM # matriz de costos, paso 1
    iters = 0 # paso 1
    if verbose
        println("Number of Locations: " * string(numLocations, base=10))
        print("\nDistance matrix: ")
        show(stdout, "text/plain", distanceM)
        println()
        print("\nFlow matrix: ")
        show(stdout, "text/plain", flowM)
        println()
    end
    print("\nCost matrix: ")
    show(stdout, "text/plain", costM)
    println()
    X = zeros(Int8, numLocations, numLocations) # matriz de decisión, paso 2
    Σ = 0 # paso 2
    @time while iters < numLocations # paso 3
        costM, X, iters,Σ = heuristic(costM, X, iters, Σ,verbose)
    end
    printstyled(stdout, "End of Heuristic\n", color=:green)
    println("Total cost: ", Σ)
    print("Decision matrix: ")
    show(stdout, "text/plain", X)
    coordenadas = findall(x->x!=0, X)
    localizaciones = Int[]
    for coord in coordenadas
        x = coord[1]
        push!(localizaciones, x)
    end
    println("\nList of facilities: ", localizaciones)
    if saveTo
        name = "solution_" * string(numLocations, base=10) * ".dat"
        firstline = "Cost: " * string(Σ, base=10) * "\n"
        open(name, "w") do io
            write(io, firstline)
            writedlm(io, [localizaciones], ' ')
            writedlm(io, [X], ' ')
        end
        printstyled(stdout, "Wrote to file\n", color=:green)
    end
catch
    @error "Invalid file or missing arguments"
end