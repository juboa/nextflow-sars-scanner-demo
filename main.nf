
params.genome = "$projectDir/test/NC_045512.2.fasta"
params.reads = "$projectDir/test/SRR17054502_{1,2}.fastq.gz"
params.outdir = "test_output/"

include {BOWTIE2_INDEX} from './modules/bowtie2_index'
include {FASTP_TRIMM} from './modules/fastp_trimm'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'


workflow {

    genome_ch = Channel.fromPath(params.genome)
    reads_ch = Channel.fromFilePairs(params.reads)

    index_out = BOWTIE2_INDEX(genome_ch)
    fastp_ch = FASTP_TRIMM(reads_ch)
    bowtie_out = BOWTIE2_ALIGN(index_out.collect(), fastp_ch.trimmed_reads)
    SAMTOOLS_SORT(bowtie_out.sam_file)
}

