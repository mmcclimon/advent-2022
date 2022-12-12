use std::cell::RefCell;
use std::collections::VecDeque;

#[derive(Debug, Clone)]
enum Operand {
  Old,
  Constant(u64),
}

#[derive(Debug, Clone)]
enum Operator {
  Plus,
  Times,
}

#[derive(Debug, Clone)]
struct Monkey {
  items: RefCell<VecDeque<u64>>,
  total_seen: RefCell<usize>,
  op: (Operand, Operator, Operand),
  divisor: u64,
  if_true: usize,
  if_false: usize,
}

fn main() {
  let monkeys = vec![
    Monkey {
      items: RefCell::new(VecDeque::from([72, 97])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Times, Operand::Constant(13)),
      divisor: 19,
      if_true: 5,
      if_false: 6,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([55, 70, 90, 74, 95])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Times, Operand::Old),
      divisor: 7,
      if_true: 5,
      if_false: 0,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([74, 97, 66, 57])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Plus, Operand::Constant(6)),
      divisor: 17,
      if_true: 1,
      if_false: 0,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([86, 54, 53])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Plus, Operand::Constant(2)),
      divisor: 13,
      if_true: 1,
      if_false: 2,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([50, 65, 78, 50, 62, 99])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Plus, Operand::Constant(3)),
      divisor: 11,
      if_true: 3,
      if_false: 7,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([90])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Plus, Operand::Constant(4)),
      divisor: 2,
      if_true: 4,
      if_false: 6,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([88, 92, 63, 94, 96, 82, 53, 53])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Plus, Operand::Constant(8)),
      divisor: 5,
      if_true: 4,
      if_false: 7,
    },
    Monkey {
      items: RefCell::new(VecDeque::from([70, 60, 71, 69, 77, 70, 98])),
      total_seen: RefCell::new(0),
      op: (Operand::Old, Operator::Times, Operand::Constant(7)),
      divisor: 3,
      if_true: 2,
      if_false: 3,
    },
  ];

  let lcm = monkeys
    .iter()
    .map(|m| m.divisor)
    .reduce(|acc, item| acc * item)
    .unwrap();

  let monkeys2 = monkeys.clone();

  for _ in 0..20 {
    for monkey in monkeys.iter() {
      let to_distribute = monkey.take_turn(true, lcm);

      for (n, item) in to_distribute {
        monkeys[n].add_item(item);
      }
    }
  }

  let mut seen = monkeys
    .iter()
    .map(|m| m.total_seen.borrow().clone())
    .collect::<Vec<_>>();

  seen.sort_unstable_by(|a, b| b.cmp(a));
  println!("part 1: {}", seen[0] * seen[1]);

  // part 2
  for _ in 0..10_000 {
    for monkey in monkeys2.iter() {
      let to_distribute = monkey.take_turn(false, lcm);

      for (n, item) in to_distribute {
        monkeys2[n].add_item(item);
      }
    }
  }

  let mut seen2 = monkeys2
    .iter()
    .map(|m| m.total_seen.borrow().clone())
    .collect::<Vec<_>>();

  seen2.sort_unstable_by(|a, b| b.cmp(a));
  println!("part 2: {}", seen2[0] * seen2[1]);
}

impl Monkey {
  fn take_turn(&self, part_one: bool, lcm: u64) -> Vec<(usize, u64)> {
    let mut ret = vec![];
    let items = self.items.replace(VecDeque::new());

    for mut item in items.into_iter() {
      let mut seen = self.total_seen.borrow_mut();
      *seen += 1;

      item = self.worry_op(item);

      if part_one {
        item = item.div_euclid(3);
      }

      item = item.rem_euclid(lcm);

      ret.push(self.toss_op(item))
    }

    ret
  }

  fn worry_op(&self, item: u64) -> u64 {
    let left = match self.op.0 {
      Operand::Old => item,
      Operand::Constant(n) => n,
    };

    let right = match self.op.2 {
      Operand::Old => item,
      Operand::Constant(n) => n,
    };

    match self.op.1 {
      Operator::Times => left * right,
      Operator::Plus => left + right,
    }
  }

  fn toss_op(&self, item: u64) -> (usize, u64) {
    if item.rem_euclid(self.divisor) == 0 {
      (self.if_true, item)
    } else {
      (self.if_false, item)
    }
  }

  fn add_item(&self, item: u64) {
    self.items.borrow_mut().push_back(item);
  }
}
