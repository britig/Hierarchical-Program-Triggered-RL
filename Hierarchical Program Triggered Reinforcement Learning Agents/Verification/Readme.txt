Dependencies 

pip install nagini

Install Java 11 or newer (64 bit) and Python 3.6 or newer (64 bit).
Install either Visual C++ Build Tools 2015 (For Windows) or make in Linux

Set

SILICONJAR(Environment Variable) Location : C:\Users\USER\Anaconda3\Lib\site-packages\nagini_translation\resources\backends
CARBONJAR(Environment Variable) Location : C:\Users\USER\Anaconda3\Lib\site-packages\nagini_translation\resources\backends

Install Z3

64-bit build:

python scripts/mk_make.py -x
then:

cd build
nmake (visual studio c++ devpromt) change environment to 64 bit .bat by running the following command from command prompt
%comspec% /k "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"

set Z3_EXE to z3-executable

Examples : https://github.com/marcoeilers/nagini/tree/master/tests/functional/verification
Online IDE : http://viper.ethz.ch/nagini-examples/blank-example.html

Run example : nagini --z3 D:\Briti\z3-master\build\z3.exe nn_agent.py
