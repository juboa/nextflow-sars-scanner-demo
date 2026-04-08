

process BOWTIE2_INDEX {
	tag    "$genome.baseName"
    conda   "bioconda::bowtie2"
    
    input:
    path(genome)

    output:
    tuple val(genome.baseName), path("${genome.baseName}.*"), emit: index

    script:
    """
        bowtie2-build ${genome} ${genome.baseName}
    """
}