# AOCL.jl

*Use AOCL BLAS and LAPACK in Julia*

[![CI][CI-img]][CI-url]
[![PkgEval][pkgeval-img]][pkgeval-url]

[CI-img]: https://github.com/junyuan-chen/AOCL.jl/workflows/CI/badge.svg
[CI-url]: https://github.com/junyuan-chen/AOCL.jl/actions?query=workflow%3ACI

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/A/AOCL.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/A/AOCL.html

[AOCL.jl](https://github.com/junyuan-chen/AOCL.jl) is a Julia package
that allows replacing Julia's BLAS and LAPACK backends
with [AOCL-BLAS and AOCL-LAPACK](https://www.amd.com/en/developer/aocl/dense.html) from AMD
by simply loading the package with `using AOCL`.
This is possible at runtime due to
[libblastrampoline](https://github.com/JuliaLinearAlgebra/libblastrampoline).

This package does not cover all libraries of
[AOCL](https://www.amd.com/en/developer/aocl.html).
For [AOCL-LibM](https://www.amd.com/en/developer/aocl/libm.html),
see [AOCLLibM.jl](https://github.com/junyuan-chen/AOCLLibM.jl).

## Installation

Users are required to install the relevant
[AOCL libraries](https://www.amd.com/en/developer/aocl/dense.html) directly from AMD,
as AOCL.jl does not contain any content from AOCL.
This may change in the future if registered JLL packages
delivering the library files become available.

AOCL.jl can be installed with the Julia package manager
[Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/).
From the Julia REPL, type `]` to enter the Pkg REPL and run:

```
pkg> add AOCL
```

## Usage

AOCL.jl tries to locate AOCL-BLAS and AOCL-LAPACK libraries
by first checking the environment variables `AOCL_BLAS_LIB` and `AOCL_LAPACK_LIB`,
which specify the paths of these libraries.
If either of the environment variables is not set,
AOCL.jl tries to search via `Libdl.find_library`.
Nothing will be changed if the necessary libraries cannot be located.

To verify that AOCL.jl has loaded the libraries successfully,
one should expect results similar to the following:

```julia
julia> using LinearAlgebra, AOCL

julia> BLAS.get_config()
LinearAlgebra.BLAS.LBTConfig
Libraries: 
├ [ILP64] libopenblas64_.so
├ [ILP64] libblis-mt.so
└ [ILP64] libflame.so
```

> Notice that `libblis-mt` is the library name for `AOCL-BLAS`
> and `libflame` is the name for `AOCL-LAPACK`.

By default, the number of threads used by AOCL-BLAS is set to be
the value returned by `Threads.nthreads()`:

```julia
julia> AOCL.get_num_threads() == Threads.nthreads()
true
```

To change the number of threads to `n`, one may do:

```julia
julia> AOCL.set_num_threads(n)
```

Performance gains from AOCL.jl require a recent AMD CPU with the Zen microarchitecture.
Choice of the kernels optimized for a specific generation of the Zen microarchitecture
is typically selected automatically,
but may be overriden by setting the environment variable `BLIS_ARCH_TYPE`
before loading AOCL.jl to a suitable value (see AOCL User Guide).

## Disclaimer

AOCL.jl does not include or redistribute any AOCL library
and is not affiliated with or endorsed by AMD.
It only redirects Julia BLAS and LAPACK calls to AOCL via libblastrampoline.
Users are expected to download AOCL libraries separately from AMD.
