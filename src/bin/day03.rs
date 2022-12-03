use std::collections::HashSet;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::sync::mpsc::{self, Receiver};
use std::sync::{Arc, Mutex};
use std::thread::{spawn, JoinHandle};

fn main() {
  let (p1_tx, p1_rx) = mpsc::channel();
  let (p2_tx, p2_rx) = mpsc::channel();
  let result = Arc::new(Mutex::new((0, 0)));

  let mut handles = vec![];
  handles.push(spawn_part1(p1_rx, Arc::clone(&result)));
  handles.push(spawn_part2(p2_rx, Arc::clone(&result)));

  let reader = BufReader::new(File::open("input/day03.txt").expect("bad open"));
  reader
    .lines()
    .map(|s| s.unwrap().trim().to_string())
    .for_each(|s| {
      p1_tx.send(s.clone()).expect("could not send to part 1");
      p2_tx.send(s).expect("could not send to part 2");
    });

  drop(p1_tx);
  drop(p2_tx);

  for h in handles {
    h.join().unwrap();
  }

  // this is totally unneccessary, and we could just lock the mutex instead
  let answers = Arc::try_unwrap(result).unwrap().into_inner().unwrap();

  println!("part 1: {}", answers.0);
  println!("part 2: {}", answers.1);
}

fn spawn_part1(rx: Receiver<String>, res: Arc<Mutex<(u32, u32)>>) -> JoinHandle<()> {
  spawn(move || {
    for line in rx.iter() {
      let mid = line.len() / 2;
      let (first, second) = line.split_at(mid);
      let f: HashSet<char> = first.chars().collect();
      let s: HashSet<char> = second.chars().collect();
      let item = f.intersection(&s).nth(0).expect("no intersection??");

      // unlock the mutex to write our result
      let mut res = res.lock().unwrap();
      res.0 = res.0 + value_for(item);
    }
  })
}

fn spawn_part2(rx: Receiver<String>, res: Arc<Mutex<(u32, u32)>>) -> JoinHandle<()> {
  spawn(move || {
    let mut group: Vec<HashSet<char>> = Vec::with_capacity(3);

    for line in rx.iter() {
      let chars: HashSet<char> = line.chars().collect();
      group.push(chars);

      if group.len() == 3 {
        let pair: HashSet<_> = group[0].intersection(&group[1]).copied().collect();
        let badge = pair.intersection(&group[2]).nth(0).unwrap();

        // write result to the second of the pair
        let mut res = res.lock().unwrap();
        res.1 = res.1 + value_for(badge);

        group.clear();
      }
    }
  })
}

fn value_for(c: &char) -> u32 {
  let ord = *c as u32;

  if c.is_ascii_lowercase() {
    ord - ('a' as u32) + 1
  } else {
    ord - ('A' as u32) + 27
  }
}
