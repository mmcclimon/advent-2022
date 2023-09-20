package main

import (
	"fmt"
	"slices"
	"strconv"

	"github.com/mmcclimon/advent-2022/advent"
)

func main() {
	scanner := advent.ScannerForArgv()

	calories := make([]int, 0)
	cur := 0

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			calories = append(calories, cur)
			cur = 0
			continue
		}

		n, _ := strconv.Atoi(line)
		cur += n
	}

	calories = append(calories, cur)
	slices.Sort(calories)
	slices.Reverse(calories)

	fmt.Printf("part 1: %d\n", calories[0])
	fmt.Printf("part 2: %d\n", calories[0]+calories[1]+calories[2])
}
