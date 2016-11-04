import difflib
import sys

for line in sys.stdin:
    x=line.split()
    levd=difflib.SequenceMatcher(None, x[0], x[1]).ratio()
    print(x[0],x[1],levd)
