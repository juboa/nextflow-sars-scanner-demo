
process SAMTOOLS_SORT {
    tag "$sample_id"
    label "process_medium"
    publishDir "${params.outdir}/${sample_id}/alignment", mode: 'copy'
    conda "bioconda::samtools"
    container   "staphb/samtools"

    input:
    tuple val(sample_id), path(sam_file)

    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: sorted_bam
    tuple val(sample_id), path("${sample_id}.bam.bai"), emit: sorted_bam_index

    script:
    """
     samtools sort ${sam_file} -o ${sample_id}.bam -@ ${task.cpus}
     samtools index ${sample_id}.bam
    """
}

