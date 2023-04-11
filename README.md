# Simple Miner 

This is a learning tool to demonstrate the operation of a _very simple and broken_ blockchain

# Building

To build simpleMiner 
```
    go build simpleMiner.go
```

# simpleMiner

SimpleMiner is a command-line utility written in Go, which performs a simple Proof of Work (PoW) algorithm on an input file. The user provides the input file, a target difficulty, and optionally, an output file and output directory. The program reads the contents of the input file, concatenates the nonce and the difficulty to the file contents, and calculates the SHA-256 hash of the modified file contents. It then increments the nonce until the hash value is less than or equal to the given difficulty. Once it finds a matching nonce, it writes the modified file contents with the nonce to the specified output file or output directory.

The code does the following:

1. Parses command-line flags for input file, difficulty, output file, and output directory.
2. Validates that the required flags are set and valid.
3. Reads the input file and initializes a nonce with a value of 0.
4. Enters a loop, incrementing the nonce and calculating the SHA-256 hash for the concatenated input file, difficulty, and nonce.
5. Checks if the hash value is less than or equal to the given difficulty.
6. If a match is found, it stops and writes the modified file contents to the output file or output directory. Otherwise, it continues incrementing the nonce.
7. Periodically displays the hash rate and the nonce it's currently checking.

# addblock.sh

Addblock.sh is a shell script that mines a new block using the compiled "simpleMiner" program from the previous Go code. The script operates as follows:

1. Sets a target difficulty for the Proof of Work algorithm.
2. Creates a temporary file for the proposed block and extracts the file's name.
3. Writes the prior block's hash, taken from the "chain" file, to the temporary file as part of the new block's header.
4. Copies the contents of the input file (specified by the $1 argument) into the temporary file as the block's body.
5. Invokes the "simpleMiner" program to perform the mining process, using the temporary file as input, the target difficulty, and an output file in the "blk" directory with the same name as the temporary file and a ".blk" extension.
6. After the "simpleMiner" program successfully mines the block, the script calculates the SHA-256 hash of the mined block and appends it to the "chain" file.

# Example 

A simple way to run the simpleMiner is to invoke it directly and view the output in the terminal:

```    
    ./simpleMiner -i 0 -f 0000000AFFFF0000000000000000000000000000000000000000000000000000 -o -
```
Creating and adding a block to a the simple blockchain is as easy as 
```
    ./addblock.sh ./content/0
```
