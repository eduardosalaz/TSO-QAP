# Pseudocódigo de la heurística constructiva:

Procedimiento Constructiva()

1.- Input: matriz de costos , número de iteración

2.- Output: matriz de decisión X, Σ, lista de localizaciones

3.- While número de iteración < numero de localizaciones

    4.- Φ[x,y] <- argmin(costos)

    5.- valorMinimo <- costos[Φx,y]

    5.- Eliminar a la fila x, columna y de la matriz de costos (se dejan como infinito para eliminarlas)

    6.- Hacer a la matriz de decisión en X[x,y] <- 1

    7.- Sumar a Σ el valorMinimo

    8.- número de iteración += 1

9.- Terminar While

10.- En base a la matriz de decisión, generar la lista de localizaciones 

11.- Return matriz de decisión X, Σ, lista de localizaciones, matriz de costos

12.- Fin


# Pseudocódigo de la heurística de búsqueda local:

Procedimiento BúsquedaLocal()

1.- Input: lista de localizaciones₀, valor inicial Σ₀, matriz de costos

2.- Output: Lista nueva de localizaciones, valor actualizado Σ₁, matriz de decision

3.- Mejorar <- false

4.- MejoresLocalizaciones <- [], MejoresValores <- []

5.- For i en 1:lista de localizaciones₀

    6.- For j en 1:lista de localizaciones₀

    7.- Si i ≠ j

        8.- localizaciones₁ <- localizaciones₀

        9.- localizaciones₁[i] <- localizaciones₀[j]

        10.- localizaciones₁[j] <- localizaciones₀[1]

        11.- Obtener matriz de decisión nueva X en base a localizaciones₁

        12.- Valor nuevo Σ₁ <- 0

        13.- Indices <- Index(todos los elementos en X que sean 1)

        14.- For indice en indices:

            15.- Sumar a Σ₁ el costo de la matriz de costos del indice actual

        16.- Terminar For

        17.- If Σ₁ < Σ₀

            18.- Mejorar <- true

            19.- Empujar a MejoresLocalizaciones localizaciones₁

            20.- Empujar a Mejores Valores Σ₁

        21.- Terminar If

    22.- Terminar For

23.- Terminar For

24.- If Mejorar es true

    25.- Φ(localizaciones, valor) = argmin(MejoresLocalizaciones, MejoresValores)

    26.- Obtener matriz de decisión nueva X en base a Φ(localizaciones)

    27.- BúsquedaLocal(Φ(localizaciones, valor), X)

28.- Fin If

29.- Return Φ(localizaciones, valor), X

30.- Fin        