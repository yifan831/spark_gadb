BEDTOOLSDIR=${1:-.}
find "${BEDTOOLSDIR}" -iname '*.bedtools_out.txt' | while read f; do
#bgzname=$(echo "${f}" | awk '{gsub("'${BEDTOOLSDIR}'",""); gsub (/.bedtools_out.txt$/,""); print;}')
bgzname=$(echo "${f}" | awk '{gsub (/.bedtools_out.txt$/,""); print;}')
awk 'BEGIN{bgzname="'${bgzname}'"}
     {
	   gsub(/[[:space:]][0-9]+$/, ""); # remove overlap field
	   print $0"\t"bgzname
     }' "${f}"
done #> roadmap_sort_IGAP.bedtools_output.txt
