using Random, Distances, LinearAlgebra, DelimitedFiles, ArgParse

"""
    generate(numLocations)
Genera una instancia del QAP tomando como parámetro `numLocations` para establecer el tamaño

Primero crea una matriz de coordenadas entre las localizaciones

Posteriormente calcula la matriz de distancias con la distancia euclidiana entre cada localizacion

Crea también una matriz de flujo aleatoria entre estas localizaciones

Guarda ambas matrices en un .dat para su posterior lectura
"""
function generate(numLocations, instance, verbose)
    minimal = rand(1:20) # numero aleatorio del rango del 1 al 20
    maximal = rand(80:100) # del 80 al 100
    coords = rand(minimal:maximal, (numLocations, 2)) # primer valor representa x, segundo valor representa y
    # cada fila representa una ciudad
    euclides = Euclidean() # necesitamos calcular distancias Euclidianas
    distances = pairwise(euclides, coords, dims=1) # el dims=1 es para especificar que vamos por las FILAS
    distances = trunc.(Int, distances) # las pasamos a enteros, el . es que se broadcastea a toda la matriz
    flow = rand(minimal:maximal, (numLocations, numLocations)) # genera una matriz de randoms del rango de n×n filas
    flow[diagind(flow)] .= 0 # convierte los índices de la diagonal principal de flujos en 0s
    flow = Symmetric(flow) # agarra la parte superior y la aplica a la parte inferior de la matriz, volviendola simetrica
    if verbose
        print("Coordinates: ")
        show(stdout, "text/plain", coords)
        println()
        print("Distance matrix: ")
        show(stdout, "text/plain", distances)
        println()
        print("Flow matrix: ")
        show(stdout, "text/plain", flow)
    end
    name = "file" * string(instance, base=10) # nombre de archivo de instancia actual
    # EN JULIA EL OPERADOR * ES PARA CONCATENAR STRINGS
    x = coords[:,1] # agarra todas las filas de la primera columna 
    y = coords[:,2] # agarra todas las filas de la segunda columna
    name = name * ".dat"
    firstLine = string(numLocations, base=10) * "\n"
    open(name, "w") do io
        write(io, firstLine)
        writedlm(io, [distances], ' ')
        writedlm(io, [flow], ' ')
    end # escribimos al archivo nuestro numero de localizaciones, matrices de distancia y flujo
    println()
end

function parse_commandline()
    settings = ArgParseSettings()
    @add_arg_table! settings begin
    "nLocations"
        help = "Number of locations of the instance"
        required = true
        arg_type = Int
        default = 0
    "nInstances"
        help = "Number of instances"
        required = true
        arg_type = Int
        default = 0
    "--verbose", "-v"
        help = "Specify verbose output"
        action = :store_true    
    end 
    return parse_args(settings)
end

function main()
    parsed_args = parse_commandline()
    numLocations = get(parsed_args, "nLocations", 0)
    numInstances = get(parsed_args, "nInstances", 0)
    verbose = get(parsed_args, "verbose", false)
    if numLocations <= 0 || numInstances <= 0
        @error "You must enter a number larger than 0"
        return
    end
    try
        dir_path = string(numLocations, base=10) # creamos el nombre del directorio en el que se guardaran las instancias
        if !isdir(dir_path) # si el dir no existe
            mkdir(dir_path) # hazlo
        end
        cd(dir_path) # cd al dir 
        for instance in 1:numInstances
            generate(numLocations, instance, verbose)
        end
        printstyled(stdout, "Files written\n", color=:green)
    catch
        @error "Invalid input"
    end
end

main()