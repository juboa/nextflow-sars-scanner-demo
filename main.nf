
params.genome = "$projectDir/test/NC_045512.2.fasta"
params.input = "$projectDir/test/*_{1,2}.fastq.gz"
params.outdir = "test_output/"

params.arctic_bed_file = "$projectDir/test/ARTIC_nCoV-2019_v4.bed"
params.nextclade_db = "$projectDir/test/nextclade_sars2_dataset"

include {BOWTIE2_INDEX} from './modules/bowtie2_index'
include {FASTP_TRIMM} from './modules/fastp_trimm'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {IVAR_TRIMM} from './modules/ivar_trimm'
include {LOFREQ_INDELQUAL} from './modules/lofreq_indelqual'
include {LOFREQ_CALL_PARALLEL} from './modules/lofreq_call_parallel'
include {LOFREQ_FILTER} from './modules/lofreq_filter'
include {SAMTOOLS_FAIDX} from './modules/samtools_faidx'
include {SNPEFF} from './modules/snpeff'


include {LOFREQ_FILTER_MAJORITY} from './modules/lofreq_filter_majority'
include {BEDTOOLS_LOWCOV_MASK} from './modules/bedtools_lowcov_mask'
include {BCFTOOLS_CONSENSUS} from './modules/bcftools_consensus'
include {PANGOLIN_ASSIGN} from './modules/pangolin_assign'
include {NEXTCLADE_ASSIGN} from './modules/nextclade_assign'


workflow {

    genome_ch = Channel.value(file(params.genome))
    reads_ch = Channel.fromFilePairs(params.input, checkIfExists: true)

    //reads_ch.view { "Found pair: $it" }

    arctic_bed_ch = Channel.value(file(params.arctic_bed_file))
    nextclade_db_ch = Channel.value(file(params.nextclade_db))

    // Phase 1 : prepare index and align reads
    index_out = BOWTIE2_INDEX(genome_ch)
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)
    fastp_ch = FASTP_TRIMM(reads_ch)
    bowtie_out = BOWTIE2_ALIGN(index_out.collect(), fastp_ch.trimmed_reads)
    samtools_ch = SAMTOOLS_SORT(bowtie_out.sam_file)


    // Phase 2 : filtration and mutations call
    ivar_ch = IVAR_TRIMM(arctic_bed_ch, samtools_ch.sorted_bam)
    lofreq_indelqual_ch = LOFREQ_INDELQUAL(genome_ch, ivar_ch.ivar_trim_bam)
    lofreq_cp_ch = LOFREQ_CALL_PARALLEL(genome_ch,faidx_ch.collect(), lofreq_indelqual_ch.lofreq_indelqual_sorted_bam, lofreq_indelqual_ch.lofreq_indelqual_sorted_bam_index)
    lofreq_filter_out = LOFREQ_FILTER(lofreq_cp_ch.lofreq_indelqual_vcf)
    snpeff_out = SNPEFF(genome_ch, lofreq_filter_out.lofreq_filter_vcf)


    // Phase 3 : Consensus genome build and lineage assignation
    
    lofreq_filter_majority_out = LOFREQ_FILTER_MAJORITY(snpeff_out.snpeff_vcf)
    
    bedtools_lowcov_mask = BEDTOOLS_LOWCOV_MASK(lofreq_indelqual_ch.lofreq_indelqual_sorted_bam)

    consensus_fasta = BCFTOOLS_CONSENSUS(genome_ch, lofreq_filter_majority_out.lofreq_majority_vcf_gz, bedtools_lowcov_mask.bedtools_lowcov_mask)

    PANGOLIN_ASSIGN(consensus_fasta.consensus_fasta)
    NEXTCLADE_ASSIGN(consensus_fasta.consensus_fasta, nextclade_db_ch)

    // Phase 4 : Results aggregation and visualization
}

