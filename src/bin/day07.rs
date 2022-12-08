use std::collections::HashMap;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::PathBuf;

fn main() {
  let sizes = read_sizes();

  let sum: usize = sizes.values().filter(|v| **v <= 100_000).map(|v| *v).sum();
  println!("part 1: {sum}");

  let unused = 70_000_000 - sizes.get("/").unwrap();
  let mut sizes = sizes
    .into_values()
    .filter(|size| unused + size >= 30_000_000)
    .collect::<Vec<_>>();

  sizes.sort();
  println!("part 2: {}", sizes[0]);
}

fn read_sizes() -> HashMap<String, usize> {
  let reader = BufReader::new(File::open("input/day07.txt").expect("bad open"));

  let mut sizes = HashMap::new();
  let mut pwd = PathBuf::new();

  for line in reader
    .lines()
    .map(|l| l.unwrap().trim().to_string())
    .filter(|l| !l.is_empty() && l != "$ ls" && !l.starts_with("dir"))
  {
    if let Some(target) = line.strip_prefix("$ cd ") {
      #[rustfmt::skip]
      match target {
        "/" => pwd.push("/"),
        ".." => { pwd.pop(); },
        dir => pwd.push(dir),
      };

      continue;
    }

    let size: usize = line.split(' ').next().expect("bad size??").parse().unwrap();

    for dir in pwd.ancestors().map(|d| d.display().to_string()) {
      let have = sizes.get(&dir).unwrap_or(&0);
      sizes.insert(dir, have + size);
    }
  }

  sizes
}
