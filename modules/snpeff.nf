


process SNPEFF {
	tag "$sample_id"
    publishDir "${params.outdir}/snpEFF", mode: 'copy'
    conda "bioconda::snpeff"
    
    input:
    path(genome)
    tuple val(sample_id), path(lofreq_filter_vcf)

    output:
    tuple val(sample_id), path("${sample_id}.snpeff.vcf"), emit: snpeff_vcf

    script:
    """
	    snpEff download NC_045512.2
        snpEff eff \
          -nodownload \
          -no-intergenic \
          -no-downstream \
          -no-upstream \
          -noStats \
          ${genome.baseName} \
          ${lofreq_filter_vcf} \
        > ${sample_id}.snpeff.vcf
    """
}