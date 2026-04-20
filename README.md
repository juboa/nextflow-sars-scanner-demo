# nextflow-sars-scanner-demo
> A Nextflow-based pipeline for scanning SARS-CoV-2 genomic data and identifying variants.

## Overview

This pipeline automates the analysis of paired-end SARS-CoV-2 FASTQ data. Given raw sequencing reads, it will:

1. **Trim** low-quality reads and adapters
2. **Align** reads to the SARS-CoV-2 reference genome
3. **Call variants** from the aligned reads
4. **Assign lineages**

---

## Prerequisites

Ensure the following tools are installed and available on your `PATH` before running the pipeline:

| Tool | Version | Install |
|---|---|---|
| Nextflow | ≥ 22.10.0 | [nextflow.io](https://www.nextflow.io/docs/latest/install.html) |
| Nextclade | ≥ 3.0.0 | [docs.nextstrain.org](https://docs.nextstrain.org/projects/nextclade/en/stable/user/installation.html) |
| micromamba | ≥ 1.0.0 | [mamba.readthedocs.io](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) |

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/juboa/nextflow-sars-scanner-demo
cd nextflow-sars-scanner-demo
```

### 2. Download the Nextclade database

This fetches the reference dataset required for clade assignment and variant annotation:

```bash
nextclade dataset get --name sars-cov-2 --output-dir nextclade_sars2_dataset
```

### Step 3 — Download the SARS-CoV-2 reference
```bash
wget https://www.ebi.ac.uk/ena/browser/api/fasta/MN908947.3?download=true -O NC_045512.2.fasta
sed -i '1s/^>.*/>NC_045512.2/' NC_045512.2.fasta
```

---

## Usage

### Step 1 — Prepare your samples

The following samples are from the [SARS-CoV-2 Variant Discovery Tutorial](https://training.galaxyproject.org/training-material/topics/variant-analysis/tutorials/sars-cov-2-variant-discovery/tutorial.html) :

```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/002/SRR17054502/SRR17054502_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/002/SRR17054502/SRR17054502_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/003/SRR17054503/SRR17054503_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/003/SRR17054503/SRR17054503_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/004/SRR17054504/SRR17054504_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/004/SRR17054504/SRR17054504_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/005/SRR17054505/SRR17054505_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/005/SRR17054505/SRR17054505_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/006/SRR17054506/SRR17054506_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/006/SRR17054506/SRR17054506_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/007/SRR17054507/SRR17054507_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/007/SRR17054507/SRR17054507_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/008/SRR17054508/SRR17054508_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/008/SRR17054508/SRR17054508_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/009/SRR17054509/SRR17054509_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/009/SRR17054509/SRR17054509_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/010/SRR17054510/SRR17054510_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/010/SRR17054510/SRR17054510_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/033/SRR17051933/SRR17051933_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/033/SRR17051933/SRR17051933_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/034/SRR17051934/SRR17051934_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/034/SRR17051934/SRR17051934_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/035/SRR17051935/SRR17051935_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/035/SRR17051935/SRR17051935_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/036/SRR17051936/SRR17051936_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/036/SRR17051936/SRR17051936_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/037/SRR17051937/SRR17051937_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/037/SRR17051937/SRR17051937_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/038/SRR17051938/SRR17051938_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/038/SRR17051938/SRR17051938_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/039/SRR17051939/SRR17051939_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/039/SRR17051939/SRR17051939_2.fastq.gz

```


### Step 2 — Run the pipeline

```bash
nextflow run main.nf \
  -profile micromamba \
  --input "samples/*_{1,2}.fastq.gz" \
  --outdir results
```

---

## Credits

This pipeline is largely based on the work presented in  [SARS-CoV-2 Variant Discovery Tutorial](https://training.galaxyproject.org/training-material/topics/variant-analysis/tutorials/sars-cov-2-variant-discovery/tutorial.html) , with some modifications to suit this demonstration.
* **SARS-CoV-2 Variant Discovery Tutorial** – Wolfgang Maier, Bérénice Batut, et al. [Galaxy Training Materials](https://training.galaxyproject.org/training-material/topics/variant-analysis/tutorials/sars-cov-2-variant-discovery/tutorial.html) (Accessed April 06, 2026).
* **Galaxy Training: A Powerful Framework for Teaching!** – Hiltemann, Saskia, Rasche, Helena et al. (2023). *PLOS Computational Biology*. [10.1371/journal.pcbi.1010752](https://doi.org/10.1371/journal.pcbi.1010752)
* **Community-Driven Data Analysis Training for Biology** – Batut et al. (2018). *Cell Systems*. [10.1016/j.cels.2018.05.012](https://doi.org/10.1016/j.cels.2018.05.012)
---
