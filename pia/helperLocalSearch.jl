using ArgParse, DelimitedFiles, Dates

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

function localSearch(costM::Matrix{Int64}, Σ₀::Int64, locations₀::Vector{Int64}, X₀::Matrix{Int64}, verbose::Bool, full::Bool)
    bestLocations = []
    bestValues = []
    improvement = false
    for i in 1:length(locations₀)
        for j in i+1:length(locations₀)
            locations₁ = copy(locations₀)
            locations₁[i] = locations₀[j]
            locations₁[j] = locations₀[i]
            fac1 = locations₁[i]
            fac2 = locations₁[j]
            X = decisionMatrix(locations₁)
            Σ₁ = 0
            indices = findall(x->x==1, X)
            for indice in indices
                Σ₁ += costM[indice]
            end
            if Σ₁ < Σ₀
                improvement = true
                push!(bestLocations, locations₁)
                push!(bestValues, Σ₁)
            else
                println("Swapped facilities $fac2 and $fac1")
                println("No improvement to current value")
            end
        end
    end

    if improvement
        locsVals = hcat(bestValues, bestLocations)
        bestOnes = sortslices(locsVals, dims = 1, by=x->(x[1], x[2]))
        bestOnes = bestOnes[:]
        mitad = floor(Int, (length(bestOnes)/2))
        values = bestOnes[1:mitad]
        locations = bestOnes[mitad+1:end]

        bestValue = values[1]
        bestLocation = locations[1]
        X = decisionMatrix(bestLocation)

        if verbose
            println(bestValue, bestLocation)
        end
        localSearch(costM, bestValue, bestLocation, X, verbose, true)
    else
        if full
            println("Final result: ")
            println(Σ₀, locations₀)
        end
        return Σ₀, locations₀, X₀
    end
end

function parseFile(path::String, verbose::Bool)
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
    println("Initial value: $Σ₀")
    println("Initial list of facilities: $locations₀")
    Σ₁, locations₁, X₁ = localSearch(costM, Σ₀, locations₀, X₀, verbose, true)
    finish = time_ns()
    Δt₁ = (finish - start) * 1e-3 # micro segundos
    improvement = valorInicial - Σ₁
    return Σ₁, locations₁, X₁, Δt₁, improvement
end

function saveToFileLocalSearch(Σ, locations, X, Δt, improvement,name)
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

function parse_commandline()
    settings = ArgParseSettings()
    @add_arg_table! settings begin
    "path"
        help = "Path to file or directory OF SOLUTIONS"
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

function mainLocalSearch()
    parsed_args = parse_commandline()
    directory = get(parsed_args, "dir", false)
    verbose = get(parsed_args, "verbose", false)
    save = get(parsed_args, "save", false)
    mainPath = get(parsed_args, "path", "")

    if Sys.isunix()
        splittedPath= split(mainPath, '/')
    else
        splittedPath= split(mainPath, '\\')
    end

    numSolutions = splittedPath[2]
    numeroSpliteado = split(numSolutions, 'c')
    numero = numeroSpliteado[1]
    if !directory
        fileName = splittedPath[3]
    end

    if save
        pathSolsLS = numero * "ls"
        if !isdir(pathSolsLS)
            mkdir(pathSolsLS)
        end
    end

    if directory
        try
            paths = readdir(mainPath)
            cd(mainPath)
            for path in paths
                Σ₁, locations₁, X₁, Δt₁, improvement = parseFile(path, verbose)
                if save
                    slicedPath = replace(path, ".dat" => "")
                    slicedPath = replace(slicedPath, "con" => "ls")
                    if Sys.isunix()
                        fullPath = "../" * pathSolsLS * "/" * slicedPath * ".dat"
                    else
                        fullPath = "..\\" * pathSolsLS * "\\" * slicedPath * ".dat"
                    end
                    saveToFileLocalSearch(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
                end
            end
        catch
            @error "Invalid path for directory"
        end
    else
        try
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFile(mainPath, verbose)
            if save
                slicedPath = replace(fileName, ".dat" => "")
                slicedPath = replace(slicedPath, "con" => "ls")
                if Sys.isunix()
                    fullPath = pathSolsLS *  "\\" * slicedPath * ".dat"
                else
                    fullPath = pathSolsLS *  "/" * slicedPath * ".dat"
                end
                saveToFileLocalSearch(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
            end
        catch
            @error "Invalid file name"
        end
    end
end