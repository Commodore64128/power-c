64tass -a src\shell.asm -l target\shell.lbl -L target\shell.lst -o target\shell
cd target
c1541 -attach powerc-d1.d64 -delete shell
c1541 -attach powerc-d1.d64 -write shell shell
cd ..