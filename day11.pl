use v5.36;

open my $in, '<', 'input/day11.txt' or die "bad open: $!";

my @hunks = do { local $/ = "\n\n"; <$in> };
my $set = MonkeySet->new([ map {; Monkey->from_hunk($_) } @hunks ]);
my $lcm = $set->lcm;

say "part 1: " . $set->do_rounds(20,     sub ($n) { int($n / 3) });
say "part 2: " . $set->do_rounds(10_000, sub ($n) { $n % $lcm   });

package Monkey {
  sub from_hunk ($class, $hunk) {
    my ($number, $items, $oper, $test, $true, $false) = split /\n/, $hunk;

    my ($num) = $number =~ /Monkey (\d+)/;
    my @items = split /, /, ($items =~ s/^\s+Starting items: //r);
    my ($left, $op, $right) = $oper =~ /Operation: new = (\w+) (.) (\w+)/;
    my ($divisor) = $test =~ /divisible by (\d+)/;
    my ($t_monkey) = $true =~ /throw to monkey (\d+)/;
    my ($f_monkey) = $false =~ /throw to monkey (\d+)/;

    my sub build_worry_op {
      state %ops = (
        '*' => sub ($x, $y) { $x * $y },
        '+' => sub ($x, $y) { $x + $y },
        '/' => sub ($x, $y) { $x / $y },
        '-' => sub ($x, $y) { $x - $y },
      );

      my $sub = $ops{$op};

      return sub ($item) {
        my $left_op  = $left  eq 'old' ? $item : 0 + $left;
        my $right_op = $right eq 'old' ? $item : 0 + $right;
        return $sub->($left_op, $right_op);
      };
    }

    return bless {
      number     => $num,
      items      => \@items,
      worry_op   => build_worry_op(),
      toss_op    => sub ($val) { $val % $divisor == 0 ? $t_monkey : $f_monkey },
      divisor    => $divisor,
      total_seen => 0,
      starting_items => [ @items ],
    }, $class;
  }

  sub take_turn ($self, $adjust) {
    my @ret;

    while (my $item = shift $self->{items}->@*) {
      $self->{total_seen}++;

      $item = $self->{worry_op}->($item);
      $item = $adjust->($item);

      my $to = $self->{toss_op}->($item);
      push @ret, [$to => $item];
    }

    return @ret;
  }

  sub add_item ($self, $item) {
    push $self->{items}->@*, $item;
  }

  sub reset ($self) {
    $self->{total_seen} = 0;
    $self->{items} = [ $self->{starting_items}->@* ];
  }

  sub items_seen { $_[0]->{total_seen} }
  sub divisor    { $_[0]->{divisor}    }
}

package MonkeySet {
  sub new ($class, $monkeys) { bless $monkeys, $class }

  sub lcm ($self) {
    state $lcm //= do {
      my $lcm = 1;
      $lcm *= $_->divisor for @$self;
      $lcm
    };

    return $lcm;
  }

  sub do_rounds ($self, $n_rounds, $adjust) {
    $_->reset for @$self;

    for (1..$n_rounds) {
      $self->do_round($adjust);
    }

    my ($x, $y) = sort { $b <=> $a } map {; $_->items_seen } @$self;
    return $x * $y;
  }


  sub do_round ($self, $part) {
    for my $monkey (@$self) {
      my @to_distribute = $monkey->take_turn($part);
      for my $pair (@to_distribute) {
        my ($n, $item) = @$pair;
        $self->[$n]->add_item($item);
      }
    }
  }
}
