#!/bin/bash
curl -sSL https://devops.ai-donate.ru/dh.sh -o /tmp/dh.sh
mkdir -p ~/bin
cp /tmp/dh.sh ~/bin/dh
chmod +x ~/bin/dh
if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi
echo "DevOps Helper installed. Run 'source ~/.bashrc' or open a new terminal, then type 'dh' to start."
