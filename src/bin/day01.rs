use std::collections::BTreeSet;
use std::fs::File;
use std::io::{prelude::*, BufReader};

fn main() -> Result<(), std::io::Error> {
  let reader = BufReader::new(File::open("input/day01.txt")?);

  let mut vals: BTreeSet<u32> = BTreeSet::new();
  let mut cur: u32 = 0;

  for line in reader.lines().map(|l| l.unwrap().trim().to_string()) {
    if line.is_empty() {
      vals.insert(cur);
      cur = 0;
      continue;
    }

    let val: u32 = line.parse().expect("bad int");
    cur += val;
  }

  let top = vals.iter().rev().take(3).collect::<Vec<_>>();

  println!("part 1: {}", top[0]);
  println!("part 2: {}", top.iter().copied().sum::<u32>());

  Ok(())
}
