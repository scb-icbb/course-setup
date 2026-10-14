# Single-Cell Bioinformatics: course environment

Conda environment files and build helpers for the scRNA-seq project of the
Single-Cell Bioinformatics course (ICBB, winter semester 2026/27). The step-by-step
instructions are in the setup sheet handed out with the project; this repository
holds the files it refers to.

| File | Use |
|---|---|
| `environment-linux.yml` | Linux, and Windows via WSL2 |
| `environment-mac.yml` | macOS (Intel and Apple Silicon) |
| `README-Windows.md` | How to set up WSL2 on Windows |
| `build-helpers/gdal-config-wrapper` | macOS only: needed to compile `terra` (see the setup sheet) |

## Quick start

```bash
git clone https://github.com/scb-icbb/course-setup.git
cd course-setup
mamba env create -f environment-linux.yml   # or environment-mac.yml
conda activate single-cell
```

Then install the remaining R packages from inside R, as described in the setup
sheet (and in the comments at the end of each environment file).

## Why the pinned versions?

The environment uses **R 4.2 and Seurat 4**, because DoubletFinder does not work
with Seurat 5. Several packages therefore have to be installed in specific
versions:

| Package | Version | Reason |
|---|---|---|
| SeuratWrappers | commit `729c31edf3` (0.3.0) | newer versions need Seurat 5; older ones fail to convert to monocle3 |
| leidenbase | 0.1.37 (CRAN) | v0.1.9 is incompatible with igraph 2.0 |
| monocle3 | [`scb-icbb/monocle3@v1.3.1-igraph2`](https://github.com/scb-icbb/monocle3/tree/v1.3.1-igraph2) | v1.3.1 plus one upstream fix for igraph 2.0; 1.4.x needs BPCells / R 4.4 |

The comments in the environment files explain every pin in detail.

**Do not accept package updates** when R asks during installation
(`Update all/some/none?` → `n`). Updates can replace the pinned versions and
break the environment.
