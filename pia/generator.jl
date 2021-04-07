using Random, Distances, LinearAlgebra, DelimitedFiles, Gadfly, Cairo

"""
    generate(numLocations)
Genera una instancia del QAP tomando como parámetro `numLocations` para establecer el tamaño

Primero crea una matriz de coordenadas entre las localizaciones

Posteriormente calcula la matriz de distancias con la distancia euclidiana entre cada localizacion

Crea también una matriz de flujo aleatoria entre estas localizaciones

Guarda ambas matrices en un .dat para su posterior lectura
"""
function generate(numLocations, instance)
    minimal = rand(1:20) # numero aleatorio del rango del 1 al 20
    maximal = rand(80:100) # del 80 al 100
    coords = rand(minimal:maximal, (numLocations, 2)) # primer valor representa x, segundo valor representa y
    # cada fila representa una ciudad
    print("Coordinates: ")
    show(stdout, "text/plain", coords)
    euclides = Euclidean() # necesitamos calcular distancias Euclidianas
    distances = pairwise(euclides, coords, dims=1) # el dims=1 es para especificar que vamos por las FILAS
    distances = trunc.(Int, distances) # las pasamos a enteros, el . es que se broadcastea a toda la matriz
    flow = rand(minimal:maximal, (numLocations, numLocations)) # genera una matriz de randoms del rango de n×n filas
    flow[diagind(flow)] .= 0 # convierte los índices de la diagonal principal de flujos en 0s
    flow = Symmetric(flow) # agarra la parte superior y la aplica a la parte inferior de la matriz, volviendola simetrica
    println()
    print("Distance matrix: ")
    show(stdout, "text/plain", distances)
    println()
    print("Flow matrix: ")
    show(stdout, "text/plain", flow)
    name = "file" * string(instance, base=10) # nombre de archivo de instancia actual
    # EN JULIA EL OPERADOR * ES PARA CONCATENAR STRINGS
    x = coords[:,1] # agarra todas las filas de la primera columna 
    y = coords[:,2] # agarra todas las filas de la segunda columna
    p = plot(x=x,y=y, Geom.point, Theme(panel_fill=colorant"white", default_color=colorant"orange"));
    push!(p, Guide.title("Locations"));
    name_plot = name * ".pdf" # en png se cambian los colores no se muy bien porque
    draw(PDF(name_plot, 5inch, 5inch), p) # se guarda el plot
    name = name * ".dat"
    firstLine = string(numLocations, base=10) * "\n"
    open(name, "w") do io
        write(io, firstLine)
        writedlm(io, [distances], ' ')
        writedlm(io, [flow], ' ')
    end # escribimos al archivo nuestro numero de localizaciones, matrices de distancia y flujo
    println()
    printstyled(stdout, "Files written\n", color=:green)
end

try
    numLocations = parse(Int64, ARGS[1]) #ARGS es el arreglo de argumentos del programa
    numInstances = parse(Int64, ARGS[2])
    dir_path = string(numLocations, base=10) #creamos el nombre del directorio en el que se guardaran las instancias
    if !isdir(dir_path) #if dir doesnt exist yet
        mkdir(dir_path)
    end
    cd(dir_path)
    for instance in 1:numInstances
        generate(numLocations, instance)
    end
catch
    @error "Invalid input"
end

