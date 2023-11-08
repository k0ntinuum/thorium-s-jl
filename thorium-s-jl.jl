using LinearAlgebra
using Printf

function str(v,s)
    join(map(i -> i ? "|"*s : "0"*s , v))
end

function key(n)
    rand(Bool,n,n)
end

function spin_row(k,i)
    circshift(k[i,:], k[i,i]  + 1)
end

function spin_col(k,i)
    circshift(k[:,i], k[i,i]  + 1)
end


function rgb(r,g,b)
    "\e[38;2;$(r);$(g);$(b)m"
end

function red()
    rgb(255,0,0)
end

function yellow()
    rgb(255,255,0)
end

function white()
    rgb(255,255,255)
end

function gray(h)
    rgb(h,h,h)
end


function print_key(k)
    for i in 1:size(k)[begin] print(str(k[i,:]," "),"\n") end
    print("\n")
end


function encode(p,q)
    k = copy(q)
    n = size(q)[begin]
    c = Bool[]
    for i in eachindex(p)
        push!(c,Bool((tr(k) + p[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    c
end

function decode(c,q)
    k = copy(q)
    n = size(q)[begin]
    p = Bool[]
    for i in eachindex(c)
        push!(p,Bool((tr(k) + c[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    p
end

function self(q)
    n = size(q)[begin]
    k = deepcopy(q)
    for i in 1:n k[i,:] = encode(q[i,:],q) end
    k
end
function alt_self(q)
    n = size(q)[begin]
    k = deepcopy(q)
    for i in 1:n k[i,:] = encode(k[i,:],q) end
    k
end

function story(q)
    n = size(q)[begin]
    k = deepcopy(q)
    s = []
    for i in 1:n
        push!(s,k)
        k = self(k)
        #k = alt_self(k)
    end
    s
end

function print_story(s)
    for i in 1:n print_key(s[i,:,:]) end
end

function encrypt(p, q)
    n = size(q)[begin]
    s = story(q)
    for i in 1:n
        p = encode(p,s[i])
        p = reverse(p)
    end
    p
end


function decrypt(c, q)
    n = size(q)[begin]
    s = story(q)
    for i in 1:n
        c = reverse(c)
        c = decode(c,s[n + 1 - i])
    end
    c
end

function demo()
    n = 32
    t = 32
    k = key(n)
    print(white(),"k =\n", gray(150))
    print_key(k)
    for i in 1:n
    	p = rand(Bool,t)
        print(white(),"f( ", red(), str(p,""), white()," ) = ")
        c  = encrypt(p,k)
        print(yellow(),str(c,""), "  ")
        e = p .== c
        print(gray(100),str(e,""), " \n")
        d  = decrypt(c,k)
        if p != d @printf "\nERROR\n" end 	
    end
    print(white())
end

function long_demo()
    n = 32
    k = key(n)
    t = 128
    w = 4
    print(white(),"k =\n", gray(150))
    print_key(k)
    for i in 1:w
    	p = rand(Bool,t)
        print( red(), str(p,""), "\n")
        c  = encrypt(p,k)
        print( yellow(), str(c,""), "\n")
        e = p .!= c
        print(gray(100),str(e,""), "\n\n")
        d  = decrypt(c,k)
        if p != d @printf "\nERROR\n" end 	
    end
    print(white())
end



