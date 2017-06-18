#the script checks bilingual embeddings across two files
cosine <- function(x,y) {
    (crossprod(x, y) / sqrt(crossprod(x) * crossprod(y)))[1,1]
}

# args=c('../data/uk-ru-train.dic.uk-100-skip.dat.xz','../data/uk-ru-train.dic.ru-100-skip.dat.xz','/corpora/cognates/data/uk-100-skip.dat.xz','/corpora/cognates/data/ru-100-skip.dat.xz','../data/uk-ru-test.dic');
args=commandArgs(trailingOnly=T);
vsf=args[1]; 
vtf=args[2];
nsf=args[3]; #new vectors in vsf language
ntf=args[4]; #new vectors in vtf language
tf=args[5]; #dict
k=10;
if (length(args)>5) {
    k=as.integer(args[5]);
}

print(sprintf("Translating from %s to %s for %s and %s using CCA.", vsf, vtf, tf, ntf));


vs=read.table(vsf,row.names=1);
vt=read.table(vtf,row.names=1);

testd=read.table(tf);
test.s=as.character(testd$V1);
test.v=as.character(testd$V2);

vns=read.table(nsf,row.names=1,skip=50);
testv=intersect(rownames(vns),test.s);
vns=vns[testv,];
vns.w=rownames(vns);

vnt=read.table(ntf,row.names=1,skip=50);
vnt.w=rownames(vnt);

print(sprintf("Obtained %d words from %s for mapping %d words from %s using %d entries from %s.", length(vns.w), vsf, length(vnt.w), ntf, length(test.s), tf));

cca.mat=cancor(vs, vt, xcenter=F, ycenter=F);
vns.new=as.matrix(vns) %*% cca.mat$xcoef;
vnt.new=as.matrix(vnt) %*% cca.mat$ycoef;
#vs.new=as.matrix(vs) %*% cca.mat$xcoef;

print('Vsub selection:');
print(rownames(vns.new));

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

print(outf <- paste(tf,vtn,sep='-'));
write.table(lsub,outf);
