
process PANGOLIN_ASSIGN {
	tag 		"$sample_id"
    publishDir 	"${params.outdir}/${sample_id}/pangolin", mode: 'copy'
    conda 		"bioconda::pangolin"
    container	"staphb/pangolin"

    input:
    tuple val(sample_id), path(consensus_fasta)

    output:
    tuple val(sample_id), path("${sample_id}.pangolin.csv"), emit: pangolin

	script:
	"""
		pangolin ${consensus_fasta} --outfile ${sample_id}.pangolin.csv --threads 4
	"""
}

