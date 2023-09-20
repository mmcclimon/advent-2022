package main

import "testing"

func TestVersus(t *testing.T) {
	tests := []struct {
		a, b   Sign
		expect Result
	}{
		{Rock, Rock, Draw},
		{Paper, Paper, Draw},
		{Scissors, Scissors, Draw},
		{Rock, Scissors, Win},
		{Scissors, Paper, Win},
		{Paper, Rock, Win},
		{Rock, Paper, Lose},
		{Scissors, Rock, Lose},
		{Paper, Scissors, Lose},
	}

	for _, test := range tests {
		if test.a.Versus(test.b) != test.expect {
			t.Logf("%d.Versus(%d) == %d", test.a, test.b, test.expect)
			t.Fail()
		}
	}

}

func TestForOutcome(t *testing.T) {
	tests := []struct {
		s      Sign
		r      Result
		expect Sign
	}{
		{Rock, Draw, Rock},
		{Paper, Draw, Paper},
		{Scissors, Draw, Scissors},
		{Rock, Win, Paper},
		{Scissors, Win, Rock},
		{Paper, Win, Scissors},
		{Rock, Lose, Scissors},
		{Paper, Lose, Rock},
		{Scissors, Lose, Paper},
	}

	for _, test := range tests {
		if test.s.ForOutcome(test.r) != test.expect {
			t.Logf("%d.ForOutcome(%d) == %d", test.s, test.r, test.expect)
			t.Fail()
		}
	}
}
