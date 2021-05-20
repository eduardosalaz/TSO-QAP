using ArgParse, DelimitedFiles, Plots
struct solucion
    locations::Vector{Int64}
    value::Int64
    interchange1::Int
    interchange2::Int
end

function decisionMatrix(locations::Vector{Int64})::Matrix{Int64}
    X = zeros(Int64, (length(locations), length(locations)))
    for i in 1:length(locations)
        numero = locations[i]
        x = i
        y = numero
        X[x,y] = 1
    end
    return X
end

function move(costM::Matrix{Int64}, locations₀::Vector{Int64}, i::Int64, j::Int64)
    locations₁ = copy(locations₀)
    locations₁[i] = locations₀[j]
    locations₁[j] = locations₀[i]
    X = decisionMatrix(locations₁)
    value = 0
    indices = findall(x->x==1, X)
    for indice in indices
        value += costM[indice]
    end
    return solucion(locations₁,value,locations₁[i], locations₁[j])
end

function selectLeastWorst(currentNeighbourhood::Vector{solucion}, tabuList::Vector{Int64})
    leastWorstCurrentMove = popfirst!(currentNeighbourhood)
    interLstWorstCurr1 = leastWorstCurrentMove.interchange1
    interLstWorstCurr2 = leastWorstCurrentMove.interchange2
    stuck = count(i->(i==0), tabuList)
    if stuck == 1 || stuck == 0
        return true, solucion([],99999999999,1,2)
    end
    if (tabuList[interLstWorstCurr1] ≠ 0 || tabuList[interLstWorstCurr2] ≠ 0)
        selectLeastWorst(currentNeighbourhood, tabuList)
    else
        return false, leastWorstCurrentMove
    end
end

function robustTabuSearch(costM::Matrix{Int64}, Σ₀::Int64, locations₀::Vector{Int64}, verbose::Bool, number::Int64, full::Bool, iters::Int64)
    valuesEvaluated = Int64[]
    bestValue = copy(Σ₀)
    push!(valuesEvaluated, bestValue)
    if full
        println("Start locations: ", locations₀)
        println("Current best value: ", bestValue)
    end
    bestLocations = copy(locations₀)
    currentLocations = copy(bestLocations)
    tabuList = zeros(Int64, number)
    sₘᵢₙ = floor(Int, (0.9 * number))
    sₘₐₓ = ceil(Int, (1.1 * number))
    randomPeriod = 2 * sₘₐₓ
    tabuTenure = rand(sₘᵢₙ:sₘₐₓ)
    itersTaken = 1
    for iteracion in 1:iters
        if iteracion % randomPeriod == 0
            tabuTenure = rand(sₘᵢₙ:sₘₐₓ)
        end
        currentNeighbourhood = solucion[]
        for i in 1:length(currentLocations)
            for j in i+1:length(currentLocations)
                movement = move(costM, currentLocations, i,j)
                push!(currentNeighbourhood, movement)
            end
        end
        sort!(currentNeighbourhood, by = move -> move.value)
        #println(currentNeighbourhood)
        scores = Int[]
        for neighbor in currentNeighbourhood
            valor = neighbor.value
            score = bestValue - valor
            push!(scores, score)
        end
        allNegatives = all(<=(0), scores)
        if allNegatives
            stuck, leastWorstCurrentMove = selectLeastWorst(currentNeighbourhood, tabuList)
            if stuck
                println("Tabu list is full, cant make any further move")
                break
            else
                currentLocations = leastWorstCurrentMove.locations
                currValue = leastWorstCurrentMove.value
                push!(valuesEvaluated, currValue)
                interLstWorstCurr1 = leastWorstCurrentMove.interchange1
                interLstWorstCurr2 = leastWorstCurrentMove.interchange2
                if verbose
                    println("Worse Iteration $iteracion, currentLocations: ", currentLocations)
                    println("Value: ", currValue)
                    println("Swapped $interLstWorstCurr1 and $interLstWorstCurr2")
                    println("----------------")
                end
                moveds = findall(x->x≠0, tabuList)
                for moved in moveds
                    tabuList[moved]= tabuList[moved] - 1
                end
                tabuList[interLstWorstCurr1] = tabuTenure
                tabuList[interLstWorstCurr2] = tabuTenure
                itersTaken += 1
            end
        else
            bestCurrentMove = popfirst!(currentNeighbourhood)
            if bestCurrentMove.locations == currentLocations
                bestCurrentMove = popfirst!(currentNeighbourhood)
            end
            interBestCurr1 = bestCurrentMove.interchange1
            interBestCurr2 = bestCurrentMove.interchange2
            if bestCurrentMove.value < bestValue && tabuList[interBestCurr1] == 0 && tabuList[interBestCurr2] == 0 # if best move matches acceptation and aspiration criteria
                bestValue = bestCurrentMove.value
                bestLocations = bestCurrentMove.locations
                currentLocations = copy(bestLocations)
                push!(valuesEvaluated, bestValue)
                if verbose
                    println("Iteration $iteracion, currentLocations: ", currentLocations)
                    println("Value: ", bestValue)
                    println("Swapped $interBestCurr1 and $interBestCurr2")
                    println("----------------")
                end
                moveds = findall(x->x≠0, tabuList)
                for moved in moveds
                    tabuList[moved]= tabuList[moved] - 1
                end
                tabuList[interBestCurr1] = tabuTenure
                tabuList[interBestCurr2] = tabuTenure
                itersTaken += 1
            elseif bestCurrentMove.value < bestValue &&(tabuList[interBestCurr1] ≠ 0 || tabuList[interBestCurr2] ≠ 0) # if best move matches aspiration criteria but not acceptation
                bestValue = bestCurrentMove.value
                bestLocations = bestCurrentMove.locations
                currentLocations = copy(bestLocations)
                if verbose
                    println("Iteration $iteracion, currentLocations: ", currentLocations)
                    println("Value: ", bestValue)
                    println("Swapped $interBestCurr1 and $interBestCurr2")
                    println("----------------")
                end
                push!(valuesEvaluated, bestValue)
                moveds = findall(x->x≠0, tabuList)
                for moved in moveds
                    tabuList[moved]= tabuList[moved] - 1
                end
                if tabuList[interBestCurr1] ≠ 0
                    tabuList[interBestCurr2] = tabuTenure
                else
                    tabuList[interBestCurr1] = tabuTenure
                end
                itersTaken += 1
            end
        end
    end
    X = decisionMatrix(bestLocations)
    if full
        Y = collect(1:itersTaken)
        plot(Y, valuesEvaluated, label = "Value of iteration", xlabel="# of iteration", ylabel="Objective function value", title="Tabu Search")
        path = string(number) * "values.pdf"
        savefig(path)
    end
    return bestValue, bestLocations, X

end

function parseFileRTS(path::String, verbose::Bool, numero::Int64, full::Bool, iters::Int64)
    stream = open(path, "r")
    contents = read(stream, String)
    close(stream)
    Σ, locations, X, costMStr, Δt = split(contents, "\n")
    Σ₀ = parse(Int, Σ)
    valorInicial = copy(Σ₀)
    locations₀ = [parse(Int, location) for location in split(locations)]
    Xmatrix = [parse(Int, x) for x in split(X)]
    Xmatrix = reshape(Xmatrix, (length(locations₀), length(locations₀)))
    X₀ = Xmatrix
    costM = [trunc(Int, parse(Float32,cost)) for cost in split(costMStr)]
    costM = reshape(costM, (length(locations₀), length(locations₀)))
    start = time_ns()
    Σ₁, locations₁, X₁ = robustTabuSearch(costM, Σ₀, locations₀, verbose, numero, full, iters)
    finish = time_ns()
    Δt₁ = (finish - start) * 1e-3 # micro segundos
    improvement = valorInicial - Σ₁
    println("New value: ", Σ₁)
    println("New locations: ", locations₁)
    println("Improvement: ", improvement)
    return Σ₁, locations₁, X₁, Δt₁, improvement
end

function parse_commandline()
    settings = ArgParseSettings()
    @add_arg_table! settings begin
    "path"
        help = "Path to file or directory OF SOLUTIONS"
        required = true
    "iters"
        help = "Number of iterations before stopping"
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

function saveToFileTS(Σ, locations, X, Δt, improvement, name)
    Σ = trunc(Int, Σ)
    time = string(Δt) * " microseconds"
    firstline = string(Σ, base=10) * "\n"
    improv = "Improvement: " * string(improvement, base=10) * "\n"
    open(name, "w") do io
        write(io, firstline)
        writedlm(io, [locations], ' ')
        writedlm(io, [X], ' ')
        write(io, improv)
        write(io, time)
    end
    printstyled(stdout, "Wrote to file\n", color=:green)
end

function mainTabu()
    parsed_args = parse_commandline()
    directory = get(parsed_args, "dir", false)
    verbose = get(parsed_args, "verbose", false)
    save = get(parsed_args, "save", false)
    mainPath = get(parsed_args, "path", "")
    iters = get(parsed_args, "iters", 100)

    if Sys.isunix()
        splittedPath= split(mainPath, '/')
    else
        splittedPath= split(mainPath, '\\')
    end
    numSolutions = splittedPath[2]
    numeroSpliteado = split(numSolutions, "_")
    numeroPerron = numeroSpliteado[1]
    numero = parse(Int64, numeroSpliteado[1])

    numIters = parse(Int64, iters)

    if !directory
        fileName = splittedPath[3]
    end

    if save
        pathSolsLS = numeroPerron * "_ts"
        if !isdir(pathSolsLS)
            mkdir(pathSolsLS)
        end
    end

    if directory
        #try
            paths = readdir(mainPath)
            cd(mainPath)
            for path in paths
                Σ₁, locations₁, X₁, Δt₁, improvement = parseFileTS(path, verbose, numero, true, numIters)
                if save
                    slicedPath = replace(path, ".dat" => "")
                    slicedPath = replace(slicedPath, "con" => "ts")
                    if Sys.isunix()
                        fullPath = "../" * pathSolsLS * "/" * slicedPath * ".dat"
                    else
                        fullPath = "..\\" * pathSolsLS * "\\" * slicedPath * ".dat"
                    end
                    saveToFileTS(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
                end
            end
        #catch
        #    @error "Invalid path for directory"
        #end
    else
        #try
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFileTS(mainPath, verbose, numero, true, numIters)
            if save
                slicedPath = replace(fileName, ".dat" => "")
                slicedPath = replace(slicedPath, "con" => "ts")
                if Sys.isunix()
                    fullPath = pathSolsLS *  "\\" * slicedPath * ".dat"
                else
                    fullPath = pathSolsLS *  "/" * slicedPath * ".dat"
                end
                saveToFileTS(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
            end
        #catch
            #@error "Invalid file name"
        #end
    end
end