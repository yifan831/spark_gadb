errorLog="spark_bedtools_comparison.error_log.re_run_no_homer"
>${errorLog}
resultFile="spark_bedtools_comparison.results.txt.re_run_no_homer"
>${resultFile}


#find /mnt/data/SPARK_GDM/spark-gadb/inferno_output_all_GADB -wholename '*track_list/out.tsv' | \
#cat tracks_to_run.gadb.track_lists.txt.unfinished | \
cat tracks_to_run.gadb.track_lists.no_Homer.txt | \
	while read trackList; do
		echo "Running Bedtools on ${trackList}"
		sparkOut="`dirname ${trackList}`/../overlaps/bed/out.bed"
		dataSource="`dirname ${trackList}`"
		dataSource=${dataSource%%/track_list}
		dataSource=${dataSource##*/}
		bedtoolsOutDir="/mnt/data/bedtools_out_IGAP_all_GADB/${dataSource}"
		mkdir -p "${bedtoolsOutDir}"
		bedtoolsOut="${bedtoolsOutDir}/concat_bedtools_out.txt"
		bash bedtools_filelist_with_concat.sh ${trackList} > ${bedtoolsOut}
		# compare
		comparisonResult="mismatch"
		if ! cmp -s <(sort ${sparkOut}) <(sort ${bedtoolsOut}); then
			echo "Bedtools ${bedtoolsOut} and Spark ${sparkOut} do no match!" | tee -a ${errorLog}
		else
			#echo "Bedtools ${bedtoolsOut} and Spark ${sparkOut} match!"
			comparisonResult="match"
		fi
        echo -e "${sparkOut}\t${bedtoolsOut}\t${comparisonResult}" | tee -a ${resultFile}
	done
