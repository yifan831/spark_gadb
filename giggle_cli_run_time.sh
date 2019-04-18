
gadbDIR="/mnt/data2/GADB"
inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed.gz"
OUTDIR="/mnt/data/giggle_out_GADB"
runtimeOut="${OUTDIR}/running_time_giggle_GADB.txt"

GIGGLE=$(command -v giggle)
if [ ! -x ${GIGGLE} ]; then
  echo "giggle not found."
  exit 1
fi

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
find "${gadbDIR}" -iname '*giggle_index*' -type d | \
	while read indexDIR; do
		echo "${indexDIR}"
		giggleOutDIR="${OUTDIR}/${indexDIR##${gadbDIR}/}"
		mkdir -p "${giggleOutDIR}"
		giggleOut="${giggleOutDIR}/giggle_out.txt"
		echo "${giggleOut}"
		startTime=$(date +%s.%N)
		$GIGGLE search -i "${indexDIR}" -q "${inputBED}" -v > "${giggleOut}"
		endTime=$(date +%s.%N)
		runTime=$( echo "${endTime} - ${startTime}" | bc -l )
		echo -e "${indexDIR}\t${runTime}" | tee -a ${runtimeOut}
	done
