# Docker aliases for NEMESIS

These scripts add shell aliases for NEMESIS executables when NEMESIS is installed via Docker. After the aliases are loaded, the executables can be run normally from your working directory, for example:

```sh
Nemesis <runname.nam> test.prc &
```

Each alias runs the matching executable inside the `patrickirwinoxford/docker_nemesis` Docker image and mounts the current directory as `/data`:

```sh
docker run --rm -i -v "$(pwd)":/data -w /data patrickirwinoxford/docker_nemesis <executable>
```

## `.kls` and `.lls` external data mounts

Aliases for executables whose names begin with `Nemesis` (for example, `NemesisL` and `NemesisPT`) use the `nemesis_docker` wrapper. In addition to mounting the calculation directory at `/data`, the wrapper does the following each time it runs:

1. Searches the current calculation directory for a single `.kls` or `.lls` file.
2. Ignores the auxiliary files `intrad.kls` and `intrad.lls` when searching.
3. Reads the non-empty, non-comment paths in that list file.
4. Leaves relative paths unchanged, because the calculation directory is already available inside the container as `/data`.
5. For every absolute path, verifies that the file exists on the host and mounts its parent directory read-only at the identical absolute path inside Docker.
6. Adds each external directory only once, even if several list entries use the same directory.

For example, if `calculation.kls` contains:

```text
tables/h2o.tbl
/Users/me/nemesis-data/absorption.tbl
```

the first path is read from `/data/tables/h2o.tbl`. The second path causes this additional Docker mount:

```text
--mount type=bind,source=/Users/me/nemesis-data,target=/Users/me/nemesis-data,readonly
```

The wrapper stops with an error if it finds more than one calculation `.kls`/`.lls` file, or if an absolute path listed in the file does not exist. Standard aliases for all other executables use the shorter `nemesis_docker_run` helper and only mount the current directory.

The Bash and zsh installers define these helpers directly in the generated shell-startup block. C shell/tcsh has no shell functions, so its generated aliases call the included `nemesis_docker_helper.sh` script (using the Bash path detected when the installer runs).

## Instructions

The aliases are generated from:

```sh
nemesis_executables.txt
```

To add or remove an executable, edit that file and rerun the script for your shell.

1. **Bash**

Run this from a Bash terminal:

```sh
./add_nemesis_docker_aliases.sh
source ~/.bashrc
```

This updates `~/.bashrc`.

2. **zsh on macOS**

Run this from a zsh terminal:

```sh
./add_nemesis_docker_aliases.zsh
source ~/.zshrc
```

This updates `~/.zshrc`.

3. **C shell or tcsh**

Run this from a `csh` or `tcsh` terminal:

```csh
./add_nemesis_docker_aliases.csh
source ~/.cshrc
```

This updates `~/.cshrc`.

To update a different file, pass the target file as the first argument:

```sh
./add_nemesis_docker_aliases.sh /path/to/.bashrc
./add_nemesis_docker_aliases.zsh /path/to/.zshrc
./add_nemesis_docker_aliases.csh /path/to/.cshrc
```

## Docker image name

By default, the scripts use the Docker image name `patrickirwinoxford/docker_nemesis`.

To use a different image name, set `NEMESIS_DOCKER_IMAGE` before running the script:

```sh
NEMESIS_DOCKER_IMAGE=my-image-name ./add_nemesis_docker_aliases.sh
```

For zsh:

```zsh
NEMESIS_DOCKER_IMAGE=my-image-name ./add_nemesis_docker_aliases.zsh
```

For C shell or tcsh:

```csh
setenv NEMESIS_DOCKER_IMAGE my-image-name
./add_nemesis_docker_aliases.csh
```

## Notes

The scripts write aliases inside a managed block in your shell startup file. Rerunning a script refreshes that block instead of adding duplicate aliases.

## Links

- NEMESIS on Docker Hub: https://hub.docker.com/r/patrickirwinoxford/docker_nemesis
- NEMESIS on GitHub: https://github.com/nemesiscode/radtrancode.git
