

process BCFTOOLS_CONSENSUS {

	  tag "$sample_id"
    publishDir "${params.outdir}/bcftools", mode: 'copy'
    conda "bioconda::bcftools"
    debug true
    
    input:
      path(genome)
      tuple val(sample_id), path(majority_vcf)
      path(low_cov_mask)

    output:
    tuple val(sample_id), path("${sample_id}.consensus.fasta"), emit: consensus_fasta

    script:
    """
      bcftools index -t ${majority_vcf}
    bcftools consensus \
        -f ${genome} \
        -m ${low_cov_mask} \
        -H A \
        ${majority_vcf} \
        > "${sample_id}.consensus.fasta"
    """
    }