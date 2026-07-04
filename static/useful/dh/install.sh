#!/bin/bash
mkdir -p ~/bin
cp dh.sh ~/bin/dh
chmod +x ~/bin/dh
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo "DevOps Helper установлен. Запустите 'dh' для начала."
