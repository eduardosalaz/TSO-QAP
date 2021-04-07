# TSO

## Ejecución del PIA
Probado en Julia 1.6.0

Para ejecutar el PIA primero se debe de ejecutar el generador de instancias
```
julia generator.jl ARG1 ARG2
```
Donde ARG1 es el número de localizaciones y ARG2 el número de instancias a crear

Para ejecutar la heurística constructiva se debe de ejecutar
```
julia constructive.jl ARG1
```
Donde ARG1 es el path completo al archivo .dat que se genera en el primer programa.

## Dependencias

Para instalar las dependencias del proyecto (Distances) hay que activar el entorno especificado por Project.toml
Una recomendación es añadir un archivo ```startup.jl``` en ```~\.julia\config``` e incluir
```
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end
```
de esta forma, cada vez que se inicie Julia, buscará el entorno apropiado para el proyecto y lo instalará automáticamente
