
gadbDIR="/mnt/data2/GADB"

inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed"
OUTDIR="/mnt/data/giggle_out_parallelized_GADB"
runtimeOut="${OUTDIR}/running_time_giggle_parallelized_GADB.txt"

inputBED="/mnt/data/datasets/sv_intervals/collapsed_sv_scalpel.bed"
OUTDIR="/mnt/data/giggle_out_parallelized_GADB_sv_scalpel"
runtimeOut="${OUTDIR}/running_time_giggle_parallelized_GADB_sv_scalpel.txt"

inputBED="/mnt/data/datasets/sv_intervals/collapsed_sv_parliament.bed"
OUTDIR="/mnt/data/giggle_out_parallelized_GADB_sv_parliament"
runtimeOut="${OUTDIR}/running_time_giggle_parallelized_GADB_sv_parliament.txt"

inputBED="/mnt/data/datasets/sv_intervals/collapsed_sv_parliament.bed"
OUTDIR="/mnt/data/giggle_out_parallelized_GADB_sv_parliament_96cores"
runtimeOut="${OUTDIR}/running_time_giggle_parallelized_GADB_sv_parliament_96cores.txt"

numPartitions=16
numPartitions=96

GIGGLE=$(command -v giggle)
if [ ! -x ${GIGGLE} ]; then
  echo "giggle not found."
  exit 1
fi

BGZIP=$(command -v bgzip)
if [ ! -x ${BGZIP} ]; then
  echo "bgzip not found."
  exit 1
fi



split -da 4 -l $(( `wc -l < ${inputBED}`/${numPartitions} )) ${inputBED} ${inputBED%.bed}.part --additional-suffix=".bed" 

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
find "${gadbDIR}" -iname '*giggle_index*' -type d | \
	while read indexDIR; do
		# iterate over input partitions
		echo "${indexDIR}"
 	    giggleOutDIR="${OUTDIR}/${indexDIR##${gadbDIR}/}"
		mkdir -p "${giggleOutDIR}"
		startTime=$(date +%s.%N)
		for inputPart in ${inputBED%.bed}.part*.bed; do
			part=${inputPart%.bed}
			part=${part##*.}
			giggleOut="${giggleOutDIR}/giggle_out.${part}.txt"
			echo "${giggleOut}"
			echo "inputPart=${inputPart}"
            echo "bgzip=${BGZIP}"
            ${BGZIP} -c "${inputPart}" > "${inputPart}.gz"
			$GIGGLE search -i "${indexDIR}" -q "${inputPart}.gz" -v > "${giggleOut}" &
		done
		wait
		endTime=$(date +%s.%N)
		runTime=$( echo "${endTime} - ${startTime}" | bc -l )
		echo -e "${indexDIR}\t${runTime}" | tee -a ${runtimeOut}
	done
