#!/bin/zsh

# Set the target difficulty
difficulty="0000000FFFFF0000000000000000000000000000000000000000000000000000"

# Create a temporary file to add to the blockchain
file=$1:t
TMPFILE=`mktemp -q /tmp/$file.XXXXXX`
if [ $? -ne 0 ]; then
   echo "$0: Can't create temp file, exiting..."
   exit 1
fi
filename=$TMPFILE:t


# add the prior block hash to the new proposed blcok
echo -n "<block>\n<header>\n<PriorBlockHash hash=\"" >> $TMPFILE
tail -n1 chain | tr -d '\n' >> $TMPFILE
echo "\"/>" >> $TMPFILE
echo "</header>" >> $TMPFILE
echo "<body>" >> $TMPFILE
# add the contents of the block to the file
cat $1 >> $TMPFILE 
echo "</body>\n</block>\n" >> $TMPFILE

# Mine the block and output to the block directory
echo ./hash9 -i $TMPFILE -f $difficulty -o ./blk/$filename
./simpleMiner -i $TMPFILE -f $difficulty -o ./blk/$filename.blk

#Add the block to the chain
shasum -a 256 ./blk/$filename.blk >> chain

#TODO: verify that the sums match 
# verify the current block chain
