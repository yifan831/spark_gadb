fileList=${1:-tracks_to_run.inferno.txt}
gadbDIR="/mnt/data2/GADB"
inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed"
OUTDIR="/mnt/data/bedtools_out_IGAP_inferno_track_set"
runtimeOut="${OUTDIR}/running_time_bedtools_IGAP_inferno_track_set.txt"
OUTDIR="/mnt/data/bedtools_out_roadmap_sort"
runtimeOut="${OUTDIR}/running_time_bedtools_roadmap_sort"
OUTDIR="/mnt/data/bedtools_out_gtex"
runtimeOut="${OUTDIR}/running_time_bedtools_gtex"
OUTDIR="/mnt/data/bedtools_out_IGAP_all_GADB"
runtimeOut="${OUTDIR}/running_time_bedtools_all_GADB"

BEDTOOLS=$(command -v bedtools)
if [ ! -x ${BEDTOOLS} ]; then
  echo "bedtools not found."
  exit 1
fi

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
cat ${fileList} | \
	while read track; do
		trackDIR=$( dirname "${track}" )
		trackName=$( basename "${track}" )
		bedtoolsOutDIR="${OUTDIR}/${trackDIR##${gadbDIR}/}"
		mkdir -p "${bedtoolsOutDIR}"
		bedtoolsOut="${bedtoolsOutDIR}/${trackName}.bedtools_out.txt"
		echo "${bedtoolsOut}"
		startTime=$(date +%s)
		${BEDTOOLS} intersect -a "${inputBED}" -b "${track}" -wo > "${bedtoolsOut}"
		endTime=$(date +%s.%N)
		runTime=$( echo "${endTime} - ${startTime}" | bc -l )
		echo -e "${track}\t${runTime}\t${trackDIR}" | tee -a ${runtimeOut}
	done
