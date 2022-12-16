use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use std::io::{prelude::*, BufReader};

type Coord = (isize, isize);

fn main() {
  let reader = BufReader::new(File::open("input/day15.txt").expect("bad open"));

  let mut beacons = HashSet::new();
  let mut sensors = HashMap::new();

  let re =
    Regex::new(r"x=([-0-9]+), y=([-0-9]+):.*x=([-0-9]+), y=([-0-9]+)").unwrap();

  for line in reader.lines().map(|l| l.unwrap().trim().to_string()) {
    let matches = re.captures(&line).unwrap();

    let sensor: Coord = (matches[1].parse().unwrap(), matches[2].parse().unwrap());
    let beacon: Coord = (matches[3].parse().unwrap(), matches[4].parse().unwrap());

    let dist = (sensor.0 - beacon.0).abs() + (sensor.1 - beacon.1).abs();
    beacons.insert(beacon);
    sensors.insert(sensor, dist);
  }

  part1(&sensors, &beacons);
  part2(&sensors);
}

fn part1(sensors: &HashMap<Coord, isize>, beacons: &HashSet<Coord>) {
  let target = 2_000_000;

  let mut pos = HashSet::new();

  for ((x, y), dist) in sensors.iter() {
    let dt = dist - (y - target).abs();

    if dt <= 0 {
      continue;
    }

    let start = x - dt;
    let end = x + dt;
    for this_x in start..=end {
      let tup = (this_x, target);
      if !beacons.contains(&tup) {
        pos.insert(tup);
      }
    }
  }

  println!("part 1: {}", pos.len());
}

fn part2(sensors: &HashMap<Coord, isize>) {
  let max = 4_000_000;

  // keys are y values, values are [[ax1,ax2], [bx1,bx2]]
  let mut blocked = HashMap::new();

  for ((x, y), dist) in sensors.iter() {
    for this_y in (y - dist)..=(y + dist) {
      let xrange = dist - (y - this_y).abs();
      if !blocked.contains_key(&this_y) {
        blocked.insert(this_y, vec![]);
      }

      let vals = blocked.get_mut(&this_y).expect("no key for {y}");
      vals.push((x - xrange, x + xrange));
    }
  }

  'outer: for (y, pairs) in blocked.iter_mut() {
    if y < &&0 || y > &&max {
      continue;
    }

    pairs.sort_unstable_by_key(|pair| pair.0);

    let mut right = 0; // rightmost point on this line

    for (start, end) in pairs.iter() {
      if start <= &(right + 1) && &(right + 1) <= end {
        right = *end;

        if right > max {
          continue 'outer;
        }
      }
    }

    // all done!
    println!("part 2: {}", ((right + 1) * 4_000_000) + y);
    return;
  }
}
