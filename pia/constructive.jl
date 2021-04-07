try
    file = ARGS[1]
    stream = open(file, "r")
    contents = read(stream, String)
    contents = replace(contents, "\n"=>"")
    numLocations, distances, flow = split(contents, "*")
    numLocations = parse(Int, numLocations)
    distancias = [parse(Int, distancia) for distancia in split(distances)]
    distancias = reshape(distancias, (numLocations, numLocations))
    flujos = [parse(Int, flujo) for flujo in split(flow)]
    flujos = reshape(flujos, (numLocations, numLocations))
    println(numLocations)
    println(distancias)
    println(flujos)
catch
    @error "File is invalid"
end