The final project for Thanh Nguyen's CS2640 Assembly Programming course. Developed in the span of three weeks, the goal of this project was to read the data on the enames.dat file, containing a list of all elements on the periodic table,
and transcribe the contents into a reverse linked list and iterate through and print all the values of said linked list.

The code to read the file was provided by Professor Thanh Nguyen, fileio.s, however all of elist.s is my own code.

To achieve this linked list, each item in the file was duplicated and memory was allocated to store said item. Then, a node is created, utilizing a stack to hold the memory address of both the value and the previous node, if one exists.
This process is repeated until all lines in the file have been read.

Finally, we iterate through the linked list, utilizing a recursive method to do so. This method also outputs the value of each node automatically, along with the length of each node's value.
