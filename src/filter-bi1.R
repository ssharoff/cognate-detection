# a script for finding closely mapped embedding spaces
# two files need to be aligned for word translations
# it follows Vulic, Korhonen, 2016 idea about the importance of symmetry in the lexicon

cosine <- function(x,y) {
    (crossprod(x,y) / sqrt(crossprod(x) * crossprod(y)))[1,1]
}

applymodel <- function(vt,v.s,cvsplit.i) {
    mlp.model <- darch(vt[cvsplit.i,], v.s[cvsplit.i,], layers = lnum, darch.batchSize=5, darch.dropout=0.3, darch.dropout.dropConnect = F, darch.isClass=F, darch.numEpochs = numEpochs, darch.unitFunction = sigmoidUnit) #,bootstrap=T
    vt.new <- predict(mlp.model,vt[-cvsplit.i,]);
    row.names(vt.new)=row.names(vt[-cvsplit.i,]);
    return(vt.new);
}

applymodel.cca <- function(vt,vs) {
        cca.mat=cancor(vs, vt, xcenter=F, ycenter=F);
        vs.new=as.matrix(vs) %*% cca.mat$xcoef;
        vt.new=as.matrix(vt) %*% cca.mat$ycoef;
        return(list(vs=vs.new,vt=vt.new))
}

library(darch)

args=commandArgs(trailingOnly=T);
# args=c('data/uk-ru-train.dic.ru-100-skip.dat.xz','data/uk-ru-train.dic.uk-100-skip.dat.xz');
vsf=args[1]; 
vtf=args[2];
coslim=0.95;
if (length(args)>2) {
    coslim=as.numeric(args[3]);  #threshold for similarity
}
lnum=400;
if (length(args)>3) {
    lnum=as.integer(args[4]);  #number of units in the hidden layer
}
numEpochs=50;
if (length(args)>4) {
    numEpochs=as.integer(args[5]);  #number of iterations
}

vs=read.table(vsf,row.names=1);
vt=read.table(vtf,row.names=1);

vsfn=unlist(strsplit(vsf,'-'))[1];
vtfn=unlist(strsplit(vtf,'-'))[2];
ls=dim(vs)[2];
lt=dim(vt)[2];
lvs=dim(vs)[1];

vs.new=numeric(0);
vt.new=numeric(0);
if (lnum>0) {
    v.s <- scale(vs, center = TRUE, scale=TRUE)/6+0.5; # to match the range of the sigmoid activation function
    cvsplit.i=sample(1:lvs,lvs/2);
    p1=applymodel.mlp(vt,v.s,cvsplit.i);
    p2=applymodel.mlp(vt,v.s,-cvsplit.i);
    vt.new=rbind(p1,p2);
    vs.new=rbind(v.s[-cvsplit.i,],v.s[cvsplit.i,]);  #to ensure the same order
} else {  #alternative with CCA:
    cc.out=applymodel.cca(vs,vt);
    vs.new=cc.out$vs;
    vt.new=cc.out$vt;
};

cos=numeric(0);
for (i in 1: lvs) {
    cos[i]=cosine(vt.new[i,],vs.new[i,])
}
print(summary(cos));

coslim=quantile(cos, prob = 1-coslim);

coslimlist <- which(cos<coslim)
print(cbind(rownames(vs[coslimlist,]),rownames(vt[coslimlist,])))
# now we select symmetrical translations
if (length(coslimlist)) {
    newdic=cbind(rownames(vs.new[-coslimlist,]),
                 rownames(vt.new[-coslimlist,]),
                 cos[-coslimlist]);
    write.table(newdic,file=paste(vsfn,ls,vtfn,lt,coslim,'test.dic',sep='-'))
}



