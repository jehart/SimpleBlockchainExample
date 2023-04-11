#!/bin/zsh

# Reset the blockchain
./resetChain.sh

# Find all files in the ./content directory and run ./addblock.sh on each file
find ./content -type f | xargs -n 1 ./addblock.sh

# Verify the blocks using Python script
python3 ./verify_blocks.py