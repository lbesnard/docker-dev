FROM ubuntu:24.04

ARG USERNAME=lbesnard
ARG UID=1000
ARG GID=1000
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git openssh-client sudo file locales unzip xz-utils less procps \
      zsh tmux silversearcher-ag \
      build-essential cmake pkg-config \
      libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev libbz2-dev \
      libreadline-dev libsqlite3-dev libpq-dev \
      libnetcdf-dev libhdf5-dev libudunits2-dev iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# ubuntu:24.04 ships a default user at UID 1000; replace it
RUN userdel -r ubuntu 2>/dev/null || true \
 && groupadd -g ${GID} ${USERNAME} \
 && useradd -m -u ${UID} -g ${GID} -s /usr/bin/zsh ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
 && mkdir -p /opt/conda /workspace /home/${USERNAME}/github_repo \
 && chown -R ${UID}:${GID} /opt/conda /workspace /home/${USERNAME}

USER ${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}

# miniforge as base python
RUN curl -fsSL -o /tmp/miniforge.sh \
      "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh" \
 && bash /tmp/miniforge.sh -b -u -p /opt/conda && rm /tmp/miniforge.sh \
 && /opt/conda/bin/conda config --set auto_activate_base false \
 && /opt/conda/bin/conda create -y -n science python netcdf4 xarray h5py nco cdo dask \
 && /opt/conda/bin/conda clean -afy

ENV PATH=/home/${USERNAME}/.local/bin:/home/${USERNAME}/.local/share/mise/shims:/home/${USERNAME}/.local/share/zerobrew/prefix/bin:/opt/conda/bin:$PATH

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && curl -sSL https://install.python-poetry.org | /opt/conda/bin/python3 -

# mise-managed CLI tools (see mise.toml)
RUN curl -fsSL https://mise.run | sh
COPY --chown=${UID}:${GID} mise.toml /home/${USERNAME}/.config/mise/config.toml
RUN mise install && mise reshim

# zerobrew (brew-compatible, fast) for packages not in mise; see Brewfile
RUN curl -fsSL https://zerobrew.rs/install | bash
COPY --chown=${UID}:${GID} Brewfile /home/${USERNAME}/Brewfile
RUN zb bundle install -f /home/${USERNAME}/Brewfile && zb gc

COPY --chown=${UID}:${GID} entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
