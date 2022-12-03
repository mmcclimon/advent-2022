use std::cmp::Ordering;
use std::fs::File;
use std::io::{prelude::*, BufReader};

#[derive(Debug, Eq, PartialEq, Ord, Clone)]
enum RPS {
  Rock,
  Paper,
  Scissors,
}

#[derive(Debug, Eq, PartialEq)]
enum Outcome {
  Lose,
  Draw,
  Win,
}

fn main() -> Result<(), std::io::Error> {
  let reader = BufReader::new(File::open("input/day02.txt")?);

  let tups = reader
    .lines()
    .map(|line| {
      let chars = line.unwrap().chars().collect::<Vec<_>>();
      let a: RPS = chars.get(0).unwrap().into();
      let b: RPS = chars.get(2).unwrap().into();
      let c: Outcome = chars.get(2).unwrap().into();

      (a, b, c)
    })
    .collect::<Vec<_>>();

  let part1: u32 = tups
    .iter()
    .map(|(them, me, _)| score_game(&them, &me))
    .sum();

  let part2: u32 = tups
    .iter()
    .map(|(them, _, outcome)| score_choice(&them, &outcome))
    .sum();

  println!("part 1: {part1}");
  println!("part 1: {part2}");

  Ok(())
}

fn score_game(them: &RPS, me: &RPS) -> u32 {
  let outcome = if them > me {
    Outcome::Lose // I lose
  } else if me > them {
    Outcome::Win
  } else {
    Outcome::Draw
  };

  me.score() + outcome.score()
}

fn score_choice(them: &RPS, outcome: &Outcome) -> u32 {
  let choice = match outcome {
    Outcome::Lose => them.losing_choice(),
    Outcome::Draw => them.clone(),
    Outcome::Win => them.winning_choice(),
  };

  return choice.score() + outcome.score();
}

impl RPS {
  fn score(&self) -> u32 {
    match self {
      RPS::Rock => 1,
      RPS::Paper => 2,
      RPS::Scissors => 3,
    }
  }

  fn losing_choice(&self) -> RPS {
    match self {
      RPS::Rock => RPS::Scissors,
      RPS::Paper => RPS::Rock,
      RPS::Scissors => RPS::Paper,
    }
  }

  fn winning_choice(&self) -> RPS {
    match self {
      RPS::Rock => RPS::Paper,
      RPS::Paper => RPS::Scissors,
      RPS::Scissors => RPS::Rock,
    }
  }
}

impl Outcome {
  fn score(&self) -> u32 {
    match self {
      Outcome::Lose => 0,
      Outcome::Draw => 3,
      Outcome::Win => 6,
    }
  }
}

impl From<&char> for RPS {
  fn from(c: &char) -> Self {
    match c {
      'A' | 'X' => RPS::Rock,
      'B' | 'Y' => RPS::Paper,
      'C' | 'Z' => RPS::Scissors,
      _ => unreachable!(),
    }
  }
}

impl From<&char> for Outcome {
  fn from(c: &char) -> Self {
    match c {
      'X' => Outcome::Lose,
      'Y' => Outcome::Draw,
      'Z' => Outcome::Win,
      _ => unreachable!(),
    }
  }
}

impl PartialOrd for RPS {
  fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
    if self == other {
      return Some(Ordering::Equal);
    }

    match self {
      RPS::Rock => {
        if other == &RPS::Paper {
          Some(Ordering::Less)
        } else {
          Some(Ordering::Greater)
        }
      },
      RPS::Paper => {
        if other == &RPS::Scissors {
          Some(Ordering::Less)
        } else {
          Some(Ordering::Greater)
        }
      },
      RPS::Scissors => {
        if other == &RPS::Rock {
          Some(Ordering::Less)
        } else {
          Some(Ordering::Greater)
        }
      },
    }
  }
}
