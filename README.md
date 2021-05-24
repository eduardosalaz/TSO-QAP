# TSO-QAP

## PIA execution

QAP Instance Generator, Constructive and Local Search heuristics, Tabu Search Metaheuristics and Analysis tools

Tested in [Julia](https://julialang.org/downloads/) 1.6.0, should work in the near and long term (Julia 1.6 is a LTS version)

## Dependencies

In order to install the required dependencies specified by Project.toml.

One recommendation is to create a ```startup.jl``` file in ```~\.julia\config``` and add the following lines
```
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end
```
this will ensure that Julia will search and install the project automatically every time.

If this is not performed, then the Pkg mode must be accesed by entering ] inside Julia and every dependence manually added
```
julia
julia> ]
(@v1.6) pkg> add Distances, ArgParse, Plots, DataFrames, StatsPlots, CSV
```

### PIA in a single run:
In order to execute the PIA in a single file(includes tools for analysis and experimentation), one must run
```
julia pia.jl
```
using the flag of ```--help```:
```
usage: pia.jl [-h] batchSize instanceSize

positional arguments:
  batchSize     Number of instances in batch (type: Int64)
  instanceSize  Size of instances of batch: S, M or L

optional arguments:
  -h, --help    show this help message and exit
```

There is also a version of the PIA without TS, in the file accordingly named.

### PIA in individual files.

In order to execute the PIA sequentally, one must first run the instance generator
```
julia generator.jl
```
using the flag of ```--help```:
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
Afterwards, in order to run the heuristic constructive, the next must be entered and executed
```
julia constructive.jl
```
using the flag of ```--help```:
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
To execute the local search heuristic, the next must be entered and executed
```
julia localSearch.jl
```
using the flag of ```--help```:
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

Finally, to run the Tabu search metaheuristic, the next must be entered and executed
```
julia tabuSearch.jl
```
using the flag of ```--help```:
```
usage: tabuSearch.jl [-d] [-v] [-s] [-h] path iters

positional arguments:
  path           Path to file or directory OF SOLUTIONS
  iters          Number of iterations before stopping

optional arguments:
  -d, --dir      Specify if a directory is to be read
  -v, --verbose  Specify verbose output
  -s, --save     Save solutions to files
  -h, --help     show this help message and exit
```

## Additional work
This code is available online on [an online repository](https://github.com/eduardosalaz/TSO-QAP). In this repository a Jupyter Lab will be prepared so anyone can access and run the project without having to install Julia on their personal computers. It will take a few days (As of May 23rd 2021) but it should be up and running relatively soon. The simulated annealing metaheuristic and long term memory component of TS are also expected to be completed on the coming months.
