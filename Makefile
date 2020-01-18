default:	all

index.html:	index.md
		pandoc index.md -o index.html

clean:
	rm -f index.html

all:	index.html

