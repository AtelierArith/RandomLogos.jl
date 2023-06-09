using Images
using RandomLogos: render
canvas = render("examples/config_mt.toml")
save("logo.png", canvas)
