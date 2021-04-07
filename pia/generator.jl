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
    minimo = rand(1:20)
    maximo = rand(80:100)
    coords = rand(minimo:maximo, (numLocations, 2)) # primer valor representa x, segundo valor representa y
    # cada fila representa una ciudad
    print("Coordinates: ")
    show(stdout, "text/plain", coords)
    dist = Euclidean()
    distancias = pairwise(dist, coords, dims=1) #el dims=1 es para especificar que vamos por las FILAS
    distancias = trunc.(Int, distancias) #las pasamos a enteros, el . es que se broadcastea a toda la matriz
    flujos = rand(minimo:maximo, (numLocations, numLocations))
    flujos[diagind(flujos)] .= 0 #convierte los índices de la diagonal principal de flujos en 0s
    flujos = Symmetric(flujos) #agarra la parte superior y la aplica a la parte inferior de la matriz
    println()
    print("Distance matrix: ")
    show(stdout, "text/plain", distancias)
    println()
    print("Flow matrix: ")
    show(stdout, "text/plain", flujos)
    name = "file" * string(instance, base=10)
    x = coords[:,1]
    y = coords[:,2]
    p = plot(x=x,y=y, Geom.point, Theme(panel_fill=colorant"white", default_color=colorant"orange"));
    push!(p, Guide.title("Locations"));
    name_plot = name * ".pdf"
    draw(PDF(name_plot, 5inch, 5inch), p)
    name = name * ".dat"
    firstLine = string(numLocations, base=10) * "\n"
    open(name, "w") do io
        write(io, firstLine)
        writedlm(io, [distancias], ' ')
        writedlm(io, [flujos], ' ')
    end
    println()
    printstyled(stdout, "Files written\n", color=:green)
end

try
    numLocations = parse(Int64, ARGS[1])
    numInstances = parse(Int64, ARGS[2])
    dir_path = string(numLocations, base=10)
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

