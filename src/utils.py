# -*- coding: utf-8 -*- 

import numpy as np
import collections
import io
from space import Space

verbosity = 1
# 0 only accuracy
# 1 also errors 
# 2 also top 5
# 3 also correct translations
# 4 also errors in topK
# 5 all with errors
topK = 10
alpha = 0.5
maxexamples = 10


def prec_at(ranks, cut):
    return len([r for r in ranks if r <= cut])/float(len(ranks))

def get_rank(nn, gold):
    for idx,word in enumerate(nn):
        if word in gold:
            return idx + 1
    if verbosity>3:
        print('Not found for %s in %d candidates' % (gold, len(nn)))
    return idx + 1

        
def read_dict(dict_file):
    return [tuple(line.strip().split()[0:2]) for line in io.open(dict_file,encoding='utf8')]

def readcosts(fn):
    """
       reading costs from fast_align output
    """
    cost={}
    for l in io.open(fn,'r',encoding='utf8'):
        [s,t,c]=l.split()
        cost[s+t]=1-2.7**float(c)
    return(cost)

def computecost(s,t,cost):
    """
       a simple backoff for the character substitution costs
    """
    if (s==t):
        cost = 0
    elif (s+t) in cost.keys():
        cost = cost[s+t]
    else:
        cost = 1
    return(cost)

def apply_tm(sp, tm):
    if verbosity>1:
        print("Applying the translation matrix, size of data: %d" % sp.mat.shape[0])
    return Space(sp.mat*tm, sp.id2row)
    
def get_valid_data(sp1, sp2, data):
    return [(x[0], x[1]) for x in data if 
            x[0] in sp1.row2id and x[1] in sp2.row2id]
    # return [(el1, el2) for el1,el2 in data if 
    #         el1 in sp1.row2id and el2 in sp2.row2id]

def train_tm(sp1, sp2, data):

    data = get_valid_data(sp1, sp2, data)
    if verbosity>1:
        print("Training using: %d word pairs" % len(data))
    
    els1, els2 = zip(*data)
    m1 = sp1.mat[[sp1.row2id[el] for el in els1],:]
    m2 = sp2.mat[[sp2.row2id[el] for el in els2],:]

    tm = np.linalg.lstsq(m1, m2, -1)[0]

    return tm 
    
def iterative_levenshtein(s, t,cost):
    """ 
    dist[i,j] will contain the Levenshtein distance between the first i characters of s 
    and the first j characters of t
    Modified example from http://www.python-course.eu/levenshtein_distance.php
    """
    rows = len(s)+1
    cols = len(t)+1

    dist = [[0 for x in range(cols)] for x in range(rows)]
    # deletions for source prefixes
    for i in range(1, rows):
        dist[i][0] = i
    # insersions for target prefixes
    for i in range(1, cols):
        dist[0][i] = i
        
    for col in range(1, cols):
        for row in range(1, rows):
            dist[row][col] = min(dist[row-1][col] + computecost('<eps>',t[col-1],cost),  # deletion
                                 dist[row][col-1] + computecost(s[row-1],'<eps>',cost), # insertion
                                 dist[row-1][col-1] + computecost(s[row-1],t[col-1],cost)) # substitution

    return(dist[row][col]/max(cols,rows))


def score(sp1, sp2, gold, additional, levcosts):

    sp1.normalize()
    if verbosity>2:
        print("Verbosity: %d, topK: %d, alpha: %.2f" % (verbosity,topK,alpha))
    if verbosity>4:
        maxexamples=topK
    else:
        maxexamples=5

    if verbosity>1:
        print(sp2.mat.shape, flush=True)

    sp1T=sp1.mat.T
    if verbosity>1:
        print(sp1T.shape, flush=True)

    sim_mat = -sp2.mat*sp1T
    
    if additional:
        #for each element, computes its rank in the ranked list of
        #similarites. sorting done on the opposite axis (inverse querying) 
        srtd_idx = np.argsort(np.argsort(sim_mat, axis=1), axis=1)

        #for each element, the resulting rank is combined with cosine scores. 
        #the effect will be of breaking the ties, because cosines are smaller
        #than 1. sorting done on the standard axis (regular NN querying)
        srtd_idx = np.argsort(srtd_idx + sim_mat, axis=0)
    else:
        srtd_idx = np.argsort(sim_mat, axis=0)

    ranks = []
    for i,el1 in enumerate(gold.keys()):

        sp1_idx = sp1.row2id[el1]
        #select the top K translations
        translations = []
        translist = []
        for j in range(topK):
            sp2_idx = srtd_idx[j, sp1_idx]
            word, score = sp2.id2row[sp2_idx], -sim_mat[sp2_idx, sp1_idx]
            lscore=1
            if not el1==word:
                lscore=1-iterative_levenshtein(el1,word,levcosts)
            translist.append([word, score, lscore, alpha*score+(1-alpha)*lscore])
            # translations.append(u"\t\t%s\t%.3f\t%.3f\t%.3f" % (word, score, lscore, alpha*score+(1-alpha)*lscore))

        # translations = "\n".join(translations) 
        translist=sorted(translist, key=lambda v: v[3], reverse=True)
        #get the rank of the (highest-ranked) translation
        rnk = get_rank([w[0] for w in translist], 
                        [el for el in gold[el1]])
        # rnk = get_rank(srtd_idx[:,sp1_idx].A.ravel(), 
        #                 [sp2.row2id[el] for el in gold[el1]])
        ranks.append(rnk)
        if ((verbosity>0) and (rnk>1)) or (verbosity>1):
            print (u"Id: %d Source: %s\tTranslation: %s\t%.3f\tGold: %s \tRank: %d" %
                (len(ranks), el1, translist[0][0], translist[0][3], gold[el1], rnk))
            if verbosity>2:
                for w in range(maxexamples):
                    print(translist[w])

    if verbosity>1:
        print("Corrected: %s" % str(additional))
    if additional:
        if verbosity>1:
            print("Total extra elements, Test(%d) + Additional:%d" % (len(gold.keys()),
                                                           sp1.mat.shape[0]))
    for k in [1,5,10]:
        print("Prec@%d: %.3f" % (k, prec_at(ranks, k)))
