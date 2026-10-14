# Windows setup - Single Cell Bioinformatics, Project 1

Short version: **don't run conda directly on Windows for this project.** Use WSL2 (Windows Subsystem for Linux) and follow the Linux instructions from inside it.

## Why

Several packages this project needs (SingleR, SingleCellExperiment, celldex - all from Bioconductor, distributed via the `bioconda` conda channel) are not built for native Windows at all. `conda env create` on plain Windows/Anaconda will fail to resolve the environment, not just install slowly.

## Setup steps

1. Install WSL2. Open PowerShell **as Administrator** and run:
   ```
   wsl --install
   ```
   Restart your computer when prompted. This installs Ubuntu by default.

2. Open the "Ubuntu" app from the Start menu and finish the first-run setup (create a Linux username/password - separate from your Windows login).

3. Inside the Ubuntu/WSL terminal, install Miniforge (this already includes mamba, which you want - see the note below):
   ```
   wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
   bash Miniforge3-Linux-x86_64.sh
   ```
   Follow the prompts, then close and reopen the terminal.

4. Copy `environment-linux.yml` into your WSL filesystem (e.g. `~/scb-project1/`) and create the environment with **mamba, not conda**:
   ```
   mamba env create -f environment-linux.yml
   conda activate single-cell
   ```

   Plain `conda env create` is known to be extremely slow (or to hang) on an environment this size - mamba solves the same file much faster. If for some reason mamba isn't available, at least run `conda config --set channel_priority strict` before falling back to `conda env create`.

5. Work from inside WSL for this project (edit with VS Code + the "WSL" extension, or RStudio Server inside WSL). Keep the project files in the Linux filesystem (e.g. `~/scb-project1/`) rather than under `/mnt/c/...` - R/conda I/O is much slower across the Windows/Linux filesystem boundary.

If you get stuck on WSL setup itself, Microsoft's docs are here: https://learn.microsoft.com/en-us/windows/wsl/install
