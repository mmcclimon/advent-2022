package main

import (
	"fmt"
	"unicode"

	"github.com/mmcclimon/advent-2022/advent"
)

func main() {
	scanner := advent.ScannerForArgv()

	sum1 := int32(0)
	sum2 := int32(0)

	n := 0
	group := make([]advent.Set[rune], 3)

	for scanner.Scan() {
		line := scanner.Text()

		// Part 1
		mid := len(line) / 2
		a, b := line[:mid], line[mid:]
		as := advent.NewSet([]rune(a)...)
		bs := advent.NewSet([]rune(b)...)
		common := as.Intersection(bs).AnElem()

		sum1 += priority(common)

		// Part 2
		group[n] = advent.NewSet([]rune(line)...)
		n++
		if n == 3 {
			common := group[0].Intersection(group[1]).Intersection(group[2]).AnElem()
			sum2 += priority(common)
			n = 0
		}
	}

	fmt.Println(sum1)
	fmt.Println(sum2)
}

func priority(c rune) rune {
	p := 1 + c - 'a'
	if unicode.IsUpper(c) {
		p = 27 + c - 'A'
	}

	return p
}
