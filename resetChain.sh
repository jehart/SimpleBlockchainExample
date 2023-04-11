#!/bin/zsh
if test -f ./chain; then
  rm -f chain
fi

if test -z "$(ls -A ./blk)"; then
else
  rm -f ./blk/*.blk
fi

echo "Genesis Block the unmoved mover" > chain

