package main

import (
	"fmt"
	"slices"
	"strings"

	"github.com/mmcclimon/advent-2022/advent"
)

func main() {
	scanner := advent.ScannerForArgv()
	var total1 int
	var total2 int

	for scanner.Scan() {
		game := NewGame(scanner.Text())
		total1 += game.Score1()
		total2 += game.Score2()
	}

	fmt.Println(total1)
	fmt.Println(total2)
}

type Sign int

const (
	Rock Sign = iota
	Paper
	Scissors
)

type Result int

const (
	Win  Result = 6
	Draw Result = 3
	Lose Result = 0
)

var rps = []Sign{Rock, Paper, Scissors}

type Game struct {
	opponent Sign
	player   Sign
	outcome  Result
}

func NewGame(line string) Game {
	f := strings.Fields(line)
	return Game{
		opponent: SignFrom(f[0]),
		player:   SignFrom(f[1]),
		outcome:  ResultFrom(f[1]),
	}
}

func SignFrom(text string) Sign {
	return map[string]Sign{
		"A": Rock, "X": Rock,
		"B": Paper, "Y": Paper,
		"C": Scissors, "Z": Scissors,
	}[text]
}

func ResultFrom(text string) Result {
	return map[string]Result{
		"X": Lose,
		"Y": Draw,
		"Z": Win,
	}[text]
}

func (g Game) Score1() int {
	return g.player.Score() + int(g.player.Versus(g.opponent))
}

func (g Game) Score2() int {
	return int(g.outcome) + g.opponent.ForOutcome(g.outcome).Score()
}

func mod(n int, div int) int {
	return (n%div + div) % div
}

func (s Sign) Versus(other Sign) Result {
	idx := slices.Index(rps, s)
	otherIdx := slices.Index(rps, other)
	return []Result{Draw, Win, Lose}[mod(idx-otherIdx, 3)]
}

func (s Sign) Score() int {
	idx := slices.Index(rps, s)
	return idx + 1
}

func (s Sign) ForOutcome(r Result) Sign {
	idx := slices.Index(rps, s)
	add := map[Result]int{
		Draw: 0,
		Win:  1,
		Lose: -1,
	}[r]

	return rps[mod(idx+add, 3)]
}
