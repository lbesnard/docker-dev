# docker-dev

A minimal Ubuntu 24.04 dev container that isolates Copilot CLI and other dev tooling from the host. Your repos are bind-mounted, so edits are visible on both sides.

## What it provides

- **Python:** miniforge as base Python (`base` kept clean), a `science` conda env (netcdf4, xarray, h5py, nco, cdo, dask), `uv`, `poetry`.
- **CLI tools via [mise](https://mise.jdx.dev)** (edit `mise.toml`): neovim, fzf, ripgrep, fd, bat, lazygit, delta, starship, zoxide, yq, jq, gh, node, `@github/copilot`.
- **Extra packages via [zerobrew](https://github.com/zerobrewhq/zerobrew)** (`zb`, a fast Homebrew-compatible installer): list them in `Brewfile` (e.g. ranger, ncdu).
- **System:** zsh, tmux, silversearcher-ag, build-essential, cmake, NetCDF/HDF5 and common `-dev` libraries.
- **Dotfiles:** [`dotfiles`](https://github.com/lbesnard/dotfiles) and `dotfiles_private` are cloned on start (pulled on later starts) and a dev-only allowlist is symlinked into `$HOME`. `env_private`, `ssh` and `gh` config are deliberately not linked.
- **Isolation:**
  - No host `~/.ssh`, Docker socket, or host `~/.copilot` is mounted.
  - Only your `ssh-agent` socket is forwarded.
  - Copilot, gh, nvim and conda envs live in named Docker volumes.

## Quick start

```bash
ssh-add                 # load your key (needed to clone dotfiles_private)
./dev --rebuild         # first build (~13 min) and start the container
./dev                   # zsh in /workspace (= ~/github_repo)
./dev my-repo           # zsh in /workspace/my-repo
```

Once inside, run `gh auth login` and sign in to `copilot` (one-off; stored in volumes).

| Command | Effect |
|---|---|
| `./dev [repo]` | Start the container if needed and open zsh |
| `./dev --rebuild` | Rebuild the image and recreate the container |
| `./dev --stop` | Stop and remove the container (volumes are kept) |

## Configuration

- `WORKSPACE`: host directory mounted at `/workspace` (default `~/github_repo`).
- `UID` / `GID`: container user IDs (default 1000).
- Add tools in `mise.toml` (GitHub-release binaries) or `Brewfile` (zerobrew), then run `./dev --rebuild`. To try one without rebuilding, run `zb install <name>` inside the container (lost on recreate).
- Change linked dotfiles in the allowlist in `entrypoint.sh`.

## Notes

- If `dotfiles_private` is missing, the container warns and continues, but `~/.aws` won't resolve. Run `ssh-add` on the host and `docker restart dev`.
- AWS `config` and `credentials` are readable inside the container, so Copilot can read them.
