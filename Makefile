.phony : all, build, web, test, test-parallel, clean

DOCKER_IMAGE=randomlogosjl

all: build

build:
	-rm -f Manifest.toml docs/Manifest.toml
	docker build -t ${DOCKER_IMAGE} . --build-arg NB_UID=`id -u`
	docker compose build
	docker compose run --rm shell julia --project=@. -e 'using Pkg; Pkg.instantiate()'
	docker compose run --rm shell julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

# Excecute in docker container
web: docs
	julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); \
		include("docs/make.jl"); \
		using LiveServer; servedocs(host="0.0.0.0"); \
		'

test: build
	docker compose run --rm shell julia -e 'using Pkg; Pkg.activate("."); Pkg.test()'

clean:
	docker compose down
	-find $(CURDIR) -name "*.ipynb" -type f -delete
	-find $(CURDIR) -name "*.html" -type f -delete
	-find $(CURDIR) -name "*.gif" -type f -delete
	-find $(CURDIR) -name "*.ipynb_checkpoints" -type d -exec rm -rf "{}" +
	-rm -f  Manifest.toml docs/Manifest.toml
	-rm -rf docs/build
