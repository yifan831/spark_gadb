# make GTEx file list for Bedtools
find /mnt/data/gtex -iname '*.bed.gz' > gtex.file_list

# run Bedtools for each track
bash bedtools_run_time_filelist.sh /mnt/data/gtex/gtex.file_list

# collect Bedtools outputs
bash collect_bedtools_outputs.sh /mnt/data/bedtools_out_gtex > /mnt/data/gtex/gtex_IGAP.bedtools_output.txt

# create giggle index
giggle index -i "`pwd`/gtex_sort/*.bed.gz" -o gtex_sort_nos_index

# add query columns in front of every overlap line
awk 'BEGIN{FS="\t";OFS="\t"}{if ($1~/^##/) {query=$0;gsub(/^##/,"",query)} else {print query, $0}}' gtex_nos_IGAP.giggle_output.txt > gtex_nos_IGAP.giggle_output.with_query.txt

# print wrong (FP) matches
awk 'BEGIN{FS="\t"}{if (($1!=$11) || ($2+1>$13) || ($3<$12+1)) print;}' gtex_nos_IGAP.giggle_output.with_query.txt > gtex_nos_IGAP.giggle_output.with_query.coordinate_mismatch.txt

# print correct matches
awk 'BEGIN{FS="\t"}{if (($1!=$11) || ($2+1>$13) || ($3<$12+1)) next; else print;}' gtex_nos_IGAP.giggle_output.with_query.txt > gtex_nos_IGAP.giggle_output.with_query.coordinate_match.txt

# unique query intervals with overlaps as reported by Giggle
cut -f1-3 gtex_nos_IGAP.giggle_output.with_query.coordinate_match.txt | sort -u > tmp.g

# unique query intervals with overlaps as reported by Bedtools
cut -f1-3 gtex_IGAP.bedtools_output.txt | sort -u > tmp.b

# print false negatives (FNs), i.e. query intervals reported by Bedtools, but not by Giggle:
comm -2 -3 tmp.b tmp.g
