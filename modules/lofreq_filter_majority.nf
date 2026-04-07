

process LOFREQ_FILTER_MAJORITY {


	tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/lofreq", mode: 'copy'
    conda "bioconda::lofreq"
    
    input:
    tuple val(sample_id), path(lofreq_vcf)

    output:
    tuple val(sample_id), path("${sample_id}.lofreq.majority.vcf"), emit: lofreq_majority_vcf
    tuple val(sample_id), path("${sample_id}.lofreq.majority.vcf.gz"), emit: lofreq_majority_vcf_gz
    tuple val(sample_id), path("*"), emit: lofreq_majority_vcf_index

    script:
    """
        lofreq filter \
          -i ${lofreq_vcf} \
          -o "${sample_id}.lofreq.majority.vcf" \
          --af-min 0.5

         bgzip -c "${sample_id}.lofreq.majority.vcf" > "${sample_id}.lofreq.majority.vcf.gz"
         bcftools index "${sample_id}.lofreq.majority.vcf.gz"
         
    """
}