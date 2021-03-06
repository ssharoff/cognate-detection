# cognate-detection
A bunch of Perl / Python / R scripts for detection of cognate words between languages

## A short description of the scripts

* `align-dict.pl` - aligns two separately trained `word2vec` models using a dictionary;
* `filter-bi1.R` - test two aligned models for how close their vectors are, following (Vulic, Korhonen, 2016);
* `align-bi1.R` - builds a [`darch`] (https://github.com/maddin79/darch/) model for mapping word vectors from two aligned models;
* `printbiwec.R` - use a [`darch`] (https://github.com/maddin79/darch/) model to map new set of word vectors into a shared space and find their closest translations;
* `weighted-lev.py` - Levenshtein distance weighted by probabilities of transitions;
* `train_tm.py` - Weighted Levenshtein Distance training expanding on Dinu, Baroni, 2014, http://clic.cimec.unitn.it/~georgiana.dinu/down/ 
* `test_tm2.py` - Weighted Levenshtein Distance cross-lingual mapping, expanding on Dinu, Baroni, 2014, http://clic.cimec.unitn.it/~georgiana.dinu/down/ 

Serge Sharoff