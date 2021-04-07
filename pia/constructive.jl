try
    file = ARGS[1]
    stream = open(file, "r")
    contents = read(stream, String)
    numLocations, distances, flow = split(contents, "\n")
    numLocations = parse(Int, numLocations)
    distancias = [parse(Int, distancia) for distancia in split(distances)]
    distancias = reshape(distancias, (numLocations, numLocations))
    flujos = [parse(Int, flujo) for flujo in split(flow)]
    flujos = reshape(flujos, (numLocations, numLocations))
    println("Number of Locations: " * string(numLocations, base=10))
    print("Distance matrix: ")
    show(stdout, "text/plain", distancias)
    println()
    print("Flow matrix: ")
    show(stdout, "text/plain", flujos)
    println()
catch
    @error "File is invalid"
end