# find . -iname "*.bed.gz" | while read f; do echo "${f}"; gunzip -c "${f}" | LC_ALL=C sort -k1,1 -k2,2n -k3,3n | bgzip -c > "${f/.bed.gz/.lc_all_c_sorted.bed.gz}"; done
find . -iname "*.bed.gz" | \
  while read f; do
    echo "${f}"
    gunzip -c "${f}" | LC_ALL=C sort -k1,1 -k2,2n -k3,3n | bgzip -c > "${f/.bed.gz/.lc_all_c_sorted.bed.gz}"
	rm "${f}"
done
