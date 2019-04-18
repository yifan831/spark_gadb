
gadbDIR="/mnt/data2/GADB"
inputBED="/mnt/data/GADBtest/IGAP/IGAP.sorted.bed"
numCPUs=$( getconf _NPROCESSORS_ONLN )
numPartitions=${numCPUs:-16}

OUTDIR="/mnt/data/bedtools_out_GADB_parallelized_${numPartitions}"
runtimeOut="${OUTDIR}/running_time_bedtools_GADB_parallized_${numPartitions}.txt"

BEDTOOLS=$(command -v bedtools)
if [ ! -x ${BEDTOOLS} ]; then
  echo "bedtools not found."
  exit 1
fi

# split input and run each partition in parallel
split -da 4 -l $(( `wc -l < ${inputBED}`/${numPartitions} )) ${inputBED} ${inputBED%.bed}.part --additional-suffix=".bed" 

mkdir -p "${OUTDIR}"
>"${runtimeOut}"
find "${gadbDIR}" -iname '*.bed.gz' -type f | \
	while read track; do
		trackDIR=$( dirname "${track}" )
		trackName=$( basename "${track}" )
		startTime=$(date +%s.%N)
		for inputPart in ${inputBED%.bed}.part*.bed; do
			part=${inputPart%.bed}
			part=${part##*.}
		    bedtoolsOutDIR="${OUTDIR}/${trackDIR##${gadbDIR}/}"
			bedtoolsOut="${bedtoolsOutDIR}/${trackName}.${part}.bedtools_out.txt"
			echo "${bedtoolsOut}"
			echo "inputPart=${inputPart}"
			mkdir -p "${bedtoolsOutDIR}"
			${BEDTOOLS} intersect -a "${inputPart}" -b "${track}" -wo > "${bedtoolsOut}" &
		done
		wait
		endTime=$(date +%s.%N)
		runTime=$( echo "${endTime} - ${startTime}" | bc -l )
		echo -e "${trackDIR}\t${runTime}\t${trackName}" | tee -a "${runtimeOut}"
	done
