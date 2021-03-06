Base.call{T <: SymbolicObject}(ex::T) = ex
function Base.call{T <: SymbolicObject}(ex::T, args...)
    xs = free_symbols(ex)
    if length(xs) >= 1
        subs(ex, collect(zip(xs, args))...)
    else
        if classname(ex) == "Symbol"
            ex
        else
            pycall(PyObject(ex), PyAny, args...)
        end
    end
end
Base.call(ex::SymbolicObject, x::Dict) = subs(ex, x)
Base.call(ex::SymbolicObject, x::Pair...) = subs(ex, x...)


## for symbolic functinos (dsolve)
Base.call(u::SymFunction, x::Base.Dict) = throw(ArgumentError("IVPsolutions can only be called with symbolic objects"))
Base.call(u::SymFunction, x::Base.Pair) = throw(ArgumentError("IVPsolutions can only be called with symbolic objects"))
function Base.call(u::SymFunction, x::Sym)
    if u.n == 0
        u.x(PyObject(x))
    else
        __x = Sym("__x")
        diff(u.x(PyObject(__x)), __x, u.n)(__x => x)
    end
end

function Base.call(u::SymFunction, x::Sym, y...)
    if u.n== 0
        u.x(vcat(x, y...)...)
    else
        error("Need to implement derivatives of symbolic functions of two or more variables")
    end
end
