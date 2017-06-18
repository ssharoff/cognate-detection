#a script for creating a model for mapping the word embedding spaces
#two files need to be aligned for word translations
cosine <- function(x,y) {
    (crossprod(x, y) / sqrt(crossprod(x) * crossprod(y)))[1,1]
}

# args=c('../data/uk-ru-train.dic.ru-100-skip.dat.xz','../data/uk-ru-train.dic.uk-100-skip.dat.xz');

args=commandArgs(trailingOnly=T);
vsf=args[1]; #'uk-ru-train.dic.ru-100-skip.dat.xz'
vtf=args[2]; #'uk-ru-train.dic.uk-100-skip.dat.xz'
lnum=400;
if (length(args)>2) {
    lnum=as.integer(args[3]);  #number of units in the hidden layer
}
numEpochs=50;
if (length(args)>3) {
    numEpochs=as.integer(args[4]);  #number of iterations
}

vs=read.table(vsf,row.names=1);
vt=read.table(vtf,row.names=1);

vsfn=unlist(strsplit(vsf,'-'))[1];
vtfn=unlist(strsplit(vtf,'-'))[2];
ls=dim(vs)[2];
lt=dim(vt)[2];

if (lnum>0) { # MLP from darch
    library(darch)
    v.s <- scale(vs, center = TRUE, scale=TRUE)/6+0.5; # to make in the same range as the sigmoid activation function
    mlp.model <- darch(vt, v.s, layers = lnum, darch.batchSize=5, darch.dropout=0.3, darch.dropout.dropConnect = F, darch.isClass=F, darch.numEpochs = numEpochs, darch.unitFunction = sigmoidUnit) #,bootstrap=T
    outf <- paste(vsfn,vtfn,ls,lt,'darch.Rdata',sep='-');
    save(v.s,vtf,mlp.model,file=outf)
    plot(mlp.model)
} else { # CCA
    cca.mat=cancor(vs, vt, xcenter=F, ycenter=F);
    ## vs.new=as.matrix(vs) %*% cca.mat$xcoef;
    ## vt.new=as.matrix(vt) %*% cca.mat$ycoef;
    outf <- paste(vsfn,vtfn,ls,lt,'cca.Rdata',sep='-');
    save(cca.mat,vs,vt,file=outf)
}
## summary(v.s[,1:4]);
## summary(vt[,1:4]);
## summary(vt.new[,1:4]);
## v.total=rbind(v.s,vt.new)
## v.total.n=fast_row_normalize(v.total);
## v.total.cos=tcrossprod(v.total.n);
## dim(v.total.cos)
## k=10;
## lsub <- t(apply(v.total.cos,MAR=1,function (x) {names(sort.int(x,decreasing=T,method='quick')[1:k])}))
## lsub[1:20,2:5]

