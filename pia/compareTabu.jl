using ArgParse, DataFrames, StatsPlots, CSV
gr() # para inicializar el backend de los plots

include("helperGenerator.jl") # incluye los archivos que tienen las funciones que ocupamos
include("helperLocalSearch.jl")
include("helperConstructive.jl")
include("helperTabuSearch.jl")
include("helperRobustTabu.jl")

function parse_commandlinePia() # lee los argumentos del programa y los procesa
    settings = ArgParseSettings()
    @add_arg_table! settings begin
    "batchSize"
        help = "Number of instances in batch"
        required = true
        arg_type = Int
    "instanceSize"
        help = "Size of instances of batch: S, M or L"
        required = true
        arg_type = String
    end 
    return parse_args(settings)
end

function mkDir(path::String)
    if !isdir(path)
        mkdir(path)
    end
end

function mainPiaComp()
    arreglo1 = []
    arreglo2 = []
    arreglo3 = []
    parsed_args = parse_commandlinePia()
    batchSize = get(parsed_args, "batchSize", 20) # 20 es el tamaño default
    instanceSize = get(parsed_args, "instanceSize", "S") # S es el tamaño de la instancia default
    N = 0
    if instanceSize == "S"
        N = 20
    elseif instanceSize == "M"
        N = 40
    elseif instanceSize == "L"
        N = 70
    else
        @error "You must enter a S(mall), M(edium) or L(arge) Batch Size"
        exit(0)
    end

    #mkDir(instanceSize)

    pathSolsCon = instanceSize * "_con"
    mkDir(pathSolsCon)

    pathSolsLS = instanceSize * "_ls"
    mkDir(pathSolsLS)

    pathSolsTS100 = instanceSize * "_100RTS"
    mkDir(pathSolsTS100)

    pathSolsTS500 = instanceSize * "_500RTS"
    mkDir(pathSolsTS500)
    
    cd(instanceSize)
    #for instance in 1:batchSize
    #    generate(N, instance, false)
    #end
    printstyled(stdout, "Files written\n", color=:green)
    
    # esta es la parte de la heurística constructiva
    paths = readdir(pwd())
    println("------------CONSTRUCTIVE HEURISTIC------------")
    for path in paths
        matchedNumber = match(r"\d{1,3}", path) # regex para obtener el número del archivo actual
        number = matchedNumber.match
        number = parse(Int, number) # lo pasamos a entero
        Σ, X, locations, Δt, costM =  parseFile(path, false, 1) # llamar parsefile de constructive, obtenemos los resultados de la heurística
        results = Dict("FileNumber" => number, "ValueC" => trunc(Int, Σ), "ΔtC" => Δt) # diccionario para asociar el número del archivo actual con su resultado
        push!(arreglo1, results) # empujamos ese diccionario a arreglo 1 
        slicedPath = replace(path, ".dat" => "")
        if Sys.isunix()
            fullPath = "../" * pathSolsCon * "/" * slicedPath * "_con"  * ".dat"
        else
            fullPath = "..\\" * pathSolsCon * "\\" * slicedPath * "_con"  * ".dat"
        end
        saveToFileConstructive(Σ, X, locations, Δt, costM, fullPath)
    end

    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end    
    println("------------ROBUST TABU SEARCH HEURISTIC WITH 100------------")
    cd(pathSolsCon)
    paths = readdir(pwd())
    for path in paths
        matchedNumber = match(r"\d{1,3}", path)
        number = matchedNumber.match
        number = parse(Int, number)
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFileRTS(path, false, N, false, 100) # llamar parsefile de tabuSearch
        results = Dict("FileNumber" => number, "ValueRTS100" => trunc(Int, Σ₁), "AbsImprovRTS100" => improvement, "ΔtRTS100" =>Δt₁)
        push!(arreglo2, results)
        slicedPath = replace(path, ".dat" => "")
        slicedPath = replace(slicedPath, "con" => "ts")
        if Sys.isunix()
            fullPath = "../" * pathSolsTS100 * "/" * slicedPath * ".dat"
        else
            fullPath = "..\\" * pathSolsTS100 * "\\" * slicedPath * ".dat"
        end
        saveToFileTS(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
    end
    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end

    println("------------ROBUST TABU SEARCH HEURISTIC WITH 500------------")
    cd(pathSolsCon)
    paths = readdir(pwd())
    for path in paths
        matchedNumber = match(r"\d{1,3}", path)
        number = matchedNumber.match
        number = parse(Int, number)
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFileRTS(path, false, N, false, 500) # llamar parsefile de tabuSearch
        results = Dict("FileNumber" => number, "ValueRTS500" => trunc(Int, Σ₁), "AbsImprovRTS500" => improvement, "ΔtRTS500" =>Δt₁)
        push!(arreglo3, results)
        slicedPath = replace(path, ".dat" => "")
        slicedPath = replace(slicedPath, "con" => "ts")
        if Sys.isunix()
            fullPath = "../" * pathSolsTS500 * "/" * slicedPath * ".dat"
        else
            fullPath = "..\\" * pathSolsTS500 * "\\" * slicedPath * ".dat"
        end
        saveToFileTS(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
    end
    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end

    plotsPath = instanceSize * "_RobustTabu"

    mkDir(plotsPath)
    cd(plotsPath)
    
    df1 = vcat(DataFrame.(arreglo1)...)
    df2 = vcat(DataFrame.(arreglo2)...)
    df3 = vcat(DataFrame.(arreglo3)...)

    df = innerjoin(df1, df2, df3, on =:FileNumber)
    sort!(df, [:FileNumber])
    df = df[!, [:FileNumber, :ValueC, :ValueRTS100, :AbsImprovRTS100, :ΔtRTS100, :ValueRTS500, :AbsImprovRTS500, :ΔtRTS500]]
    relativeRTS100 = (df[!, 4] ./ df[!, 2]) .* 100
    df[!, :RelImprovRTS100] = relativeRTS100
    relativeRTS500 = (df[!, 7] ./ df[!, 2]) .* 100
    df[!, :RelImprovRTS500] = relativeRTS500
    df = df[!, [:FileNumber, :ValueC, :ValueRTS100, :AbsImprovRTS100, :RelImprovRTS100, :ΔtRTS100, :ValueRTS500, :AbsImprovRTS500, :RelImprovRTS500, :ΔtRTS500]]

    println(df)

    titleString = "100 vs 500 iters Robust Tabu Comparison of absolute values of batch size " *  instanceSize
    @df df plot(:FileNumber, [:ValueRTS100], line = (:dot, 2), title = titleString, legend = :best,
    xlabel = "Number of instance", ylabel = "Objective function value", label = "Robust Tabu 100", 
    size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(1, :gray)))
    @df df plot!(:FileNumber, [:ValueRTS500], line = (:dot, 2), title = titleString, legend = :best,
    xlabel = "Number of instance", ylabel = "Objective function value", label = "Robust Tabu 500", 
    size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(1, :gray)))
    pathAbsolute = "absoluteValuesRTScomp" * instanceSize * ".pdf"
    savefig(pathAbsolute)

    titleString = "100 vs 500 iters Robust Tabu Relative value improvement of batch size " *  instanceSize
    @df df plot(:FileNumber, [:RelImprovRTS100], line = (:dot, 2), title = titleString, legend = :best,
                xlabel = "Number of instance", ylabel = "Percentage of improvement", label = "Robust Tabu 100",
                size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    @df df plot!(:FileNumber, [:RelImprovRTS500], line = (:dash, 2), title = titleString, legend = :best,
                xlabel = "Number of instance", ylabel = "Percentage of improvement", label= "Robust Tabu 500",
                size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    pathRelativeTS = "relativeValuesRTScomp" * instanceSize * ".pdf"
    savefig(pathRelativeTS)

    dfFixedTimes = filter(row -> !(row.FileNumber == 10), df)

    titleString = "100 vs 500 iters Robust Tabu Comparison of run time of batch size " *  instanceSize
    @df dfFixedTimes plot(:FileNumber, [:ΔtRTS100], line = (:dot, 2), title = titleString, legend = :best,
    xlabel = "Number of instance", ylabel = "Microseconds", label = "Robust Tabu 100", 
    size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    @df dfFixedTimes plot!(:FileNumber, [:ΔtRTS500], line = (:dash, 2), title = titleString, legend = :best,
    xlabel = "Number of instance", ylabel = "Microseconds", label = "Robust Tabu 500", 
    size = (900,1050), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    pathTimeTS = "timesRTScomp" * instanceSize * ".pdf"
    savefig(pathTimeTS)
    CSV.write("resultsR.csv", df)
end
mainPiaComp()