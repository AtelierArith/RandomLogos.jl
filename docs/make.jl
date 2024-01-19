using RandomLogos
using Documenter

DocMeta.setdocmeta!(RandomLogos, :DocTestSetup, :(using RandomLogos); recursive=true)

makedocs(;
    modules=[RandomLogos],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo=Remotes.Remote,
    sitename="RandomLogos.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AtelierArith.github.io/RandomLogos.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/AtelierArith/RandomLogos.jl",
    devbranch="main",
)
