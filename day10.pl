use v5.36;

open my $in, '<', 'input/day10.txt' or die "bad open: $!";

my @directions = <$in>;

my $x = 1;
my $val;

my $sum = 0;
my $crt = '';

for (my $i = 1; @directions; $i++) {
  # part 1
  $sum += $i * $x if ($i - 20) % 40 == 0;

  # part 2
  my $xpos = ($i - 1) % 40;
  $crt .= abs($x - $xpos) <= 1 ? '█' : ' ';
  $crt .= "\n" if $xpos == 39;

  if ($val) {
    $x += $val;
    $val = 0;
  } else {
    (undef, $val) = split /\s/, shift @directions;
  }
}

say "part 1: $sum";
say "part 2:\n\n$crt";
