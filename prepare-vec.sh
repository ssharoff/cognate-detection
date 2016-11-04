# 1 language1
# 2 vector length
# 3 dic to filter
#$ -cwd -V
#$ -l h_rt=48:00:00
#$ -m be
#$ -l h_vmem=1G

D=src #~/bilingual


if [ ! -f $1-$2-skip.dat.xz ] 
then
   xzcat $1-$2-skip.vec.xz | $D/clean-vectors.sh $3 | xz >$1-$2-skip.dat.xz
fi
