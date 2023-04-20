# Simple Miner 

This is a learning tool to demonstrate the operation of a _very simple and broken_ blockchain. The blockchain implementation uses a proof-of-work mechanism to secure and add new blocks to the chain. The implementation includes a simple miner that can be used to mine blocks and a script to format and add them to the blockchain.

The blockchain is made up of a chain of blocks, with each block containing information about its contents and the block that came before it. The block structure includes the block number, a timestamp, a hash of the prior block's content, a hash of the block's content, and information about the block's mining process (including the difficulty and nonce).

The project includes a shell script that can be used to add blocks to the chain. The script determines the next block number, creates a new block file, mines the block using the simple miner, adds the block to the chain.

The implementation also includes command-line flags that can be used to specify the input file, the current search difficulty, the output file, and the output directory. These flags provide flexibility and allow the miner to be used in a variety of settings.

Overall, this project provides a basic implementation of a blockchain and a simple miner that can be used to add new blocks to the chain. It can be used as a starting point for developing more complex blockchain applications or as a learning resource for those who want to better understand how blockchains work.

# TL;DR
Just try it out:
```
    go build simpleMiner.go
    ./init_blockchain.sh
    ./addblock.sh ./content/1
    ./addblock.sh ./content/2
    ./addblock.sh ./content/3
    ./addblock.sh ./content/4
    ./addblock.sh ./content/5
    python3 ./verify_blocks.py
```
# simpleMiner

## Description
SimpleMiner is a command-line utility written in Go, which performs a simple Proof of Work (PoW) algorithm on an input file. The user provides the input file, a target difficulty, and optionally, an output file and output directory. The program reads the contents of the input file, concatenates the nonce and the difficulty to the file contents, and calculates the SHA-256 hash of the modified file contents. It then increments the nonce until the hash value is less than or equal to the given difficulty. Once it finds a matching nonce, it writes the modified file contents with the nonce to the specified output file or output directory.

The code does the following:

1. Parses command-line flags for input file, difficulty, output file, and output directory.
2. Validates that the required flags are set and valid.
3. Reads the input file and initializes a nonce with a value of 0.
4. Enters a loop, incrementing the nonce and calculating the SHA-256 hash for the concatenated input file, difficulty, and nonce.
5. Checks if the hash value is less than or equal to the given difficulty.
6. If a match is found, it stops and writes the modified file contents to the output file or output directory. Otherwise, it continues incrementing the nonce.
7. Periodically displays the hash rate and the nonce it's currently checking.

A simple way to run the simpleMiner is to invoke it directly and view the output in the terminal:

```    
    ./simpleMiner -i 0 -f 0000000AFFFF0000000000000000000000000000000000000000000000000000 -o -
```


## Building

To build simpleMiner 
```
    go build simpleMiner.go
```

# Adding a block and growing the blockchain
Addblock.sh is a shell script that mines a new block using the compiled "simpleMiner" program from the previous Go code. The script operates as follows:

1. Sets a target difficulty for the Proof of Work algorithm.
2. Creates a temporary file for the proposed block and extracts the file's name.
3. Writes the prior block's hash, taken from the "chain" file, to the temporary file as part of the new block's header.
4. Copies the contents of the input file (specified by the $1 argument) into the temporary file as the block's body.
5. Invokes the "simpleMiner" program to perform the mining process, using the temporary file as input, the target difficulty, and an output file in the "blk" directory with the same name as the temporary file and a ".blk" extension.
6. After the "simpleMiner" program successfully mines the block, the script calculates the SHA-256 hash of the mined block and appends it to the "chain" file.

Creating and adding a block to a the simple blockchain is as easy as:
```
    ./addblock.sh ./content/0
```

# Resetting and Initializing the Blockchain
The resetChain.sh script is a simple shell script to reset the blockchain state. It performs the following tasks:

Removes all the ".blk" files from the "blk" directory. These files represent the mined blocks.
Deletes the "chain" file, which stores the hashes of the mined blocks.
Creates a new "chain" file with an initial entry, "Genesis Block the unmoved mover", representing the genesis block or the first block of the blockchain.

To initialize of reset the blockchain from the distribution folder run:

```
    ./init_blockchain.sh
```

# Verifying the Blocks
The distribution contains a Python program that perfroms a simple blockchain validation. It reads the chain file line by line, verifies each block in the chain, and outputs whether each block is valid or invalid. If any block is invalid, the program prints an error message and terminates. If all blocks in the chain are valid, the program completes successfully.

To validate the blockcahin run:
```
    python3 ./verify_blocks.py
```
There are many improvements that can and probably should be made. Like not relying on the chain file and instead walking the .blk files directly. 

# Other Details
Each block has the following structure:
```
<block>
<number>1</number>
<timestamp>1681251059</timestamp>
<priorBlockHash>
<hash>000000846ad3774b3555e06ad9c2d6e48e2c089fa25677e4919a55118ef098a4</hash>
<file>./blk/0.blk<file/>
</priorBlockHash>
<contentHash>8ff55c765b44667d40e371c67182108556d101c2fb42fc32b965bde66dda9e9a</contentHash>
</block>
<minerData>
<difficulty>000000FFFFFF0000000000000000000000000000000000000000000000000000</difficulty>
<nonce>4866307</nonce>
</minerData>
```

## Discussion
- number: The block number, represented as a positive integer.
- timestamp: The timestamp of the block's creation, represented as a Unix epoch timestamp.
- priorBlockHash: A hash of the prior block's content, represented as a SHA256 hash. This element also contains the filename of the prior block.
- contentHash: A hash of the block's content, represented as a SHA256 hash.
- minerData: Information about the block's mining process. This element includes the difficulty of the current mined block and the nonce that was found to match the difficulty.
- difficulty: The level of complexity required to solve a the SHA256 hash and add a new block to the blockchain. The difficulty is can be adjusted in the addblock.sh script.
- nonce: a number that is included in a block's data that can be varied in order to create a hash that meets a specific difficulty level
