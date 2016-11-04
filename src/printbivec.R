#the script checks bilingual embeddings across two files
library('RANN')  # for testing the vectors

nncheck <- function(u,usub,k=10) {
    nnv <- nn2(u,usub,k=k,treetype='kd',searchtype='standard');
    apply(nnv$nn.idx,MAR=1,FUN=function (x) rownames(u[x,]))
}

args=commandArgs(trailingOnly=T);
vf=args[1]; #'ru-uk-100-skip-50k.dat'
vf2=args[2]; #'uk-100-skip-50k.dat.xz'
#nrows=as.integer(args[3]);
mf=args[3]; # 'ru.uk.100.50.Rdata' 
tf=args[4]; #'ru-uk-test.dic'
k=30;
if (length(args)>4) {
    k=as.integer(args[5]);
}

#print(sprintf("Translating from %s to %s using %s.", vf, vf2, mf));

library(darch);
load(mf); #v.s and mlp.model

v=read.table(vf,row.names=1,skip=100);
v2=read.table(vf2,row.names=1,skip=100);
testd=read.table(tf);
testv=as.character(testd$V1);
testv2=as.character(testd$V2);

testv=intersect(rownames(v),testv);

print(sprintf("Obtained %d words from %s for mapping %d words from %s using %d entries from %s.", length(v[,1]), vf, length(v2[,1]), vf2, length(testv), tf));


vnew <- scale(v[testv,], attr(v.s, "scaled:center"), attr(v.s, "scaled:scale"))/6+0.5
vnew2 <- predict(mlp.model,v2);
rownames(vnew2) <- rownames(v2)

#testv=c('deben','reforzar','medios','comunidad','tenga','Presidenta','ustedes','Derechos','posibilidades','ayuda','cierto');
#testv=v[c('white','blue','strong','voice','lack','repair','demand','miss','need','poor'),]

print('Vsub selection:');
print(rownames(vnew));

lsub <- nncheck(vnew2,vnew,k=k);

vfn=unlist(strsplit(vf,'-'))[1];
vf2n=unlist(strsplit(vf,'-'))[2];

colnames(lsub) <- rownames(vnew);
print(outf <- paste(vfn,vf2n,k,tf,sep='-'));
write.table(t(lsub),outf);
