# RandomLogos.jl [![Build Status](https://github.com/AtelierArith/RandomLogos.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/AtelierArith/RandomLogos.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://AtelierArith.github.io/RandomLogos.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://AtelierArith.github.io/RandomLogos.jl/dev/)

<img width="800" alt="image" src="https://github.com/AtelierArith/RandomLogos.jl/assets/16760547/9969325c-9740-4b0d-aa91-1c3ea5062cbd">

# Description

This repository aims to generate fancy fractal objects using an algorithm [based on the SVD-based approach for sampling IFS (Iterated Function Systems), as Connor Anderson and Ryan Farrell proposed](https://catalys1.github.io/fractal-pretraining/). While the original authors implemented the algorithm they suggested using Python, our implementation adopts JuliaLang, a JIT-compiled language.

# How to use

## Install Julia

Let's install JuliaLang v1.9.1 from https://julialang.org/downloads/. Make sure you can execute the `julia` command in your terminal:

```console
$ date
Fri Jun  9 19:16:08 JST 2023
$ julia --version
1.9.1
```

Then run the following commands:

```console
$ git clone https://github.com/AtelierArith/RandomLogos.jl.git
$ cd RandomLogos.jl
$ julia --project -e 'using Pkg; Pkg.instantiate()'
$ cat run.jl
using Images
using RandomLogos: render
canvas = render("examples/config_mt.toml")
save("logo.png", canvas)
$ julia --project run.jl
$ ls
logo.png
```

More examples can be found [here](https://AtelierArith.github.io/RandomLogos.jl/dev/).

