# TSO

## Ejecución del PIA

Generador de Instancias del QAP, Heurística Constructiva y Heurística de Búsqueda Local

Probado en [Julia](https://julialang.org/downloads/) 1.6.0

### PIA en un solo archivo:
Para ejecutar el PIA en un sólo archivo (para el análisis y experimentación) se ejecuta
```
julia pia.jl
```
usando la bandera de ```--help```:
```
usage: pia.jl [-h] batchSize instanceSize

positional arguments:
  batchSize     Number of instances in batch (type: Int64)
  instanceSize  Size of instances of batch: S, M or L

optional arguments:
  -h, --help    show this help message and exit
```

### PIA en archivos separados

Para ejecutar el PIA de manera secuencial, primero se debe de ejecutar el generador de instancias
```
julia generator.jl
```
usando la bandera de ```--help```:
```
usage: generator.jl [-v] [-h] nLocations nInstances

positional arguments:
  nLocations     Number of locations of the instance (type: Int64,
                 default: 0)
  nInstances     Number of instances (type: Int64, default: 0)

optional arguments:
  -v, --verbose  Specify verbose output
  -h, --help     show this help message and exit
```
Posteriormente, para ejecutar la heurística constructiva se debe de ejecutar
```
julia constructive.jl
```
usando la bandera de ```--help```:
```
usage: constructive.jl [-d] [-v] [-s] [-h] path

positional arguments:
  path           Path to file or directory

optional arguments:
  -d, --dir      Specify if a directory is to be read
  -v, --verbose  Specify verbose output
  -s, --save     Save solutions to files
  -h, --help     show this help message and exit
```
Por último, para ejecutar la heurística de búsqueda local se debe de ejecutar
```
julia localSearch.jl
```
usando la bandera de ```--help```:
```
usage: localSearch.jl [-d] [-v] [-s] [-h] path

positional arguments:
  path           Path to file or directory OF SOLUTIONS

optional arguments:
  -d, --dir      Specify if a directory is to be read
  -v, --verbose  Specify verbose output
  -s, --save     Save solutions to files
  -h, --help     show this help message and exit
```
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
(@v1.6) pkg> add Distances, ArgParse, Plots, DataFrames, StatsPlots
```
