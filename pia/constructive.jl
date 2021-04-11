using SparseArrays, DelimitedFiles, ArgParse, Dates

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

function heuristic(cost, X, iter, sum, verbose)
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

function parseFile(path, verbose)
    stream = open(path, "r")
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
    start = now(UTC)
    while iters < numLocations # paso 3
        costM, X, iters,Σ = heuristic(costM, X, iters, Σ, verbose)
    end
    finish = now(UTC)
    Δt = finish-start
    println(Δt)
    printstyled(stdout, "End of Heuristic\n", color=:green)
    println("Total cost: ", Σ)
    print("Decision matrix: ")
    show(stdout, "text/plain", X)
    coordenadas = findall(x->x!=0, X)
    locations = Int[]
    for coord in coordenadas
        x = coord[1]
        push!(locations, x)
    end
    println("\nList of facilities: ", locations)
    return Σ, X, locations, Δt
end

function parse_commandline()
    settings = ArgParseSettings()
    @add_arg_table! settings begin
    "path"
        help = "Path to file or directory"
        required = true
    "--dir", "-d"
        help = "Specify if a directory is to be read"
        action = :store_true
    "--verbose", "-v"
        help = "Specify verbose output"
        action = :store_true
    "--save", "-s"
        help = "Save solutions to files"
        action = :store_true
    
    end 
    return parse_args(settings)
end

function saveToFile(Σ, X, locations, Δt, name)
    firstline = "Cost: " * string(Σ, base=10) * "\n"
    open(name, "w") do io
        write(io, firstline)
        writedlm(io, [locations], ' ')
        writedlm(io, [X], ' ')
        write(io, string(Δt))
    end
    printstyled(stdout, "Wrote to file\n", color=:green)
end


function main()
    parsed_args = parse_commandline()
    directory = get(parsed_args, "dir", false)
    verbose = get(parsed_args, "verbose", false)
    save = get(parsed_args, "save", false)
    mainPath = get(parsed_args, "path", "")
    splittedPath= split(mainPath, '\\')
    number = splittedPath[2]
    
    if !directory
        fileName = splittedPath[3]
    end

    if save
        pathSols = number * "solutions"
        if !isdir(pathSols)
            mkdir(pathSols)
        end  
    end

    if directory
        try
            paths = readdir(mainPath)
            cd(mainPath)
            for path in paths
                Σ, X, locations, Δt =  parseFile(path, verbose)
                if save
                    slicedPath = replace(path, ".dat" => "")
                    fullPath = "..\\" *pathSols * "\\" * slicedPath * "_sol"  * ".dat"
                    saveToFile(Σ, X, locations, Δt, fullPath)
                end
            end
        catch
            @error "Invalid path for directory"
        end
    else
        try
            Σ, X, locations,  Δt = parseFile(mainPath, verbose)
            if save
                slicedPath = replace(fileName, ".dat" => "")
                fullPath = pathSols *  "\\" * slicedPath * "_sol"  * ".dat"
                saveToFile(Σ, X, locations, Δt, fullPath)
            end
        catch
            println(stacktrace())
        end
        
    end
end

main()