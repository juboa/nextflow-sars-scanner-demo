
include {BOWTIE2_INDEX}     from './modules/bowtie2_index'
include {SAMTOOLS_FAIDX}    from './modules/samtools_faidx'
include {FASTP_TRIMM}       from './modules/fastp_trimm'
include {BOWTIE2_ALIGN}     from './modules/bowtie2_align'
include {SAMTOOLS_SORT}     from './modules/samtools_sort'

include {IVAR_TRIMM}            from './modules/ivar_trimm'
include {LOFREQ_INDELQUAL}      from './modules/lofreq_indelqual'
include {LOFREQ_CALL_PARALLEL}  from './modules/lofreq_call_parallel'
include {LOFREQ_FILTER}         from './modules/lofreq_filter'
include {SNPEFF}                from './modules/snpeff'

include {LOFREQ_FILTER_MAJORITY} from './modules/lofreq_filter_majority'
include {BEDTOOLS_LOWCOV_MASK}   from './modules/bedtools_lowcov_mask'
include {BCFTOOLS_CONSENSUS}     from './modules/bcftools_consensus'
include {PANGOLIN_ASSIGN}        from './modules/pangolin_assign'
include {NEXTCLADE_ASSIGN}       from './modules/nextclade_assign'



workflow ALIGN {
    take:
    genome_ch
    reads_ch

    main:
    index_ch = BOWTIE2_INDEX(genome_ch)
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)
    fastp_ch = FASTP_TRIMM(reads_ch)
    bowtie_ch = BOWTIE2_ALIGN(index_ch.collect(), fastp_ch.trimmed_reads)
    sort_ch = SAMTOOLS_SORT(bowtie_ch.sam_file)

    emit:
    sorted_bam = sort_ch.sorted_bam
    sorted_bam_index = sort_ch.sorted_bam_index
    fai = faidx_ch.fai
}


workflow VARIANT_CALL {
    take:
    genome_ch
    fai_ch
    sorted_bam_ch
    arctic_bed_ch

    main:
    ivar_ch      = IVAR_TRIMM(arctic_bed_ch, sorted_bam_ch)
    indelqual_ch = LOFREQ_INDELQUAL(genome_ch, ivar_ch.ivar_trim_bam)
    lofreq_ch = LOFREQ_CALL_PARALLEL(genome_ch, fai_ch.collect(), indelqual_ch.lofreq_indelqual_sorted_bam, indelqual_ch.lofreq_indelqual_sorted_bam_index)
    filter_ch = LOFREQ_FILTER(lofreq_ch.lofreq_indelqual_vcf)
    snpeff_ch = SNPEFF(genome_ch, filter_ch.lofreq_filter_vcf)

    emit:
    snpeff_vcf = snpeff_ch.snpeff_vcf
    indelqual_sorted_bam = indelqual_ch.lofreq_indelqual_sorted_bam
}


workflow CONSENSUS_LINEAGE {
    take:
    genome_ch
    snpeff_vcf_ch
    indelqual_sorted_bam
    nextclade_db_ch

    main:
    majority_ch = LOFREQ_FILTER_MAJORITY(snpeff_vcf_ch)
    lowcov_ch   = BEDTOOLS_LOWCOV_MASK(indelqual_sorted_bam)
    consensus_ch = BCFTOOLS_CONSENSUS(genome_ch, majority_ch.lofreq_majority_vcf_gz, lowcov_ch.bedtools_lowcov_mask)

    PANGOLIN_ASSIGN(consensus_ch.consensus_fasta)
    NEXTCLADE_ASSIGN(consensus_ch.consensus_fasta, nextclade_db_ch)

}


workflow {

    genome_ch = Channel.value(file(params.genome))
    reads_ch = Channel.fromFilePairs(params.input, checkIfExists: true)

    arctic_bed_ch = Channel.value(file(params.arctic_bed_file))
    nextclade_db_ch = Channel.value(file(params.nextclade_db))
    
    ALIGN(genome_ch, reads_ch)

    VARIANT_CALL(
        genome_ch,
        ALIGN.out.fai,
        ALIGN.out.sorted_bam,
        arctic_bed_ch
    )

    CONSENSUS_LINEAGE(
        genome_ch,
        VARIANT_CALL.out.snpeff_vcf,
        VARIANT_CALL.out.indelqual_sorted_bam,
        nextclade_db_ch
    )

}

