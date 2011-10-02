Each month Diamond Comic release a list of the comics to come and
apparels to come. In order to leave no comic behind, this script 
parses the list for the current month, and returns a list of comics
associated to the provided titles. The title can either be in a file
or a single title can be pass via the command line.

The output has the following form :
ID TITLE PRICE

Example :
0672 WOLVERINE AND X-MEN #3 XREGG $3.99

# Usage
Usage :
   -c : show only comic books
   -f file : search every title in file
   -t title : search only this title
   -h : show help
