use v5.36;

my %monkeys = do {
  open my $in, '<', 'input/day21.txt' or die "bad open: $!";
  map {; chomp && split /: /} <$in>;
};

my %monkeys2 = %monkeys;
$monkeys2{root} =~ s![-+*/]!=!;

my $NUMBER_RE = qr{\A[-0-9]+\z};
my %OPS = (
  '+' => sub { $_[0] + $_[1] },
  '-' => sub { $_[0] - $_[1] },
  '*' => sub { $_[0] * $_[1] },
  '/' => sub { $_[0] / $_[1] },
);

say "part 1: " . part1('root');
say "part 2: " . part2();

sub part1 ($name) {
  my $val = $monkeys{$name};
  return $val if $val =~ $NUMBER_RE;

  my ($l, $op, $r) = split /\s+/, $val;

  my $left = part1($l);
  my $right = part1($r);

  $monkeys{$name} = $OPS{$op}->($left, $right);
  return $monkeys{$name};
}

sub part2 {
  # We preprocess everything to replace everything we can with real numbers
  preprocess_part2('root');

  # and then walk down from the root, computing as we go. We could do this in
  # one step by building a bunch of subrefs as we walk the first time, but
  # this is faster.
  return walk_part2('root');
}

sub preprocess_part2 ($name) {
  return '<humn>' if $name eq 'humn';

  my $val = $monkeys2{$name};
  return $val if $val =~ $NUMBER_RE;

  my ($l, $op, $r) = split /\s+/, $val;

  my $left = preprocess_part2($l);
  my $right = preprocess_part2($r);

  if ($left eq '<humn>') {
    $monkeys2{$name} =~ s/$r/$right/;
    return '<humn>';
  }

  if ($right eq '<humn>') {
    $monkeys2{$name} =~ s/$l/$left/;
    return '<humn>';
  }

  $monkeys2{$name} = $OPS{$op}->($left, $right);
  return $monkeys2{$name};
}

sub walk_part2 ($name, $value = 0) {
  return $value if $name eq 'humn';

  my ($l, $op, $r) = split /\s+/, $monkeys2{$name};

  my $left_known = $l =~ $NUMBER_RE;
  my ($known, $var) = $left_known ? ($l, $r) : ($r, $l);

  my $got = $op eq '=' ? $known
          : $op eq '+' ? $value - $known
          : $op eq '*' ? $value / $known
          : $op eq '-' ? ($left_known ? $known - $value : $known + $value)
          : $op eq '/' ? ($left_known ? $known / $value : $known * $value)
          : die 'wat';

  return walk_part2($var, $got);
}
