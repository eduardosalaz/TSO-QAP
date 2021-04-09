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

matriz = [1 2 3; 5 4 7; 8 1 9]
nfil = trunc(Int, √length(matriz))
min_filas = Tuple[]
for fila in 1:nfil
    push!(min_filas, findmin(matriz[fila,:]))
end
min_filas
3-element Vector{Tuple}:
 (1, 1)
 (4, 2)
 (1, 2)

min_cols = Tuple[]
for col in 1:nfil
    push!(min_cols, findmin(matriz[:,col]))
end

min_cols
3-element Vector{Tuple}:
 (1, 1)
 (1, 3)
 (3, 1)

cols_deminfilas = (x->x[2]).(min_filas)
 3-element Vector{Int64}:
  1
  2
  2

filas_demincols = (x->x[2]).(min_cols)

coords_minfils = []

for fila in 1:length(cols_deminfilas)
    tup = (fila, cols_deminfilas[fila])
    push!(coords_minfils, tup)
end


end

try
    file = ARGS[1]
    verbose = parse(Int, ARGS[2])
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
    if verbose == 1
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
        costM, X, iters,Σ = heuristic(costM, X, iters, Σ)
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

catch
    @error "Invalid file or missing arguments"
end