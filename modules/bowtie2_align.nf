
process BOWTIE2_ALIGN {
    tag "$sample_id"
    publishDir "${params.outdir}/alignment", mode: 'copy'
    conda "bioconda::bowtie2 bioconda::samtools"
    
    input:
    tuple val(index_name), path(index_files)
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}.sam"),emit: sam_file

    script:
    """
    bowtie2 -x ${index_name} -1 ${reads[0]} -2 ${reads[1]} -S ${sample_id}.sam
    """
}