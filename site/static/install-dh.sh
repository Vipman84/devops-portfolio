#!/bin/bash
curl -sSL https://devops.ai-donate.ru/dh.sh -o /tmp/dh.sh
mkdir -p ~/bin
cp /tmp/dh.sh ~/bin/dh
chmod +x ~/bin/dh
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
echo "DevOps Helper installed. Run 'dh' to start."
