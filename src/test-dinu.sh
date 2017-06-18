#$ -cwd -V
#$ -l h_rt=48:00:00
#$ -m be
#$ -l h_vmem=24G
#x$ -pe smp 9
#x$ -l node_type=16core-256G

module add java
module add python
module add python-libs

LIBS=marmot-2015-06-26.jar:mallet.jar:JSAP-2.1.jar
D=/nobackup/smlss/wiki

#cd $1

#cut -f 1 $1-$2-train.dic >$1-$3
#cut -f 2 $3 >$2-$3
#java -cp $LIBS chipmunk.segmenter.cmd.Segment\
#      --model-file $1.chipmunk.srl\
#      --input-file $1-$3.wl1\
#      --output-file $1-$3.chipmunk1
#
#java -cp $LIBS chipmunk.segmenter.cmd.Segment\
#      --model-file $2.chipmunk.srl\
#      --input-file $2-$3.wl1\
#      --output-file $2-$3.chipmunk1
#
#paste <(

#time python train_tm.py -o $1-$2-tm $1-$2-train.dic $1-100-skip.dat $2-100-skip.dat

#echo "Testing standard NN retrieval (baseline)"
#python3 test_tm.py $1-$2-tm.txt data/OPUS_en_it_europarl_test.txt data/EN.200K.cbow1_wind5_hs0_neg10_size300_smpl1e-05.txt data/IT.200K.cbow1_wind5_hs0_neg10_size300_smpl1e-05.txt

echo "Testing GC retrieval with 500 aditional elements"
time python test_tm.py -c 500 $1-$2-tm.txt $1-$2-test.dic $1-100-skip.dat.gz $2-100-skip.dat.gz >$1-$2.res





