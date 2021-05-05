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
        help = "Size of instances of batch"
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
    cd(instanceSize)
    for instance in 1:batchSize
        generate(N, instance, false)
    end
    printstyled(stdout, "Files written\n", color=:green)
    paths = readdir(pwd())
    println(paths)



end

mainPia()