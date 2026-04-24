
process FASTP_TRIMM {
    tag         "$sample_id"
    label       "process_medium"
    publishDir  "${params.outdir}/${sample_id}/fastp", mode: 'copy'
    conda       "bioconda::fastp"
    container   "staphb/fastp"

    
    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_{1,2}.fastq.gz"), emit: trimmed_reads
    path "*"

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${sample_id}_trimmed_1.fastq.gz  -O ${sample_id}_trimmed_2.fastq.gz
    """
}