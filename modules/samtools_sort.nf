
process SAMTOOLS_SORT {
    tag "$sample_id"
    publishDir "${params.outdir}/alignment", mode: 'copy'
    conda "bioconda::samtools"
    
    input:
    tuple val(sample_id), path(sam_file)

    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: sorted_bam
    tuple val(sample_id), path("${sample_id}.bam.bai"), emit: sorted_bam_index

    script:
    """
     samtools sort ${sam_file} -o ${sample_id}.bam
     samtools index ${sample_id}.bam
    """
}

