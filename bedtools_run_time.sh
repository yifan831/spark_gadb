
gadbDIR="/mnt/data2/GADB"
inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed.gz"
OUTDIR="/mnt/data/bedtools_out_GADB"
runtimeOut="${OUTDIR}/running_time_bedtools_GADB.txt"

BEDTOOLS=$(command -v bedtools)
if [ ! -x ${BEDTOOLS} ]; then
  echo "bedtools not found."
  exit 1
fi

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
find "${gadbDIR}" -iname '*.bed.gz' -type f | \
	while read track; do
		trackDIR=$( dirname "${track}" )
		trackName=$( basename "${track}" )
		bedtoolsOutDIR="${OUTDIR}/${trackDIR##${gadbDIR}/}"
		mkdir -p "${bedtoolsOutDIR}"
		bedtoolsOut="${bedtoolsOutDIR}/${trackName}.bedtools_out.txt"
		echo "${bedtoolsOut}"
		startTime=$(date +%s)
		${BEDTOOLS} intersect -a "${inputBED}" -b "${track}" -wo > "${bedtoolsOut}"
		endTime=$(date +%s)
		runTime=$(( endTime - startTime ))
		echo -e "${trackDIR}\t${runTime}\t${trackName}" | tee -a ${runtimeOut}
	done
