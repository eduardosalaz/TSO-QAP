using ArgParse

include("helperGenerator.jl")
include("helperLocalSearch.jl")
include("helperConstructive.jl")

function parse_commandlinePia()
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

function mainPia()
    parsed_args = parse_commandlinePia()
    batchSize = get(parsed_args, "batchSize", 10)
    instanceSize = get(parsed_args, "instanceSize", "S")
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
    if !isdir(instanceSize)
        mkdir(instanceSize)
    end
    pathSols = instanceSize * "_sols"
    if !isdir(pathSols)
        mkdir(pathSols)
    end

    path2opt = instanceSize * "_2opt"
    if !isdir(path2opt)
        mkdir(path2opt)
    end
    
    cd(instanceSize)
    for instance in 1:batchSize
        generate(N, instance, false)
    end
    printstyled(stdout, "Files written\n", color=:green)
    paths = readdir(pwd())
    for path in paths
        Σ, X, locations, Δt, costM =  parseFile(path, false, 1)
        slicedPath = replace(path, ".dat" => "")
        if Sys.isunix()
            fullPath = "../" * pathSols * "/" * slicedPath * "_sol"  * ".dat"
        else
            fullPath = "..\\" * pathSols * "\\" * slicedPath * "_sol"  * ".dat"
        end
        saveToFileConstructive(Σ, X, locations, Δt, costM, fullPath)
    end
    if Sys.isunix()
        cd("../")
    else
        cd("..\\")
    end
    cd(pathSols)
    paths = readdir(pwd())
    for path in paths
        Σ₁, locations₁, X₁, Δt₁, improvement = parseFile(path, false)
        slicedPath = replace(path, ".dat" => "")
        if Sys.isunix()
            fullPath = "../" * path2opt * "/" * slicedPath * "_2opt"  * ".dat"
        else
            fullPath = "..\\" * path2opt * "\\" * slicedPath * "_2opt"  * ".dat"
        end
        saveToFileLocalSearch(Σ₁, locations₁, X₁, Δt₁, improvement, fullPath)
    end

end

mainPia()