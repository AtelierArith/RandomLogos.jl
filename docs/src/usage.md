```@meta
CurrentModule = RandomLogos
```

# Usage

Let's get started😆😆😆! Open Julia REPL and run the following code:

```@example usage
using TOML
using Random
using Images

import RandomLogos
using RandomLogos: render
using RandomLogos: Config
```

Go on the next section below.

## Example(`config_mt.toml`)

```@example usage
configpath = joinpath(pkgdir(RandomLogos), "examples", "config_mt.toml")
toml = TOML.parsefile(configpath)
toml
```

```@example usage
canvas = render(configpath)
canvas
```

## Example(`config_xoshiro.toml`)

```@example usage
configpath = joinpath(pkgdir(RandomLogos), "examples", "config_xoshiro.toml")
toml = TOML.parsefile(configpath)
toml
```

```@example usage
canvas = render(configpath)
canvas
```

## Example(Generating multiple logos)

We can generate multiple logos as below:

```@example usage
configpath = joinpath(pkgdir(RandomLogos), "examples", "config_mt.toml")
config = Config(configpath)
logos = Matrix{RGB{N0f8}}[]
for s in 1:30
    rng = MersenneTwister(999 + s)
    ifs = rand(rng, RandomLogos.SigmaFactorIFS{2})
    rng = MersenneTwister(999 + 2s)
    canvas = render(rng, ifs, config)
    push!(logos, canvas)
end

reshape(logos, 5, 6)
```
