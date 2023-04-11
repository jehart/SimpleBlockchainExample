#!/bin/zsh



# Read the number from the file
number=$(cat currentblock.dat)

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
echo -n "<block><number>" >> $TMPFILE
echo -n $number >> $TMPFILE
echo -n "</number>\n<priorBlockHash><hash>" >> $TMPFILE
tail -n1 chain | cut -d ' ' -f 1|tr -d '\n' >> $TMPFILE
echo -n "</hash><file>" >> $TMPFILE
tail -n1 chain | cut -d ' ' -f 3|tr -d '\n' >> $TMPFILE
echo "<file/></priorBlockHash>" >> $TMPFILE
# add the sha256 sum of the contents to the proposed block file
echo -n "<contentHash>" >> $TMPFILE
shasum -a 256 $1 | cut -d ' ' -f1 |tr -d '\n' >> $TMPFILE
echo "</contentHash>\n</block>\n" >> $TMPFILE

# add the contents of the file to the proposed block file
# to improve performance, we will not add the contents of the file
#echo -n "<fileContents>" >> $TMPFILE
#cat $1 >> $TMPFILE
#echo "</fileContents>" >> $TMPFILE


# Mine the block and output to the block directory
echo ./simpleMiner -i $TMPFILE -f $difficulty -o ./blk/$number
./simpleMiner -i $TMPFILE -f $difficulty -o ./blk/$number.blk

#Add the block to the chain
shasum -a 256 ./blk/$number.blk >> chain


# Increment the number
number=$((number + 1))

# Write the new number back to the file
echo $number > currentblock.dat
