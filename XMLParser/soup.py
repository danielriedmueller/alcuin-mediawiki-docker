import sys
from bs4 import BeautifulSoup

with open(sys.argv[1]) as fp:
    soup = BeautifulSoup(fp,  "xml")
    print(soup)