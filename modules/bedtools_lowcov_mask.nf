

process BEDTOOLS_LOWCOV_MASK {

	tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/bedtools", mode: 'copy'
    conda "bioconda::bedtools"
    
    input:
    tuple val(sample_id), path(bam_file)

    output:
    path("${sample_id}.lowcov_mask.bed"), emit: bedtools_lowcov_mask

    script:
    """
    bedtools genomecov \
      -ibam ${bam_file} \
      -bga | awk '\$4 < 20'  > "${sample_id}.lowcov_mask.bed"
         
    """
}