

process LOFREQ_INDELQUAL {
	tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/lofreq", mode: 'copy'
    conda "bioconda::lofreq bioconda::samtools"
    
    input:
    path(genome)
    tuple val(sample_id), path(ivar_bam_file)

    output:
    tuple val(sample_id), path("${sample_id}.indelqual.bam"), emit: lofreq_indelqual_bam
    tuple val(sample_id), path("${sample_id}.indelqual.sorted.bam"), emit: lofreq_indelqual_sorted_bam
    tuple val(sample_id), path("${sample_id}.indelqual.sorted.bam.bai"), emit: lofreq_indelqual_sorted_bam_index

    script:
    """
		lofreq indelqual \
		  --dindel \
		  -f ${genome} \
		  -o ${sample_id}.indelqual.bam \
		  ${ivar_bam_file}

        samtools sort ${sample_id}.indelqual.bam -o ${sample_id}.indelqual.sorted.bam
        samtools index ${sample_id}.indelqual.sorted.bam
    """
}