#$ -cwd -V
#$ -l h_rt=48:00:00
#x$ -m be
#$ -l h_vmem=24G
#x$ -pe smp 9
#x$ -l node_type=16core-256G

module add java
module add python
module add python-libs

# 1 SL
# 2 TL
# 3 GC
# 4 SKIP
# 5 TopK
# 6 Alpha


K=20
if [ $# -gt 4 ]
then
   K=$5
fi

ALPHA=0.8
if [ $# -gt 5 ]
then
   ALPHA=$6
fi

V=1
if [ $# -gt 6 ]
then
   V=$7
fi

if [ ! -f $1-$2-${4}tm.txt ]
then
    echo "Training tm matrix from $1 to $2"
    time python3 train_tm.py -o $1-$2-${4}tm $1-$2-train.dic $1-100-skip.dat $2-100-skip.dat
fi

#    echo "Testing standard NN retrieval (baseline)"
#    python3 test_tm.py $1-$2-tm.txt $1-$2-train.dic  $1-100-skip.dat $2-100-skip.dat
echo "Testing GC retrieval with $3 aditional elements for $1 to $2 in $K neighbours with $ALPHA"
time python3 test_tm2.py -a $ALPHA -c $3 -m $1-$2-${4}tm.txt -1 $1-100-$4.dat -2 $2-100-$4.dat -l $1-$2.cost -t $K -v $V  $1-$2-test.dic





