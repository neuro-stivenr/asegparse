# asegparse

## Purpose

This tools works with recon-all output from FreeSurfer ecosystem.
It converts subj/stats/aseg.stats into more usable data format that outputs to subj/output/asegstats_{data.csv, meta.json}.

## System Dependencies

1. [julia](https://julialang.org/downloads/)
2. [make](https://ftp.gnu.org/gnu/make/) # optional: simply run the commands in Makefile under "asegparse"

# Installation

```bash
git clone https://github.com/umich-stivenr/asegparse
cd asegparse
make # alternatively, follow commands inside Makefile
```

# Usage

```bash
cd asegparse
./asegparse $SUBJECTS_DIR/{subj} # where subj is replaced with subject of interest
ls $SUBJECTS_DIR/{subj}/output # to see output files
```
