struct solucion
    locations::Vector{Int64}
    value::Int64
    interchange1::Int
    interchange2::Int
end

function decisionMatrix(locations::Vector{Int64})::Matrix{Int64}
    X = zeros(Int64, (length(locations), length(locations)))
    for i in 1:length(locations)
        numero = locations[i]
        x = i
        y = numero
        X[x,y] = 1
    end
    return X
end

function move(costM::Matrix{Int64}, locations₀::Vector{Int64}, i::Int64, j::Int64)
    locations₁ = copy(locations₀)
    locations₁[i] = locations₀[j]
    locations₁[j] = locations₀[i]
    X = decisionMatrix(locations₁)
    value = 0
    indices = findall(x->x==1, X)
    for indice in indices
        value += costM[indice]
    end
    return solucion(locations₁,value,locations₁[i], locations₁[j])
end

function selectLeastWorst(currentNeighbourhood::Vector{solucion}, tabooList::Vector{Int64})::solucion
    leastWorstCurrentMove = popfirst!(currentNeighbourhood)
    interLstWorstCurr1 = leastWorstCurrentMove.interchange1
    interLstWorstCurr2 = leastWorstCurrentMove.interchange2
    if (tabooList[interLstWorstCurr1] ≠ 0 || tabooList[interLstWorstCurr2] ≠ 0)
        println("HEY IM NOT ALLOWED")
        selectLeastWorst(currentNeighbourhood, tabooList)
    else
        return leastWorstCurrentMove
    end
end

function taboo(costM::Matrix{Int64}, Σ₀::Int64, locations₀::Vector{Int64})
    println("Start locations: ", locations₀)
    bestValue = copy(Σ₀)
    println("Current best value: ", bestValue)
    bestLocations = copy(locations₀)
    currentLocations = copy(bestLocations)
    tabooList = zeros(Int64, 10)    
    for iteracion in 1:100
        currentNeighbourhood = solucion[]
        for i in 1:length(currentLocations)
            for j in 1:length(currentLocations)
                if i ≠ j
                    movement = move(costM, currentLocations, i,j)
                    push!(currentNeighbourhood, movement)
                end
            end
        end
        sort!(currentNeighbourhood, by = move -> move.value)
        #println(currentNeighbourhood)
        scores = Int[]
        for neighbor in currentNeighbourhood
            valor = neighbor.value
            score = bestValue - valor
            push!(scores, score)
        end
        allNegatives = all(<=(0), scores)
        if allNegatives
            leastWorstCurrentMove= selectLeastWorst(currentNeighbourhood, tabooList)
            currentLocations = leastWorstCurrentMove.locations
            #println("Iteration $iteracion, currentLocations: ", currentLocations)
            currValue = leastWorstCurrentMove.value
            #println("Value: ", currValue)
            interLstWorstCurr1 = leastWorstCurrentMove.interchange1
            interLstWorstCurr2 = leastWorstCurrentMove.interchange2
            #println("Swapped $interLstWorstCurr1 and $interLstWorstCurr2")
            moveds = findall(x->x≠0, tabooList)
                for moved in moveds
                    tabooList[moved]= tabooList[moved] - 1
                end
            tabooList[interLstWorstCurr1] = 5
            tabooList[interLstWorstCurr2] = 5
        else
            bestCurrentMove = popfirst!(currentNeighbourhood)
            if bestCurrentMove.locations == currentLocations
                bestCurrentMove = popfirst!(currentNeighbourhood)
            end
            interBestCurr1 = bestCurrentMove.interchange1
            interBestCurr2 = bestCurrentMove.interchange2
            if bestCurrentMove.value < bestValue && tabooList[interBestCurr1] == 0 && tabooList[interBestCurr2] == 0 # if best move matches acceptation and aspiration criteria
                bestValue = bestCurrentMove.value
                bestLocations = bestCurrentMove.locations
                currentLocations = copy(bestLocations)
                #println("Iteration $iteracion, currentLocations: ", currentLocations)
                #println("Value: ", bestValue)
                #println("Swapped $interBestCurr1 and $interBestCurr2")
                moveds = findall(x->x≠0, tabooList)
                for moved in moveds
                    tabooList[moved]= tabooList[moved] - 1
                end
                tabooList[interBestCurr1] = 5
                tabooList[interBestCurr2] = 5
            elseif bestCurrentMove.value < bestValue &&(tabooList[interBestCurr1] ≠ 0 || tabooList[interBestCurr2] ≠ 0) # if best move matches aspiration criteria but not acceptation
                bestValue = bestCurrentMove.value
                bestLocations = bestCurrentMove.locations
                currentLocations = copy(bestLocations)
                #println("Iteration $iteracion, currentLocations: ", currentLocations)
                #println("Value: ", bestValue)
                #println("Swapped $interBestCurr1 and $interBestCurr2")
                moveds = findall(x->x≠0, tabooList)
                for moved in moveds
                    tabooList[moved]= tabooList[moved] - 1
                end
                tabooList[interBestCurr1] = 5
                tabooList[interBestCurr2] = 5
            end
        end
    end
    X = decisionMatrix(bestLocations)
    return bestValue, bestLocations, X
end

function parseFile(path::String)
    stream = open(path, "r")
    contents = read(stream, String)
    close(stream)
    Σ, locations, X, costMStr, Δt = split(contents, "\n")
    Σ₀ = parse(Int, Σ)
    valorInicial = copy(Σ₀)
    locations₀ = [parse(Int, location) for location in split(locations)]
    Xmatrix = [parse(Int, x) for x in split(X)]
    Xmatrix = reshape(Xmatrix, (length(locations₀), length(locations₀)))
    X₀ = Xmatrix
    costM = [trunc(Int, parse(Float32,cost)) for cost in split(costMStr)]
    costM = reshape(costM, (length(locations₀), length(locations₀)))
    start = time_ns()
    Σ₁, locations₁, X₁ = taboo(costM, Σ₀, locations₀)
    finish = time_ns()
    Δt₁ = (finish - start) * 1e-3 # micro segundos
    improvement = valorInicial - Σ₁
    return Σ₁, locations₁, X₁, Δt₁, improvement
end

function main()
    path = "10_con\\file1_con.dat"
    Σ₁, locations₁, X₁, Δt₁, improvement = parseFile(path)
    println("New value: ", Σ₁)
    println("New locations: ", locations₁)
    println("Time: ", Δt₁)
    println("Improvement: ", improvement)
end

main()