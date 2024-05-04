FROM julia:1.10.3

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    curl \
    ca-certificates \
    git \
    wget \
    zip \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Dependencies for development
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

ENV PATH=$PATH:$HOME/.rye/shims
RUN curl -sSf https://rye-up.com/get | RYE_VERSION="0.32.0" RYE_INSTALL_OPTION="--yes" bash
RUN $HOME/.rye/shims/rye config --set-bool behavior.use-uv=true

RUN $HOME/.rye/shims/rye tools install jupyter \
    && $HOME/.rye/shims/rye tools install jupyterlab \
    && $HOME/.rye/shims/rye tools install jupytext \
    && $HOME/.rye/shims/rye tools install ruff

WORKDIR ${HOME}
USER ${USER}

USER root
RUN mkdir -p ${HOME}/.local ${HOME}/.jupyter
# Set color theme Monokai++ by default

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension && \
    echo '{"shortcuts": [{"command": "runmenu:restart-and-run-all", "keys": ["Alt R"], "selector": "[data-jp-code-runner]"}]}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings

# Modify defaultViewers
RUN jupytext-config set-default-viewer

RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
    # set environment variables\n\
    ENV["PYTHON"]=Sys.which("python3")\n\
    ENV["JUPYTER"]=Sys.which("jupyter")\n\
    ' >> ${HOME}/.julia/config/startup.jl && cat ${HOME}/.julia/config/startup.jl

RUN julia -e 'using Pkg; Pkg.add(["Revise", "LiveServer", "Pluto", "PlutoUI"])' && \
    julia -e 'using Pkg; Pkg.add(["BenchmarkTools", "ProfileSVG", "JET", "JuliaFormatter"])'

# Launch Revise automatically within IJulia
# https://timholy.github.io/Revise.jl/stable/config/#Using-Revise-automatically-within-Jupyter/IJulia-1
RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
    try; @eval using Revise; catch e; @warn "Error initializing Revise" exception=(e, catch_backtrace()); end \n\
    ' >> ${HOME}/.julia/config/startup_ijulia.jl && cat ${HOME}/.julia/config/startup_ijulia.jl

RUN julia --threads auto -e '\
    using Pkg; \
    using Base.Threads; \
    Pkg.add("IJulia"); \
    using IJulia; \
    installkernel("Julia", "--project=@.");\
    installkernel("Julia-$(nthreads())-threads", "--project=@.", env=Dict("JULIA_NUM_THREADS"=>"$(nthreads())")); \
    ' && \
    echo "Done"

ENV JULIA_PROJECT "@."
WORKDIR /workspace/RandomLogos.jl

USER root
RUN chown -R ${NB_UID} /workspace/RandomLogos.jl
USER ${USER}

RUN mkdir -p /workspace/RandomLogos.jl/src && echo "module RandomLogos end" > /workspace/RandomLogos.jl/src/RandomLogos.jl
COPY ./Project.toml /workspace/RandomLogos.jl

ENV PATH=${PATH}:${HOME}/.local/bin

USER root
RUN chown -R ${NB_UID} /workspace/RandomLogos.jl
USER ${USER}

RUN rm -f Manifest.toml && julia -e 'using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile()' && \
    # Check Julia version \
    julia -e 'using InteractiveUtils; versioninfo()'

USER ${USER}
EXPOSE 8000
EXPOSE 8888
EXPOSE 1234

CMD ["julia"]
