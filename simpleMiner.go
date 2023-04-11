package main

import (
	"crypto/sha256"
	"flag"
	"fmt"
	"io/ioutil"
	"math/big"
	"os"
	"path/filepath"
	"strconv"
	"time"
)

func main() {

	// Define command line flags
	filenameFlag := flag.String("i", "", "the name of the file to check")
	difficulty := flag.String("f", "", "The current search difficulty")
	outputFilenameFlag := flag.String("o", "", "(Optional) the name of the output file (\"-\" is stdout")
	outputDirFlag := flag.String("d", "", "(Optional)the directory to save the output file")

	// Parse command line flags
	flag.Parse()

	// Check that the required flags are set
	if *filenameFlag == "" || *difficulty == "" {
		executableName := os.Args[0]
		fmt.Println("Usage: " + executableName + " -i <filename> -f <difficulty> [-o <output_filename>] [-d <output directory>]")
		fmt.Println("Flags: -i: the name of the file to check")
		fmt.Println("       -f: the current search difficulty")
		fmt.Println("       -o: (Optional) the name of the output file (\"-\" is stdout")
		fmt.Println("       -d: (Optional) the directory to save the output file")
		fmt.Println("")
		fmt.Println("Example: " + executableName + " -i input.txt -f 0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -o output.txt")

		os.Exit(1)
	}
	// Retrieve the filename, number of leading zeros, and output directory from the flags
	filename := *filenameFlag
	filebasename := filepath.Base(filename)

	givenNumber, ok := new(big.Int).SetString(*difficulty, 16)
	if !ok {
		fmt.Println("Invalid given number:", *difficulty)
		return
	}

	outputDir := *outputDirFlag

	var outputFile *os.File
	var err error

	if *outputFilenameFlag == "-" {
		outputFile = os.Stdout
	} else if *outputFilenameFlag == "" {

	} else {
		outputFile, err = os.Create(*outputFilenameFlag)
		if err != nil {
			fmt.Println("Error: could not create output file:", *outputFilenameFlag)
			os.Exit(1)
		}
		defer outputFile.Close()
	}

	// Read the contents of the file into memory
	fileContents, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Println("Error: could not read file:", filename)
		os.Exit(1)
	}

	// Calculate the initial SHA-256 hash of the file contents and nonce
	nonce := 0

	startTime := time.Now()
	for {
		// Concatenate the encoded file contents and nonce
		data := append(fileContents, []byte("<minerData>\n<difficulty>"+*difficulty+"</difficulty>\n<nonce>"+strconv.Itoa(nonce)+"</nonce>\n</minerData>\n\n")...)

		// Calculate the SHA-256 hash of the concatenated data
		hash := sha256.Sum256(data)

		// Convert the hash to a big.Int representation
		hashInt := new(big.Int).SetBytes(hash[:])

		if hashInt.Cmp(givenNumber) <= 0 {
			// If it does, stop the timer and display the results
			elapsedTime := time.Since(startTime)
			hashRate := float64(nonce) / elapsedTime.Seconds()
			StatusLine(fmt.Sprintf("Nonce: %d, Hash: %x, Hashrate: %.2f H/s", nonce, hash, hashRate))
			fmt.Printf("\nMatch found in %s!\n", elapsedTime)
			if *outputFilenameFlag != "" {
				WriteChainEncodedFile(outputFile, data, nonce)
			}
			if *outputDirFlag != "" {
				WriteChainEncodedFileToDir(filebasename, outputDir, data, nonce)
			}
			os.Exit(0)
		}

		// Increment the nonce and display the current hash rate
		nonce++
		if nonce%100000 == 0 {
			elapsedTime := time.Since(startTime)
			hashRate := float64(nonce) / elapsedTime.Seconds()
			StatusLine(fmt.Sprintf("Checking nonce %d... %.2f H/s", nonce, hashRate))
		}
	}
}

// WriteEncodedFile writes the encoded file contents and nonce to
// a new file with the extension ".blk" in the specified output directory
// WriteChainEncodedFile writes the encoded file contents and nonce to a file handle
func WriteChainEncodedFile(outputFile *os.File, fileContents []byte, nonce int) error {
	// Write the concatenated data to the output file
	_, err := outputFile.Write(fileContents)
	if err != nil {
		return err
	}

	return nil
}

// WriteEncodedFile writes the encoded file contents and nonce to
// a new file with the extension ".blk" in the specified output directory
func WriteChainEncodedFileToDir(filename string, outputDir string, fileContents []byte, nonce int) {
	if _, err := os.Stat(outputDir); os.IsNotExist(err) {
		// Create the output directory if it doesn't exist
		if err := os.MkdirAll(outputDir, 0755); err != nil {
			fmt.Println("Error: could not create output directory:", outputDir)
			os.Exit(1)
		}
	}

	outputFilename := filepath.Join(outputDir, filename+".blk")
	outputFile, err := os.Create(outputFilename)
	if err != nil {
		fmt.Println("Error: could not create output file:", outputFilename)
		os.Exit(1)
	}
	defer outputFile.Close()

	// Concatenate the encoded file contents and nonce
	data := fileContents

	// Write the concatenated data to the output file
	_, err = outputFile.Write(data)
	if err != nil {
		fmt.Println("Error: could not write output file:", outputFilename)
		os.Exit(1)
	}
}

// StatusLine is a helper function to display a status message on a single line of the console
func StatusLine(s string) {
	fmt.Printf("\r%s", s)
}
