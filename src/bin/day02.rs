use std::cmp::Ordering;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::sync::mpsc::{self, Receiver, Sender};
use std::thread::{spawn, JoinHandle};

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
  let (tx, rx) = mpsc::channel();
  let (p1_tx, p1_rx) = mpsc::channel();
  let (p2_tx, p2_rx) = mpsc::channel();

  let mut handles = vec![];

  handles.push(spawn_plexer(rx, p1_tx, p2_tx));
  handles.push(spawn_part1(p1_rx));
  handles.push(spawn_part2(p2_rx));

  // main thread will do the reading
  let reader = BufReader::new(File::open("input/day02.txt").expect("bad open"));
  reader.lines().for_each(|line| {
    let chars = line.unwrap().chars().collect::<Vec<_>>();
    let a = chars.get(0).unwrap().clone();
    let b = chars.get(2).unwrap().clone();
    tx.send((a, b)).expect("could not send?");
  });

  drop(tx); // tell everyone else we're all done

  for h in handles {
    h.join().unwrap();
  }

  Ok(())
}

// We need this because rust stdlib doesn't have mpmc or similar (it's in
// crossbeam)
fn spawn_plexer(
  rx: Receiver<(char, char)>,
  p1_tx: Sender<(RPS, RPS)>,
  p2_tx: Sender<(RPS, Outcome)>,
) -> JoinHandle<()> {
  spawn(move || {
    for (ref a, ref b) in rx.iter() {
      let them: RPS = a.into();
      let me: RPS = b.into();
      let outcome: Outcome = b.into();

      p1_tx
        .send((them.clone(), me))
        .expect("could not send to part 1");

      p2_tx
        .send((them, outcome))
        .expect("could not send to part 2");
    }
  })
}

fn spawn_part1(rx: Receiver<(RPS, RPS)>) -> JoinHandle<()> {
  // part 1
  spawn(move || {
    let mut sum = 0;

    for (ref them, ref me) in rx.iter() {
      sum += score_game(them, me);
    }

    println!("part 1: {sum}");
  })
}

fn spawn_part2(rx: Receiver<(RPS, Outcome)>) -> JoinHandle<()> {
  spawn(move || {
    let mut sum = 0;

    for (ref them, ref outcome) in rx.iter() {
      sum += score_choice(them, outcome);
    }

    println!("part 2: {sum}");
  })
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
