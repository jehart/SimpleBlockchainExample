#!/bin/zsh



# Read the number from the file
number=$(ls -1 ./blk | wc -l | tr -d '\ ')

# Print the number
echo "Adding Block: $number"

# Set the target difficulty for the block 
# this sets the highest value of the hash
difficulty="000000FFFFFF0000000000000000000000000000000000000000000000000000"

# Create a temporary file to add to the blockchain
file=$1:t
TMPFILE=`mktemp -q /tmp/$file.XXXXXX`
if [ $? -ne 0 ]; then
   echo "$0: Can't create temp file, exiting..."
   exit 1
fi
filename=$TMPFILE:t

# add the prior block hash to the new proposed blcok
echo -n "<block>\n<number>" >> $TMPFILE
echo -n $number >> $TMPFILE
echo -n "</number>\n" >> $TMPFILE

# add the timestamp to the proposed block file
echo -n "<timestamp>" >> $TMPFILE
date +%s | tr -d '\n'>> $TMPFILE
echo -n "</timestamp>\n" >> $TMPFILE

# add the prior block hash to the proposed block file
echo -n "<priorBlockHash>\n<hash>" >> $TMPFILE
tail -n1 chain | cut -d ' ' -f 1|tr -d '\n' >> $TMPFILE
echo -n "</hash>\n<file>" >> $TMPFILE
tail -n1 chain | cut -d ' ' -f 3|tr -d '\n' >> $TMPFILE
echo "<file/>\n</priorBlockHash>" >> $TMPFILE

# add the sha256 sum of the contents to the proposed block file
echo -n "<contentHash>" >> $TMPFILE
shasum -a 256 $1 | cut -d ' ' -f1 |tr -d '\n' >> $TMPFILE
echo -n "</contentHash>\n</block>\n" >> $TMPFILE

# add the contents of the file to the proposed block file
# to improve performance, we will not add the contents of the file
#echo -n "<fileContents>" >> $TMPFILE
#cat $1 >> $TMPFILE
#echo "</fileContents>" >> $TMPFILE


# Mine the block and output to the block directory
echo ./simpleMiner -i $TMPFILE -f $difficulty -o ./blk/$number.blk
./simpleMiner -i $TMPFILE -f $difficulty -o ./blk/$number.blk

#Add the block to the chain
shasum -a 256 ./blk/$number.blk >> chain
