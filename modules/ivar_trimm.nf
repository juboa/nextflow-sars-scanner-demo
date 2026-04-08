

process IVAR_TRIMM {
	tag 		"$sample_id"
    label       "process_medium"
    publishDir 	"${params.outdir}/${sample_id}/ivar", mode: 'copy'
    conda 		"bioconda::ivar"
    
    input:
    path(arctic_bed)
    tuple val(sample_id), path(bam_file)

    output:
    tuple val(sample_id), path("${sample_id}.ivar.bam"), emit: ivar_trim_bam

    script:
    """
	    ivar trim \
		  -i ${bam_file} \
		  -b ${arctic_bed} \
		  -p ${sample_id}.ivar.bam \
		  -e \
		  -q 0 \
		  -m 30 \
		  -s 4
    """
}