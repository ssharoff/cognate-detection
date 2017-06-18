#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import sys
# import collections
import io

def readtest(fn):
    # d={} # collections.defaultdict('<missing>')
    # with io.open(filename,'r',encoding='utf8') as f:
    #     for l in f:
    #         [s,t]=l.split()
    #         d[s]=t
    # return(d)
    return([tuple(line.strip().split()) for line in io.open(fn,'r',encoding='utf8')])

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
       a simple backoff for the costs
    """
    if (s+t) in cost.keys():
        cost = cost[s+t]
    else:
        cost = 1
    return(cost)

def iterative_levenshtein(s, t,cost):
    """ 
        iterative_levenshtein(s, t) -> ldist
        ldist is the Levenshtein distance between the strings 
        s and t.
        For all i and j, dist[i,j] will contain the Levenshtein 
        distance between the first i characters of s and the 
        first j characters of t
        Modified example from http://www.python-course.eu/levenshtein_distance.php
    """
    rows = len(s)+1
    cols = len(t)+1
    # rows = len(s)
    # cols = len(t)

    dist = [[0 for x in range(cols)] for x in range(rows)]
    # source prefixes can be transformed into empty strings 
    # by deletions:
    for i in range(1, rows):
        dist[i][0] = i
    # target prefixes can be created from an empty source string
    # by inserting the characters
    for i in range(1, cols):
        dist[0][i] = i
        
    for col in range(1, cols):
        for row in range(1, rows):
            dist[row][col] = min(dist[row-1][col] + computecost('<eps>',t[col-1],cost),  # deletion
                                 dist[row][col-1] + computecost(s[row-1],'<eps>',cost), # insertion
                                 dist[row-1][col-1] + computecost(s[row-1],t[col-1],cost)) # substitution
    # for r in range(rows):
    #     print(dist[r])

    return(dist[row][col]/max(cols,rows))

d=readtest(sys.argv[1])
cost={}
if len(sys.argv)>2:
    cost=readcosts(sys.argv[2])
if len(sys.argv)>3:
    cost=cost.update(readcosts(sys.argv[3]))

print(iterative_levenshtein(u'англійські',u'английские',cost))
print(iterative_levenshtein(u'англійські',u'английски',cost))
print(iterative_levenshtein(u'англійські',u'английском',cost))

count=0.1
tp=0
for line in sys.stdin.readlines():
    cands=line.replace('"','').split()
    f=cands.pop(0)
    if len(f)>5:
        beste=min(enumerate(cands), key=lambda e: iterative_levenshtein(f,e[1],cost))[1]
        try:
            reale=d[f]
            m=int(reale==beste)
            tp+=m
            count+=1
            print(m,f,reale,beste,iterative_levenshtein(f,beste,cost))
            # for e in cands:
            #     print(f,reale,e,iterative_levenshtein(f,e,cost))
        except:
            print('Unknown ',f)
#print('%.3f' % float(tp/count), file=sys.stderr)

