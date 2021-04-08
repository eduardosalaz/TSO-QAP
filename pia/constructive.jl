using SparseArrays

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

function heuristic(cost, X, iter, sum)
    value, index = findmin(cost) # análogo al paso 4
    x = index[1] # paso 4
    y = index[2] # paso 4
    cost[:,y] .= 9999 # paso 5, no se eliminan como tal pero se dejan unfeasible
    cost[x,:] .= 9999 # paso 5
    X[x,y] = 1 # paso 6
    sum += value # paso 7
    printCost = sparse(cost) # todo esto es para imprimir la matriz de costos actualizada
    replace!(printCost, 9999=>0)
    dropzeros!(printCost)
    print("\nCheapest cost: ", value, " found at: ", x, ",", y)
    print("\nDecision matrix: ")
    show(stdout, "text/plain", X)
    println("\nUpdated cost matrix: ")
    show(stdout, "text/plain", printCost)
    println()
    iter += 1 # paso 8
    return cost,X,iter,sum # paso 9
end

try
    file = ARGS[1]
    stream = open(file, "r")
    contents = read(stream, String)
    numLocations, distString, flowString = split(contents, "\n") # cada salto de linea representa un valor nuevo
    numLocations = parse(Int, numLocations)
    distances = [parse(Int, distance) for distance in split(distString)] # pasamos el string que leimos a un arreglo 
    distanceM = reshape(distances, (numLocations, numLocations)) # al arreglo le damos la forma de la matriz tomando en cuenta numLocations 
    flows = [parse(Int, flow) for flow in split(flowString)]
    flowM = reshape(flows, (numLocations, numLocations))
    println("Number of Locations: " * string(numLocations, base=10))
    print("\nDistance matrix: ")
    show(stdout, "text/plain", distanceM)
    println()
    print("\nFlow matrix: ")
    show(stdout, "text/plain", flowM)
    println()
    × = * # mejor notación
    costM = distanceM × flowM # matriz de costos, paso 1
    iters = 0 # paso 1
    print("\nCost matrix: ")
    show(stdout, "text/plain", costM)
    println()
    X = zeros(Int8, numLocations, numLocations) # matriz de decisión, paso 2
    Σ = 0 # paso 2
    @time while iters < numLocations # paso 3
        costM, X, iters, Σ = heuristic(costM, X, iters, Σ)
    end
    printstyled(stdout, "End of Heuristic\n", color=:green)
    println("Total cost: ", Σ)
    print("Decision matrix: ")
    show(stdout, "text/plain", X)
catch
    @error "File is invalid"
end