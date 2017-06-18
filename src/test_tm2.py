#!/usr/bin/env python3
# -*- coding: utf-8 -*- 

import sys, io
import getopt
import numpy as np
import collections
import random
from space import Space
import utils as u
# from sklearn.neighbors import BallTree

def usage(errno=0):
    if errno==0 :
        print("""
          Given a translation matrix, test data (words and their translations) and 
          source and target language vectors, it returns translations of source test 
          words and computes Top N accuracy.

          Usage:
          python3 test_tm2.py [options] test_data
          \n\
          Options:
          -1  <file>: vectors in source language, Space-separated, with string 
                      identifier as first column (dim+1 columns, where dim is the 
                      dimensionality of the space)
          -2 <file>: vectors in target language
          -m --matrix <file>: trans_matrix (learned in the training step)
          -c --correction <int>: Number of additional elements for Global Correction. 
                               Optional. Default, baseline retrieval is run.
          -l ---levenshtein <file>: file of weights for Levenshtein operations
                        Source-char Target-char Log-probability 
          -t --topK N, top N words for the similarity assessment
          -v --verbosity N, level of verbosity (0-5),
          -a --alpha num, (between 0 and 1) relative weight to the similarity score,
                      (1-alpha) for the Levenshtein distance    
          -o --output <file>: file prefix. It prints the vectors obtained after 
                              the translation matrix is applied (.vecs.txt and .wds.txt).
                              Optional. Default is ./translated_vecs
          -h --help : help

          Argument:
          test_data: <file>, list of source-target word pairs (space separated words, 
                      one word pair per line)

          Example:
          1) Retrieve translations with standard nearest neighbour retrieval

          python3 test_tm2.py -m tm.txt -1 ENspace.txt -2 ITspace.txt test_data.txt

          2) "Corrected" retrieval (GC). Use additional 2000 source space elements to 
          correct for hubs (words that appear as the nearest neighbours of many points))

          python3 test_tm2.py -c 2000 -m tm.txt -1 ENspace.txt -2 ITspace.txt test_data.txt

          """)
    sys.exit(errno)


def main(sys_argv):
    try:
        opts, argv = getopt.getopt(sys_argv[1:], "ho:c:l:m:1:2:t:a:v:",
                ["help", "output=", "correction=", "levenshtein=", "matrix=", "1=", "2=", "topK=", "alpha=", "verbosity="])
    except getopt.GetoptError as err:
        print(str(err))
        usage()
        sys.exit(1)

    out_file = "./translated_vecs"
    additional = None
    levcosts = {}
    for opt, val in opts:
        # print(opt+'='+val)
        if opt in ("-o", "--ouput"):
            out_file = val
        elif opt in ("-l", "--levenshtein"):
            levcosts = u.readcosts(val)
        elif opt in ("-m", "--matrix"):
            tm_file = val
        elif opt == '-1':
            source_file = val
        elif opt == '-2':
            target_file = val
        elif opt in ("-c", "--correction"):
            try:
                additional = int(val)
            except ValueError:
                print("additional: %s" % val)
                usage(1)
        elif opt in ("-t", "--topK"):
            try:
                u.topK = int(val)
            except ValueError:
                print("topK: %s" % val)
                usage(1)
        elif opt in ("-v", "--verbosity"):
            try:
                u.verbosity = int(val)
            except ValueError:
                print("verbosity: %s" % val)
                usage(1)
        elif opt in ("-a", "--alpha"):
            try:
                u.alpha = float(val)
            except ValueError:
                print("alpha: %s" % val)
                usage(1)
        elif opt in ("-h", "--help"):
            usage(0)
        else:
            print("Unknown option: -%s %s" % (opt,val))
            usage(1)

    if len(argv) == 1:
        test_file = argv[0]
    else:
        print('Unused arguments:')
        print(argv)
        usage(1)

    #if u.verbosity>0: # always log the parameters in the output
    sys.stdout.write(sys_argv[0]+" ")
    for opt, val in opts:
        sys.stdout.write(opt+" "+val+" ")
    print(test_file)

    if u.verbosity>1:
        print("Loading the translation matrix %s " % tm_file)
    tm = np.loadtxt(tm_file)

    if u.verbosity>1:
        print("Reading the test data %s " % test_file)
    test_data = u.read_dict(test_file)

    #in the _source_ space, we only need to load vectors for the words in test.
    #semantic spaces may contain additional words, ALL words in the _target_ 
    #space are used as the search space
    source_words, _ = zip(*test_data)
    source_words = set(source_words)

    if u.verbosity>1:
        print("Reading: %s" % source_file)

    if not additional:
        source_sp = Space.build(source_file, source_words)
    else:
        #read all the words in the space
        with io.open(source_file,'r',encoding='utf8') as f:
            lexicon = set([l.split(' ')[0] for l in f])
        # lexicon = set(np.loadtxt(source_file, skiprows=1, dtype=str, 
        #                             comments=None, usecols=(0,)).flatten())
        #the max number of additional+test elements is bounded by the size 
        #of the lexicon
        additional = min(additional, len(lexicon) - len(source_words))
        #we sample additional elements that are not already in source_words
        random.seed(100)
        if additional>0:
            lexicon = random.sample(list(lexicon.difference(source_words)), additional)
        
        #load the source space
        source_sp = Space.build(source_file, source_words.union(set(lexicon)))
    
    source_sp.normalize()

    if u.verbosity>1:
        print("Reading: %s" % target_file)
    target_sp = Space.build(target_file)
    target_sp.normalize()

    if u.verbosity>1:
        print("Retrieving translations")
    test_data = u.get_valid_data(source_sp, target_sp, test_data)

    #turn test data into a dictionary (a word can have mutiple translation)
    gold = collections.defaultdict(set)
    for k, v in test_data:
        gold[k].add(v)

    if u.verbosity>1:
        print("Translating") #translates all the elements loaded in the source space
    source_sp = u.apply_tm(source_sp, tm)

    u.score(source_sp, target_sp, gold, additional,levcosts)
    print("Printing mapped vectors: %s" % out_file)
    np.savetxt("%s.vecs.txt" % out_file, source_sp.mat)
    #    np.savetxt("%s.wds.txt" % out_file, source_sp.id2row, fmt="%s")  # no utf8
    with open("%s.wds.txt" % out_file, "w") as outf:
        for s in source_sp.id2row:
            print(s,file=outf)

if __name__ == '__main__':
    main(sys.argv)
