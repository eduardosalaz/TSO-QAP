dist = [0 47 61 86 56; 47 0 31 66 65; 61 31 0 35 47; 86 66 35 0 44; 56 65 47 44 0]
flow = [0 72 23 19 43; 72 0 45 4 93; 23 45 0 31 33; 19 4 31 0 28; 43 93 33 28 0]
costo = dist * flow

filas = []
tope = trunc(Int, √length(costo))
for fila in 1:tope
    push!(filas, costo[fila, :])
end

valores = []
indices = []

for fila in filas
    valor, indice = findmin(fila)
    push!(valores, valor)
    push!(indices, indice)
end

juntos = hcat(indices, valores)

sorteados = sortslices(juntos, dims=1, by=x->(x[1], x[2]))

previous = 0
repetidos = false
indexCool = 0
for i in 1:tope
    if sorteados[i, 1] == previous
        repetidos = true
        indexCool = i
        break
    end
    previous = sorteados[i,1]
end

indexCool2 = indexCool-1
