use v5.36;

open my $in, '<', 'input/day11.txt' or die "bad open: $!";

my @hunks = do { local $/ = "\n\n"; <$in> };
my @monkeys = map {; Monkey->from_hunk($_) } @hunks;

my $GLOBAL_LCM = 1;
$GLOBAL_LCM *= $_->divisor for @monkeys;

sub do_round ($part) {
  for my $monkey (@monkeys) {
    my @to_distribute = $monkey->take_turn($part);
    for my $pair (@to_distribute) {
      my ($n, $item) = @$pair;
      $monkeys[$n]->add_item($item);
    }
  }
}

sub calc_result {
  my ($x, $y) = sort { $b <=> $a } map {; $_->items_seen } @monkeys;
  return $x * $y;
}

do_round(1) for 1..20;
say "part 1: " . calc_result();

$_->reset for @monkeys;

do_round(2) for 1..10_000;
say "part 2: " . calc_result();


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

  sub take_turn ($self, $part) {
    my @ret;

    while (my $item = shift $self->{items}->@*) {
      push @ret, $self->consider_item($item, $part);
    }

    return @ret;
  }

  sub consider_item ($self, $item, $part) {
    $self->{total_seen}++;
    $item = $self->{worry_op}->($item);

    if ($part == 1) {
      $item = int($item / 3);
    }

    $item %= $GLOBAL_LCM;

    my $to = $self->{toss_op}->($item);
    return [$to => $item];
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
