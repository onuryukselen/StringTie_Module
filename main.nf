$HOSTNAME = ""
params.outdir = 'results'  

$HOSTNAME = "default"
params.DOWNDIR = (params.DOWNDIR) ? params.DOWNDIR : ""
//* params.genome_build =  ""  //* @dropdown @options:"human_hg19, human_hg38, macaque_macFas5, rat_rn6, rat_rn6ens, mousetest_mm10, custom"
//* params.run_StringTie =  "yes"  //* @dropdown @options:"yes","no" 


def _species;
def _build;
def _share;
//* autofill
if (params.genome_build == "mousetest_mm10"){
    _species = "mousetest"
    _build = "mm10"
} else if (params.genome_build == "human_hg19"){
    _species = "human"
    _build = "hg19"
} else if (params.genome_build == "human_hg38"){
    _species = "human"
    _build = "hg38"
} else if (params.genome_build == "mouse_mm10"){
    _species = "mouse"
    _build = "mm10"
} else if (params.genome_build == "macaque_macFas5"){
    _species = "macaque"
    _build = "macFas5"
} else if (params.genome_build == "rat_rn6"){
    _species = "rat"
    _build = "rn6"
} else if (params.genome_build == "rat_rn6ens"){
    _species = "rat"
    _build = "rn6ens"
}
if ($HOSTNAME == "default"){
    _share = "${params.DOWNDIR}/genome_data"
    $SINGULARITY_IMAGE = "https://galaxyweb.umassmed.edu/pub/dnext_data/singularity/UMMS-Biocore-rna-seq-2.0.simg"
}

if ($HOSTNAME == "fs-bb7510f0"){
    _share = "/mnt/efs/share/genome_data"
    $SINGULARITY_IMAGE = "https://galaxyweb.umassmed.edu/pub/dnext_data/singularity/UMMS-Biocore-rna-seq-2.0.simg"
	$SINGULARITY_OPTIONS = "--bind /mnt"
} else if ($HOSTNAME == "192.168.20.150"){
    _share = "/home/botaoliu/share/genome_data"
    $SINGULARITY_IMAGE = "https://galaxyweb.umassmed.edu/pub/dnext_data/singularity/UMMS-Biocore-rna-seq-2.0.simg"
} else if ($HOSTNAME == "50.228.141.2"){
    _share = "/share/genome_data"
    $SINGULARITY_IMAGE = "https://galaxyweb.umassmed.edu/pub/dnext_data/singularity/UMMS-Biocore-rna-seq-2.0.simg"
    $CPU  = 1
    $MEMORY = 10
} else if ($HOSTNAME == "ghpcc06.umassrc.org"){
    _share = "/share/data/umw_biocore/genome_data"
    $SINGULARITY_IMAGE = "/project/umw_biocore/singularity/UMMS-Biocore-rna-seq-2.0.simg"
    $TIME = 500
    $CPU  = 1
    $MEMORY = 32 
    $QUEUE = "long"
}
if (params.genome_build && $HOSTNAME){
    params.genomeDir ="${_share}/${_species}/${_build}/"
    params.genome ="${_share}/${_species}/${_build}/${_build}.fa"
    params.gtf ="${_share}/${_species}/${_build}/ucsc.gtf"
    params.gff ="${_share}/${_species}/${_build}/genes.gff3"
    params.exon_file  = "${_share}/${_species}/${_build}/exons.txt.gz"
    params.bed_file_genome ="${_share}/${_species}/${_build}/${_build}.bed"
    params.ref_flat ="${_share}/${_species}/${_build}/ref_flat"
    params.genomeSizePath ="${_share}/${_species}/${_build}/${_build}.chrom.sizes"

}
if ($HOSTNAME){
    params.genomeCoverageBed_path = "genomeCoverageBed"
    params.wigToBigWig_path = "wigToBigWig"
    params.pdfbox_path = "/usr/local/bin/dolphin-tools/pdfbox-app-2.0.0-RC2.jar"
    params.gtf2bed_path = "/usr/local/bin/dolphin-tools/gtf2bed"
    $CPU  = 1
    $MEMORY = 10
}
//*





workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
