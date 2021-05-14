using ArgParse, DataFrames, StatsPlots, CSV
gr() # para inicializar el backend de los plots

include("helperGenerator.jl") # incluye los archivos que tienen las funciones que ocupamos
include("helperLocalSearch.jl")
include("helperConstructive.jl")
include("helperTabooSearch.jl")

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

function mainPia()
    arreglo1 = []
    arreglo2 = []
    arreglo3 = []
    parsed_args = parse_commandlinePia()
    batchSize = get(parsed_args, "batchSize", 10) # 10 es el tamaño default
    instanceSize = get(parsed_args, "instanceSize", "S") # S es el tamaño de la instancia default
    N = 0
    if instanceSize == "S"
        N = 10
    elseif instanceSize == "M"
        N = 30
    elseif instanceSize == "L"
        N = 50
    else
        @error "You must enter a S(mall), M(edium) or L(arge) Batch Size"
        exit(0)
    end

    mkDir(instanceSize)

    pathSolsCon = instanceSize * "_con"
    mkDir(pathSolsCon)

    pathSolsLS = instanceSize * "_ls"
    mkDir(pathSolsLS)

    pathSolsTS = instanceSize * "_ts"
    mkDir(pathSolsTS)
    
    cd(instanceSize)
    for instance in 1:batchSize
        generate(N, instance, false)
    end
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
    println("------------LOCAL SEARCH HEURISTIC------------")
    cd(pathSolsCon)
    paths = readdir(pwd())
    for path in paths
        matchedNumber = match(r"\d{1,3}", path)
        number = matchedNumber.match
        number = parse(Int, number)
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFile(path, false) # llamar parsefile de localSearch
        results = Dict("FileNumber" => number, "ValueLS" => trunc(Int, Σ₁), "AbsImprovLS" => improvement, "ΔtLS" =>Δt₁)
        push!(arreglo2, results)
        slicedPath = replace(path, ".dat" => "")
        slicedPath = replace(slicedPath, "con" => "ls")
        if Sys.isunix()
            fullPath = "../" * pathSolsLS * "/" * slicedPath * ".dat"
        else
            fullPath = "..\\" * pathSolsLS * "\\" * slicedPath * ".dat"
        end
        saveToFileLocalSearch(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
    end
    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end
    println("------------TABOO SEARCH HEURISTIC------------")
    cd(pathSolsCon)
    paths = readdir(pwd())
    for path in paths
        matchedNumber = match(r"\d{1,3}", path)
        number = matchedNumber.match
        number = parse(Int, number)
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFileTS(path, false, N, false) # llamar parsefile de localSearch
        results = Dict("FileNumber" => number, "ValueTS" => trunc(Int, Σ₁), "AbsImprovTS" => improvement, "ΔtTS" =>Δt₁)
        push!(arreglo3, results)
        slicedPath = replace(path, ".dat" => "")
        slicedPath = replace(slicedPath, "con" => "ts")
        if Sys.isunix()
            fullPath = "../" * pathSolsLS * "/" * slicedPath * ".dat"
        else
            fullPath = "..\\" * pathSolsLS * "\\" * slicedPath * ".dat"
        end
        saveToFileTS(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
    end
    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end

    plotsPath = instanceSize * "_output"

    mkDir(plotsPath)
    cd(plotsPath)

    df1 = vcat(DataFrame.(arreglo1)...) # https://stackoverflow.com/questions/54168574/an-array-of-dictionaries-into-a-dataframe-at-one-go-in-julia
    df2 = vcat(DataFrame.(arreglo2)...)
    df3 = vcat(DataFrame.(arreglo3)...)

    df = innerjoin(df1, df2, df3, on =:FileNumber)
    sort!(df, [:FileNumber])
    df = df[!, [:FileNumber, :ValueC, :ΔtC, :ValueLS, :ΔtLS, :AbsImprovLS, :ValueTS, :ΔtTS, :AbsImprovTS]]
    relativeLS = (df[!, 6] ./ df[!, 2]) .* 100
    df[!, :RelImprovLS] = relativeLS
    relativeTS = (df[!, 9] ./ df[!, 2]) .* 100
    df[!, :RelImprovTS] = relativeTS
    df = df[!, [:FileNumber, :ValueC, :ΔtC, :ValueLS, :ΔtLS, :AbsImprovLS, :RelImprovLS, :ValueTS, :ΔtTS, :AbsImprovTS, :RelImprovTS]]

    println(df)
    titleString = "Comparison of absolute values of batch size " *  instanceSize
    @df df plot(:FileNumber, [:ValueC, :ValueLS, :ValueTS], line = (:solid, 2), title = titleString, legend = :best,
                xlabel = "Number of instance", ylabel = "Objective function value", labels = ["Constructive" "Local" "Taboo"], 
                size = (700,600), marker = ([:hex :d], 3, 0.8, Plots.stroke(1, :gray)))
    pathAbsolute = "absoluteValues" * instanceSize * ".pdf"
    savefig(pathAbsolute)

    titleString = "Relative value improvement of batch size " *  instanceSize
    @df df plot(:FileNumber, [:RelImprovLS, :RelImprovTS], line = (:solid, 2), title = titleString, legend = :best,
                xlabel = "Number of instance", ylabel = "Percentage of improvement", labels = ["Local" "Taboo"],
                size = (700,600), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    pathRelative = "relativeValues" * instanceSize * ".pdf"
    savefig(pathRelative)

    dfFixedTimes = filter(row -> !(row.FileNumber == 10), df)

    titleString = "Comparison of run time of batch size " *  instanceSize
    @df dfFixedTimes plot(:FileNumber, [:ΔtC, :ΔtLS, :ΔtTS], line = (:solid, 2), title = titleString, legend = :best,
                xlabel = "Number of instance", ylabel = "Microseconds", labels = ["Constructive" "Local" "Taboo"], 
                size = (700,600), marker = ([:hex :d], 3, 0.8, Plots.stroke(3, :gray)))
    pathTime = "times" * instanceSize * ".pdf"
    savefig(pathTime)

    CSV.write("results.csv", df)
end
mainPia()