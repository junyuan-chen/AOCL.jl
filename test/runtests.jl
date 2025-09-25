using Test
using AOCL
using AOCL: lbt_forward_to_aocl, get_num_threads, set_num_threads
using AOCL_jll
using LinearAlgebra

const linalg_stdlib_test_path = joinpath(dirname(pathof(LinearAlgebra)), "..", "test")

loaded(lib) = any(x->contains(basename(x.libname), lib), BLAS.get_config().loaded_libs)

# ! The test only works on Linux with Julia v1.11 or above due to the availability of AOCL_jll

@testset "lbt_forward" begin
    @test !loaded("libblis-mt")
    @test !loaded("libflame")
    ENV["AOCL_BLAS_LIB"] = aocl_blas_ilp64
    ENV["AOCL_LAPACK_LIB"] = aocl_lapack_ilp64
    lbt_forward_to_aocl()
    @test loaded("libblis-mt")
    @test loaded("libflame")
end

@testset "threads" begin
    nthreads = get_num_threads()
    @test nthreads == Threads.nthreads()
    set_num_threads(4)
    @test get_num_threads() == 4
    set_num_threads(nthreads)
end

@testset "BLAS" begin
    # run all BLAS tests of the LinearAlgebra stdlib (i.e. LinearAlgebra/test/blas.jl)
    loaded("libblis-mt") && include(joinpath(linalg_stdlib_test_path, "blas.jl"))
end

@testset "LAPACK" begin
    # run all LAPACK tests of the LinearAlgebra stdlib (i.e. LinearAlgebra/test/lapack.jl)
    loaded("libflame") && include(joinpath(linalg_stdlib_test_path, "lapack.jl"))
end
