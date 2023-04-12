#!/bin/zsh

#prepare the chain file
if test -f ./chain; then
  rm -f chain
fi

#prepare the blockchain directory
if [ -d ./blk ]; then
    if test -z "$(ls -A ./blk)"; then
    # No files in directory
    else
    # Remove all blockchain files in the directory
      rm -f ./blk/*.blk
    fi # files in directory
else
  mkdir ./blk
fi

