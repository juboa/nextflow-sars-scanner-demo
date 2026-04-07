

process LOFREQ_FILTER {
	tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/lofreq", mode: 'copy'
    conda "bioconda::lofreq"
    
    input:
    tuple val(sample_id), path(lofreq_vcf)

    output:
    tuple val(sample_id), path("${sample_id}.lofreq.filtered.vcf"), emit: lofreq_filter_vcf

    script:
    """
        lofreq filter \
          -i ${lofreq_vcf} \
          -o ${sample_id}.lofreq.filtered.vcf \
          --af-min 0.05 \
          --cov-min 20 \
          --sb-incl
         
    """
}