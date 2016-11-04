import sys

def readcosts(fn,cost1):
    """
       reading costs
    """
    dlist=open(fn,'r').readlines()
    cost=cost1
    for l in dlist:
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

def argbest(f,cands,cost):
    return 

cost={}
cost=readcosts(sys.argv[1],cost);
cost=readcosts(sys.argv[2],cost);

#iterative_levenshtein(u"англійські",u"английские",cost)

for line in sys.stdin.readlines():
    cands=line.split()
    f=cands.pop(0)
    if len(f)>5:
        beste=min(enumerate(cands), key=lambda e: iterative_levenshtein(f,e[1],cost))[1]
        print(f,beste,iterative_levenshtein(f,beste,cost))
        # for e in cands:
        #     print(f,e,iterative_levenshtein(f,e,cost))

    # if len(f)>3:
    #     [f,e]=line.split()
    #     print(f,e,iterative_levenshtein(f,e,cost)) 

