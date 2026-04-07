

process NEXTCLADE_ASSIGN {
	
	tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/nextclade", mode: 'copy'
    conda "bioconda::nextclade"

    input:
    	tuple val(sample_id), path(consensus_fasta)
    	path(nextclade_sars2_dataset)

    output:
    	path("output_folder/*"), emit: nextclade

	script:
	"""
		nextclade run --input-dataset ${nextclade_sars2_dataset}  --output-all=output_folder ${consensus_fasta}
	"""
}

