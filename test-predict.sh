# 1 language1
# 2 language2
# 3 vector length
# 4 name of Rdata map
# 5 test file
# 6 number of suggestions to output
#$ -cwd -V
#$ -l h_rt=1:00:00
#$ -m be
#$ -l h_vmem=3G
#For multithreading -pe smp 9
#For large memory: -l node_type=16core-256G

module add leeds
module add R/3.2.2

D=src #~/bilingual

   echo "Applying bitransforms $1-$2"
   Rscript $D/printbivec.R $1-$3-skip.dat.xz $2-$3-skip.dat.xz $4 $5 $6
   module del python
   module add python/3.3.2
   module add python-libs/2.4.0
   python3 $D/weighted-lev.py <$1-$3-$6-$5 $1-$2.cost $1-$2-rev.cost | sed 's/"//g;s/ /\t/g' | sort | sort -nsrk3 >$1-$3-$6-$5-test.out


