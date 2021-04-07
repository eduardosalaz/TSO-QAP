try
    file = ARGS[1]
    stream = open(file, "r")
    contents = read(stream, String)
    numLocations, distString, flowString = split(contents, "\n") # cada salto de linea representa un valor nuevo
    numLocations = parse(Int, numLocations)
    distances = [parse(Int, distance) for distance in split(distString)] # pasamos el string que leimos a un arreglo 
    distanceM = reshape(distances, (numLocations, numLocations)) # al arreglo le damos la forma de la matriz tomando en cuenta numLocations 
    flows = [parse(Int, flow) for flow in split(flowString)]
    flowM = reshape(flows, (numLocations, numLocations))
    println("Number of Locations: " * string(numLocations, base=10))
    print("Distance matrix: ")
    show(stdout, "text/plain", distanceM)
    println()
    print("Flow matrix: ")
    show(stdout, "text/plain", flowM)
    println()
catch
    @error "File is invalid"
end