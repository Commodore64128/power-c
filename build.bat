64tass -a src\shell.asm -l target\shell.lbl -L target\shell.lst -o target\shell
64tass -a src\cc.sh.asm -l target\cc.sh.lbl -L target\cc.sh.lst -o target\cc.sh
64tass -a src\compiler.asm -l target\compiler.lbl -L target\compiler.lst -o target\compiler
cd target
c1541 -attach powerc-d1.d64 -delete shell
c1541 -attach powerc-d1.d64 -write shell shell
c1541 -attach powerc-d1.d64 -delete cc.sh
c1541 -attach powerc-d1.d64 -write cc.sh cc.sh
c1541 -attach powerc-d1.d64 -delete compiler
c1541 -attach powerc-d1.d64 -write compiler compiler
cd ..