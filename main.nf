$HOSTNAME = ""
params.outdir = 'results'  

$HOSTNAME = "default"
params.DOWNDIR = (params.DOWNDIR) ? params.DOWNDIR : ""
//* params.genome_build =  ""  //* @dropdown @options:"human_hg19, human_hg38, macaque_macFas5, rat_rn6, rat_rn6ens, mousetest_mm10, custom"
//* params.run_StringTie =  "yes"  //* @dropdown @options:"yes","no" @show_settings:"StringTie"


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
    $TIME = 240
    $CPU  = 1
    $MEMORY = 32 
    $QUEUE = "short"
}
if (params.genome_build && $HOSTNAME){
    params.gtf ="${_share}/${_species}/${_build}/ucsc.gtf"
}
if ($HOSTNAME){
    params.gtf2bed_path = "/usr/local/bin/dolphin-tools/gtf2bed"
    $CPU  = 1
    $MEMORY = 10
}
//*


if (!params.bam){params.bam = ""} 

Channel.fromPath(params.bam, type: 'any').map{ file -> tuple(file.baseName, file) }.set{g_1_bam_file_g_6}


process StringTie {

input:
 set val(name), file(bam) from g_1_bam_file_g_6

output:
 file "*.gtf"  into g_6_gtfFile_g_7

container "dolphinnext/stringtie_module:2.0"

when:
(params.run_StringTie && (params.run_StringTie == "yes")) || !params.run_StringTie

script:
stringtie_parameters = params.StringTie.stringtie_parameters
paramPrefix = stringtie_parameters.replaceAll(" -","_").replaceAll(" ","").replaceAll("-","")
"""
stringtie ${bam} ${stringtie_parameters} -o ${name}_${paramPrefix}.StringTie.gtf
"""

}

//* params.gtf =  ""  //* @input 

process stringtieMergeGtf {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /${gtfname}.StringTie.sorted.gtf$/) "stringtieMergedGtf/$filename"
}

input:
 file gtfs from g_6_gtfFile_g_7.collect()

output:
 file "${gtfname}.StringTie.sorted.gtf"  into g_7_gtfFile
 val "${baseDir}/work/tmp/${gtfname}.StringTie.sorted.gtf"  into g_7_gtfFilePath

container "dolphinnext/stringtie_module:2.0"

script:
gtfname = params.gtf.substring(params.gtf.lastIndexOf('/')+1,params.gtf.lastIndexOf('.'))

"""
# 0. Save file names of all Stringtie.gtf files in gtflist.txt
ls ${gtfs} > gtflist.txt

# 1. Merge .gtf files
stringtie -F 0 -T 0 -f 0 --merge gtflist.txt -G ${params.gtf} -o ${gtfname}.StringTie.gtf

# 4. Sort the merged .gtf file
(grep "^#" ${gtfname}.StringTie.gtf; grep -v "^#" ${gtfname}.StringTie.gtf | sort -T '.' -k1,1 -k4,4n) > ${gtfname}.StringTie.sorted.gtf

# 5. Remove [Merged GTF]
rm ${gtfname}.StringTie.gtf

# 6. cp to work/tmp
mkdir -p ${baseDir}/work/tmp
cp ${gtfname}.StringTie.sorted.gtf ${baseDir}/work/tmp/${gtfname}.StringTie.sorted.gtf
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
