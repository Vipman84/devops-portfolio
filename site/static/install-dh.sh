#!/bin/bash
curl -sSL https://devops.ai-donate.ru/dh.sh -o /tmp/dh.sh
mkdir -p ~/bin
cp /tmp/dh.sh ~/bin/dh
chmod +x ~/bin/dh
grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
echo "DevOps Helper установлен. Запустите 'dh'."
