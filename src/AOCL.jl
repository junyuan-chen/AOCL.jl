module AOCL

using Libdl: find_library
using LinearAlgebra: BLAS

# Use typed globals introduced in Julia v1.8
global libaoclblas::String
global libaocllapack::String

function get_num_threads()::Cint
    ccall((:bli_thread_get_num_threads, libaoclblas), Cint, ())
end

function set_num_threads(n::Integer)
    n = Cint(n)
    ccall((:bli_thread_set_num_threads, libaoclblas), Cvoid, (Cint,), n)
end

function lbt_forward_to_aocl()
    # Without a registered jll package, users are required to install AOCL directly
    global libaoclblas = get(ENV, "AOCL_BLAS_LIB", find_library("libblis-mt.so"))
    if libaoclblas == ""
        @warn "AOCL-BLAS library is not found"
    else
        BLAS.lbt_forward(libaoclblas; clear=false)
        set_num_threads(Threads.nthreads())
    end
    global libaocllapack = get(ENV, "AOCL_LAPACK_LIB", find_library("libflame.so"))
    if libaocllapack == ""
        @warn "AOCL-LAPACK library is not found"
    else
        BLAS.lbt_forward(libaocllapack; clear=false)
    end
    return nothing
end

function __init__()
    lbt_forward_to_aocl()
end

end # module AOCL
