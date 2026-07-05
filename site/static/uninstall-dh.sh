#!/bin/bash
rm -f ~/bin/dh
sed -i '/export PATH="$HOME\/bin:$PATH"/d' ~/.bashrc
echo "DevOps Helper (dh) удалён."
