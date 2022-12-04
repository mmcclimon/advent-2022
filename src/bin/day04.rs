use std::fs::File;
use std::io::{prelude::*, BufReader};

#[derive(Debug)]
struct Assignment(u32, u32);

#[derive(Debug)]
struct Pair {
  left: Assignment,
  right: Assignment,
}

fn main() {
  let reader = BufReader::new(File::open("input/day04.txt").expect("bad open"));

  let (subsumed, overlap) =
    reader
      .lines()
      .map(|l| Pair::from(l.unwrap()))
      .fold((0, 0), |acc, pair| {
        (
          acc.0 + pair.left.subsumes(&pair.right) as u32,
          acc.1 + pair.left.overlaps(&pair.right) as u32,
        )
      });

  println!("part 1: {}", subsumed);
  println!("part 2: {}", overlap);
}

impl Pair {
  fn new(a: Assignment, b: Assignment) -> Self {
    if a.start() == b.start() {
      let (left, right) = if a.end() > b.end() { (a, b) } else { (b, a) };
      Pair { left, right }
    } else if a.start() < b.start() {
      Pair { left: a, right: b }
    } else {
      Pair { left: b, right: a }
    }
  }
}

impl Assignment {
  fn start(&self) -> u32 {
    self.0
  }

  fn end(&self) -> u32 {
    self.1
  }

  fn subsumes(&self, other: &Assignment) -> bool {
    self.overlaps(other) && self.end() >= other.end()
  }

  fn overlaps(&self, other: &Assignment) -> bool {
    other.start() <= self.end()
  }
}

impl From<String> for Pair {
  fn from(line: String) -> Self {
    let mut vec = line.split(',').map(|half| Assignment::from(half));
    Pair::new(vec.next().unwrap(), vec.next().unwrap())
  }
}

impl From<&str> for Assignment {
  fn from(s: &str) -> Self {
    let mut nums = s.split('-').map(|n| n.parse::<u32>().unwrap());
    Assignment(nums.next().unwrap(), nums.next().unwrap())
  }
}
