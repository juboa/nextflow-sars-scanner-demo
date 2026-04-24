
process BEDTOOLS_LOWCOV_MASK {
	  tag         "$sample_id"
    label       "process_medium"
    publishDir  "${params.outdir}/${sample_id}/bedtools", mode: 'copy'
    conda       "bioconda::bedtools"
    container   "biocontainers/bedtools:v2.27.1dfsg-4-deb_cv1"
    
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