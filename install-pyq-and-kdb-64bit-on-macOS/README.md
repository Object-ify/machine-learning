#### Install pyq with kdb 64bit on MacOS


If you need to run the pyq library with kdb 64 bit on Mac OS, you have to follow these steps:

1 - Download the pyq source code:

git clone https://github.com/enlnt/pyq.git


2 - Change the setup.py file.
Remove the line 751:

bits = 32

3 - Install it:

pip install .

Note: Maybe you need set the user mode on pip install:

pip install --user .


Enjoy it.