

process LOFREQ_CALL_PARALLEL {
    tag         "$sample_id"
    label       "process_medium"
    publishDir  "${params.outdir}/${sample_id}/lofreq", mode: 'copy'
    conda       "bioconda::lofreq"
    container   "nanozoo/lofreq:2.1.5--229539a"
    
    input:
    path(genome)
    path(fai)
    tuple val(sample_id), path(indelqual_bam_file)
    tuple val(sample_id), path(indelqual_bam_index_file)

    output:
    tuple val(sample_id), path("${sample_id}.lofreq.vcf"), emit: lofreq_indelqual_vcf

    script:
    """
        lofreq call-parallel \
          --pp-threads 4 \
          -f ${genome} \
          -o ${sample_id}.lofreq.vcf \
          --call-indels \
          --min-cov 20 \
          --max-depth 1000000 \
          --min-bq 30 \
          --min-alt-bq 30 \
          --sig 0.01 \
          --bonf dynamic \
          --no-default-filter \
          ${indelqual_bam_file}
    """
}