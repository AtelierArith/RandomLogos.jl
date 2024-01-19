using RandomLogos
using Documenter

DocMeta.setdocmeta!(RandomLogos, :DocTestSetup, :(using RandomLogos); recursive=true)

makedocs(;
    modules=[RandomLogos],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    sitename="RandomLogos.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AtelierArith.github.io/RandomLogos.jl",
        edit_link="main",
        assets=String[],
        repolink = "https://github.com/AtelierArith/RandomLogos.jl",
    ),
    pages=[
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API" => "api.md",
    ],
    # generated HTML over size_threshold limit
    # https://documenter.juliadocs.org/latest/release-notes/#Breaking
    size_threshold=nothing, 
)

deploydocs(;
    repo="github.com/AtelierArith/RandomLogos.jl",
    devbranch="main",
)
