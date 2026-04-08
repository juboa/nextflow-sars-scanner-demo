
process SAMTOOLS_FAIDX {
	tag     "$genome.baseName"
    conda   "bioconda::samtools"
    
    input:
    path genome

    output:
    path("${genome}.fai"), emit: fai

    script:
    """
        samtools faidx ${genome}
    """
}