```@meta
CurrentModule = RandomLogos
```

# RandomLogos

Documentation for [RandomLogos](https://github.com/AtelierArith/RandomLogos.jl).

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

Go on to the next page [Usage](usage.md)