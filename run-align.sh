# 1 language1
# 2 language2
# 3 vector length
# 4 number of suggestions to output
#$ -cwd -V
#$ -l h_rt=48:00:00
#$ -m be
#$ -l h_vmem=5G
#For multithreading -pe smp 9
#For large memory: -l node_type=16core-256G

module add leeds
module add R/3.2.2

D=src #~/bilingual
HID=400
ITER=50

./prepare-vec.sh $1 $3 $1.num
./prepare-vec.sh $2 $3 $2.num

if [ ! -s $1-$2-train.dic.$1-$3-skip.dat ] 
then
    echo "Creating $1-$2 pair"
   $D/align-dict.pl -1 $1-$3-skip.dat.xz -2 $2-$3-skip.dat.xz -d $1-$2-train.dic
fi

if [ ! -f $1-$2-$3-$3-darch.Rdata ] 
then
    echo "Creating $1-$2 MLP"
   Rscript $D/align-bi1.R $1-$2-train.dic.$1-$3-skip.dat $1-$2-train.dic.$2-$3-skip.dat $HID $ITER
fi

#if [ ! -s $1-$2-$3-$HID-$4-test.out ]
#then
   echo "Applying bitransforms $1-$2"
   Rscript $D/printbivec.R $1-$3-skip.dat.xz $2-$3-skip.dat.xz $1-$2-$3-$3-darch.Rdata $1-$2-test.dic $4
   module add python/3.3.2
   module add python-libs/2.4.0
   python3 $D/weighted-lev.py <$1-$3-$4-$1-$2-test.dic $1-$2.cost $1-$2-rev.cost >$1-$2-$3-$HID-$4-test.out
#fi

