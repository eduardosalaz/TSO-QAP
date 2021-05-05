using ArgParse, DelimitedFiles, Dates

function decisionMatrix(locations)
    X = zeros(Int8, (length(locations), length(locations)))
    for i in 1:length(locations)
        numero = locations[i]
        x = i
        y = numero
        X[x,y] = 1
    end
    return X
end

function heuristic(costM, Σ₀, locations₀, X₀, verbose)
    bestLocations = []
    bestValues = []
    improvement = false
    for i in 1:length(locations₀)
        for j in 1:length(locations₀)
            if j ≠ i
                locations₁ = copy(locations₀)
                locations₁[i] = locations₀[j]
                locations₁[j] = locations₀[i]
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
                end
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
        heuristic(costM, bestValue, bestLocation, X, verbose)
    else
        println("No further improvement made")
        println("Final result: ")
        println(Σ₀, locations₀)
        return Σ₀, locations₀, X₀
    end
end

function parseFile(path, verbose)
    stream = open(path, "r")
    contents = read(stream, String) 
    Σ, locations, X, costM, Δt = split(contents, "\n")
    Σ₀ = parse(Int, Σ)
    valorInicial = copy(Σ₀)
    locations₀ = [parse(Int, location) for location in split(locations)]
    X = [parse(Int, x) for x in split(X)]
    X = reshape(X, (length(locations₀), length(locations₀)))
    X₀ = X
    costM = [trunc(Int, parse(Float32,cost)) for cost in split(costM)]
    costM = reshape(costM, (length(locations₀), length(locations₀)))
    Δt = split(Δt)[1]
    Δt₀ = Millisecond(Δt)
    start = now(UTC)
    Σ₁, locations₁, X₁ = heuristic(costM, Σ₀, locations₀, X₀, verbose)
    finish = now(UTC)
    Δt₁ = finish - start
    improvement = valorInicial - Σ₁
    return Σ₁, locations₁, X₁, Δt₁, improvement
end

function saveToFile(Σ, locations, X, Δt, improvement,name)
    Σ = trunc(Int, Σ)
    firstline = string(Σ, base=10) * "\n"
    improv = "Improvement: " * string(improvement, base=10) * "\n"
    open(name, "w") do io
        write(io, firstline)
        writedlm(io, [locations], ' ')
        writedlm(io, [X], ' ')
        write(io, improv)
        write(io, string(Δt))
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
    println("local")
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
    numeroSpliteado = split(numSolutions, 's')
    numero = numeroSpliteado[1]

    if !directory
        fileName = splittedPath[3]
    end

    if save
        pathSols2opt = numero * "_2opt"
        if !isdir(pathSols2opt)
            mkdir(pathSols2opt)
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
                    if Sys.isunix()
                        fullPath = "../" * pathSols2opt * "/" * slicedPath * "_2opt"  * ".dat"
                    else
                        fullPath = "..\\" * pathSols2opt * "\\" * slicedPath * "_2opt"  * ".dat"
                    end
                    saveToFile(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
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
                if Sys.isunix()
                    fullPath = pathSols2opt *  "\\" * slicedPath * "_sol"  * ".dat"
                else
                    fullPath = pathSols2opt *  "/" * slicedPath * "_2opt"  * ".dat"
                end
                saveToFile(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
            end
        catch
            @error "Invalid file name"
        end
    end
end