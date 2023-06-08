# RandomLogos [![Build Status](https://github.com/AtelierArith/RandomLogos.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/AtelierArith/RandomLogos.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://AtelierArith.github.io/RandomLogos.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://AtelierArith.github.io/RandomLogos.jl/dev/)
# RandomLogos.jl



```console
$ julia --project -e 'using Pkg; Pkg.instantiate()'
$ cat run.jl
using ImageInTerminal
using RandomLogos: render
render("examples/config_mt.toml") |> display
$ julia --project run.jl
```
