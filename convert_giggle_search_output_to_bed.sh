# add query line in front of each overlap line
GIGGLEIN=$1
awk 'BEGIN{FS="\t";OFS="\t"}
     {
	   if ($1~/^#/)
	   {
		  query=$0;
		  gsub(/^##/,"",query);
	   }
       else
	   {
		  # check boundary/overlap condition
		  n=split(query, a, "\t")
		  qChr=a[1]; qChrStart=a[2]+1; qChrEnd=a[3]
          n=split($0, a, "\t")
		  chr=a[1]; chrStart=a[2]+1; chrEnd=a[3];
		  if (chr == qChr && !(qChrStart > chrEnd || qChrEnd < chrStart))
		    print query, $0;
		  #print query, $0;
	   }
	 }' "${GIGGLEIN}" #roadmap_sort_IGAP.giggle_output.txt > roadmap_sort_IGAP.giggle_output.with_query.txt
