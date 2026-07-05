#!/bin/bash
rm -f ~/bin/dh
sed -i '/export PATH="$HOME\/bin:$PATH"/d' ~/.bashrc
echo "DevOps Helper uninstalled. Please restart your terminal."
