package advent

import (
	"bufio"
	"fmt"
	"os"
)

func Assert(cond bool, msg string, args ...any) {
	if cond {
		return
	}

	fmt.Printf(msg+"\n", args...)
	os.Exit(1)
}

func ScannerForArgv() *bufio.Scanner {
	Assert(len(os.Args) > 1, "need a file name to read")

	f, err := os.Open(os.Args[1])
	Assert(err == nil, "couldn't open file: %s", err)

	return bufio.NewScanner(f)
}
