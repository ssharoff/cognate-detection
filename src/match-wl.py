#!/usr/bin/env python3
# -*- coding: utf-8 -*- 

import sys, os
wln1,wln2,outn=sys.argv[1:]
wl1=int(os.popen('wc -l '+wln1).readline().split()[0])
wl2=int(os.popen('wc -l '+wln2).readline().split()[0])
print('paste %s %s | head -%d >%s' % (wln1, wln2, min(wl1,wl2), outn))
os.system('paste %s %s | head -%d >%s' % (wln1, wln2, min(wl1,wl2), outn))
if wl1>wl2:
    with open(wln2) as f:
        w2=f.readline().strip() # just the first word
    outf=open(outn,'a')
    with open(wln1) as f:
        for l in f:
            print(l.strip()+'\t'+w2,file=outf)
