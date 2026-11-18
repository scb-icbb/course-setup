# Installing ArchR for Project 2 (scATAC-seq)

In Project 2 you analyse scATAC-seq data with **ArchR**. You do **not** need a new environment: you add ArchR to the `single-cell` environment you already set up for Project 1. Project 2 reuses your annotated Seurat object from Project 1, so both projects must run in the same environment.

**Time:** about 20 to 40 minutes, most of it waiting for downloads.
**Disk space:** about 3 GB free. The human genome package (hg38) alone is about 800 MB.
**Windows:** do every step inside your WSL (Ubuntu) terminal, exactly as for Project 1 (see `README-Windows.md`).

---

## Step 1: Check that your Project 1 environment works

Open a terminal and activate the environment:

```bash
conda activate single-cell
```

Check that Seurat 4 loads:

```bash
Rscript -e 'library(Seurat); packageVersion("Seurat")'
```

You should see `4.4.0` (any `4.x` is fine). If Seurat does not load, get your Project 1 setup working before you continue.

## Step 2 (optional): Make a backup copy of your environment

If you want to be sure the installation cannot break your Project 1 setup, copy the environment first:

```bash
conda create -n single-cell-backup --clone single-cell
```

This needs a few GB of extra disk space. If anything goes wrong later, you can keep working in `single-cell-backup`. You can delete the backup once Project 2 runs:

```bash
conda env remove -n single-cell-backup
```

## Step 3: Get the install script

Go to the directory where you cloned the course-setup folder from `github.com/scb-icbb/course-setup.git`
and download the install script `build-helpers/install_archr.R` using:

```bash
cd course-setup
git fetch
git pull
```

## Step 4: Install ArchR's conda dependencies

**Apple Silicon Mac (M1/M2/M3/M4) only:** first find out whether your environment runs natively or under Rosetta. With the environment activated, run:

```bash
conda config --env --show subdir
```

- If it prints `subdir: osx-64`, Put `CONDA_SUBDIR=osx-64` in front of the `mamba install` command below, with a space after it, on the same line.
- If it prints `subdir: osx-arm64` or `subdir: None`, use the command as it is.

On Intel Macs, Linux and WSL, use the command as it is.

With the environment still activated, run:

```bash
mamba install --freeze-installed -c conda-forge -c bioconda "r-base=4.2.*" "r-seurat=4.*" "r-dbplyr=2.3.4" "r-matrixstats=1.1.0" bioconductor-chromvar bioconductor-motifmatchr bioconductor-rsamtools bioconductor-bsgenome bioconductor-bsgenome.hsapiens.ucsc.hg38 bioconductor-jaspar2020 bioconductor-tfbstools r-nabor r-harmony r-ggseqlogo macs2
```

**Before you type `y`, read the list mamba shows you.**

- It should mostly say **Install**. An update of `ca-certificates` or `openssl` is fine.
- If it wants to **downgrade, upgrade or remove** `r-base`, `r-seurat`, `r-seuratobject`, `r-rcpp`, `r-matrix`, `r-matrixstats` or `r-dbplyr`, type `n` and ask a tutor.

The step finishes with `Executing transaction: done`. Downloading the genome package takes a while; let it run.

## Step 5: Install ArchR

With the environment activated, run in the **terminal** (not inside R):
(change path/to/your/course-setup accordingly.)

```bash
cd path/to/your/course-setup
Rscript build-helpers/install_archr.R
```

The script installs three packages from GitHub: `presto`, `chromVARmotifs` and `ArchR` (version 1.0.3). It changes one line in ArchR so that label transfer from your Project 1 RNA object (`addGeneIntegrationMatrix`) works with our Seurat version.

It takes a few minutes, because ArchR is compiled. You will see a lot of compiler output, and warnings are normal. The last line must be:

```
ArchR 1.0.3 installed (with Seurat 4.4.0).
```

**Do not** install ArchR any other way, for example with `devtools::install_github("GreenleafLab/ArchR")` or with ArchR's own `installExtraPackages()`. That would install ArchR without the fix, or upgrade packages the course depends on.

## Step 6: Check the installation

Start R from the activated environment and run:

```r
library(Seurat)
library(ArchR)
library(BSgenome.Hsapiens.UCSC.hg38)   # needed for peak calling in Week 2
addArchRGenome("hg38")
packageVersion("ArchR")      # 1.0.3
packageVersion("Seurat")     # 4.4.0
```

You should see the ArchR logo and `Setting default genome to Hg38.` No errors.

Check that ArchR finds MACS2, which you need for peak calling in Week 2:

```r
findMacs2()                  # prints "macs2"
```

Then check that your Project 1 packages still load:

```r
library(CellChat)
library(monocle3)
library(SingleR)
```

If all of this works, you are ready for Project 2.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| mamba fails with `Could not solve for environment specs` | Run the command again without `--freeze-installed`, read the list as described in Step 4, and only continue if it says Install. Otherwise ask a tutor. |
| The install script stops with `HTTP error 403` or `API rate limit exceeded` | GitHub limits anonymous downloads. Wait an hour and run the script again, or create a GitHub token and set it as `GITHUB_PAT` before running the script. |
| The install script stops with `ArchR source does not look like v1.0.3 - patch not applied` | Ask a tutor. Don't install ArchR another way. |
| ArchR compile fails with `clang: command not found` or `xcrun: error` (Mac) | Install the Xcode command line tools with `xcode-select --install`, then run Step 5 again. |
| `addGeneIntegrationMatrix` fails with `length of 'dimnames' [1] not equal to array extent` | You have an ArchR without the course fix. Run Step 5 again. |
| ArchR fails with `unable to lock file` or another HDF5 error | Your data is probably on a network drive or, on WSL, under `/mnt/c/...`. Move the project into your home folder (for example `~/scb/`). If that isn't possible, run `Sys.setenv(HDF5_USE_FILE_LOCKING = "FALSE")` in R before `library(ArchR)`. |
| `addGroupCoverages` stops with `object 'BSgenome.Hsapiens.UCSC.hg38' not found` | Run `library(BSgenome.Hsapiens.UCSC.hg38)` in R first. If that fails, the genome package is missing: run the Step 4 command again. |
| `findMacs2()` says `Could Not Find Macs2!` | Start R from the activated environment (so that `macs2` is on your PATH). Check in the terminal with `macs2 --version`. If it is missing, run `mamba install -c conda-forge -c bioconda macs2` (with `CONDA_SUBDIR=osx-64` in front if Step 4 told you so). |
| Something is broken and you made the backup in Step 2 | Run `conda activate single-cell-backup`, which is your environment as it was before Step 4. |
