# TSO

## Ejecución del PIA

Generador de Instancias del QAP, Heurística Constructiva y Heurística de Búsqueda Local

Probado en [Julia](https://julialang.org/downloads/) 1.6.0

Para ejecutar el PIA primero se debe de ejecutar el generador de instancias
```
julia generator.jl ARG1 ARG2
```
Donde ARG1 es el número de localizaciones y ARG2 el número de instancias a crear

Para ejecutar la heurística constructiva se debe de ejecutar
```
julia constructive.jl ARG1 ARG2
```
Donde ARG1 es el path completo al archivo .dat que se genera en el primer programa y ARG2 el tipo de verbosidad que se quiere (1 para verboso, otro para silencioso)

## Dependencias

Para instalar las dependencias del proyecto hay que activar el entorno especificado por Project.toml.

Una recomendación es añadir un archivo ```startup.jl``` en ```~\.julia\config``` e incluir
```
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end
```
de esta forma, cada vez que se inicie Julia, buscará el entorno apropiado para el proyecto y lo instalará automáticamente.

De otra forma, hay que entrar al modo de Pkg en el REPL de julia presionando ]
```
julia
julia> ]
(@v1.6) pkg> add Distances, Cairo, Gadfly
```
