# https://medium.com/parrot-prediction/partitioning-in-apache-spark-8134ad840b0

df1=spark.createDataFrame([("chr1","brain"),("chr2","lung"),("chr1","brain2"),("chr3","lung3"),("chr2","lung2"), ("chr4","kidney")],["chr","tissue"])
df2=df1.repartitionByRange(4,"chr")
df2=df1.repartitionByRange("chr")
