using DelimitedFiles
try
    print("Number of elements: ")
    n = parse(Int64, readline())
    if n > 0
        print("Minimum value: ")
        vmin = parse(Int64, readline())
        print("Maximum value: ")
        vmax = parse(Int64, readline())
        if vmax > vmin
            print("Minimum weight: ")
            wmin = parse(Int64, readline())
            print("Maximum weight: ")
            wmax = parse(Int64, readline())
            if wmax > wmin
                print("Number of instances to generate: ")
                k = parse(Int64, readline())
                if k > 0
                    W = 0.3*(n*(wmin+wmax)/2)
                    W = floor(Int64, W)
                    @time for i in 1:k
                        dir_path = string(n, base=10)
                        if !isdir(dir_path) #if dir doesnt exist yet
                            mkdir(dir_path)
                        end
                        if Sys.iswindows() # portability
                            name =  dir_path * "\\" * "file" * string(i,base=10)
                        else
                            name = dir_path * "/" * "file" * string(i,base=10)
                        end
                        firstLine = string(n, base=10) * " " * string(W, base=10)
                        firstLine = firstLine * "\n"
                        complete_path = name * ".dat"
                        open(complete_path, "w") do io
                            write(io, firstLine)
                        end #do io
                        rand_values = rand(vmin:vmax, n)
                        rand_weights = rand(wmin:wmax, n)
                        open(complete_path, "a") do io
                            writedlm(io, [rand_values rand_weights], ' ')
                        end #io
                    end #for i
                else
                    @error "You should generate at least 1 instance"
                end #if k
            else
                @error "Max weight should be more than min weight"
            end #if wmax
        else
            @error "Max value should be more than min value"
        end #if vmax
    else
        @error "n should be greater than 0"
    end # if n>0
catch
    @error "Wrong input"
end # try
