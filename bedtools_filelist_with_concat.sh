# run Bedtools for each file in the input list
# collect results into one output file by adding file path as the last column
fileList=${1} # input list of files to run Bedtools on; one file (absolute path) per line
inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed"
OUTDIR="/mnt/data/bedtools_out_IGAP_all_GADB"
runtimeOut="${OUTDIR}/running_time_bedtools_all_GADB"

if [ $# -lt 1 ]; then
	echo "USAGE: $0 <file-list-of-tracks>"
	exit 1
fi

BEDTOOLS=$(command -v bedtools)
if [ ! -x ${BEDTOOLS} ]; then
  echo "bedtools not found."
  exit 1
fi

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
cat ${fileList} | \
	while read track; do
		if [[ ! ${track:0:1} = "/" ]]; then
			echo "Skipping line $track. No absolute path found" 1>&2
			continue
		fi
		trackDIR=$( dirname "${track}" )
		trackName=$( basename "${track}" )
		bedtoolsOutDIR="${OUTDIR}/${trackDIR}"
		mkdir -p "${bedtoolsOutDIR}"
		bedtoolsOut="${bedtoolsOutDIR}/${trackName}.bedtools_out.txt"
		startTime=$(date +%s)
		${BEDTOOLS} intersect -a "${inputBED}" -b "${track}" -wo | awk 'BEGIN{FS="\t"; OFS="\t"; absPath="'${track}'"}{$NF=absPath; print;}' 
		endTime=$(date +%s.%N)
		runTime=$( echo "${endTime} - ${startTime}" | bc -l )
		echo -e "${track}\t${runTime}\t${trackDIR}" > "${runtimeOut}"
	done
