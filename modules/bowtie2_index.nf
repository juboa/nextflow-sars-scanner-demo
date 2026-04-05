

process BOWTIE2_INDEX {
	tag "$genome.baseName"
    conda "bioconda::bowtie2"
    
    input:
    path genome

    output:
    tuple val(genome.baseName), path("${genome.baseName}.*.bt2")

    script:
    """
        bowtie2-build ${genome} ${genome.baseName}
    """
}