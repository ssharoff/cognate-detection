#the script checks bilingual embeddings across two files
cosine <- function(x,y) {
    (crossprod(x, y) / sqrt(crossprod(x) * crossprod(y)))[1,1]
}

# args=c('../../uk-ru-100-100-darch.Rdata','/corpora/cognates/data/uk-100-skip.dat.xz','/corpora/cognates/data/ru-100-skip.dat.xz','../data/uk-ru-test.dic');

args=commandArgs(trailingOnly=T);
mf=args[1]; # predict model
nsf=args[2]; #new vectors in vsf language
ntf=args[3]; #new vectors in vtf language
tf=args[4]; #test dict
k=10;
if (length(args)>4) {
    k=as.integer(args[5]);
}

print(sprintf("Translating from %s to %s using %s.", nsf, ntf, mf));

library(darch);
load(mf); #v.s and mlp.model

testd=read.table(tf);
test.s=as.character(testd$V1);
test.v=as.character(testd$V2);

vns=read.table(nsf,row.names=1,skip=50);
testv=intersect(rownames(vns),test.s);
vns=vns[testv,];
vns.w=rownames(vns);

vnt=read.table(ntf,row.names=1,skip=50);
vnt.w=rownames(vnt);


vns.new <- scale(vns[testv,], attr(v.s, "scaled:center"), attr(v.s, "scaled:scale"))/6+0.5
vnt.new <- predict(mlp.model,vnt);
rownames(vnt.new) <- rownames(vnt)

#testv=c('deben','reforzar','medios','comunidad','tenga','Presidenta','ustedes','Derechos','posibilidades','ayuda','cierto');
#testv=v[c('white','blue','strong','voice','lack','repair','demand','miss','need','poor'),]

print('Vsub selection:');
print(vns.w);

lsub=matrix('',length(vns.w),k);
rownames(lsub)=vns.w;

for (i in 1:length(vns.w)) {
    v.s=vns.new[i,];
    coslist=vnt.new[,1]; # to copy the names
    for (j in 1:length(vnt.w)) {
        coslist[j]=cosine(v.s,vnt.new[j,]);
    };
    lsub[i,]=names(tail(sort.int(coslist), k));
}

vtn=unlist(strsplit(vtf,'-'))[2];

print(outf <- paste(tf,vtn,'darch',sep='-'));
write.table(lsub,outf);
