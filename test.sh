#!/bin/zsh
./resetChain.sh
find ./content -type f | xargs -n 1 ./addblock.sh
python3 ./verify_blocks.py