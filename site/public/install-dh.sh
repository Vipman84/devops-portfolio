#!/bin/bash
curl -sSL https://devops.ai-donate.ru/dh.sh -o dh.sh
mkdir -p ~/bin
cp dh.sh ~/bin/dh
chmod +x ~/bin/dh
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo "DevOps Helper установлен. Запустите 'dh' для начала."
