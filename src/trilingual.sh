#this creates a tri-lingual list from two sets of bilingual files
# 1-3 lgs ($1-$2 and $1-$3)
# 4-5 limits for the two lg pairs, tested as "grep -n ' 0.4' pl-cs-bi-lev.dic | head"

PAIR1=$1-$2
PAIR2=$1-$3
BOTH=$1-$2-$3

cut -f 1 -d ' ' $PAIR1-bi-lev.dic | head -n $4 | sort >$PAIR1-bi.$1
cut -f 1 -d ' ' $PAIR2-bi-lev.dic | head -n $5 | sort >$PAIR2-bi.$1

comm -12 $PAIR1-bi.$1 $PAIR2-bi.$1 >$BOTH.$1

head -n $4 $PAIR1-bi-lev.dic | dedupekeys.pl -k $BOTH.$1 | sort >$PAIR1-bi-lev-test.dic 
head -n $5 $PAIR2-bi-lev.dic | dedupekeys.pl -k $BOTH.$1 | sort >$PAIR2-bi-lev-test.dic 

paste -d ' ' $PAIR2-bi-lev-test.dic $PAIR1-bi-lev-test.dic | cut -f 1,2,5 -d ' ' | grep -v '[A-Z]' >$BOTH-test.dic