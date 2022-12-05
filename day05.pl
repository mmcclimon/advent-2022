use v5.36;
use Data::Dumper::Concise;

my $test = <<EOF;
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
EOF

# open my $in, '<', \$test or die "bad open: $!";
open my $in, '<', 'input/day05.txt' or die "bad open: $!";

my @ship_lines;
{
  local $/ = "\n\n";
  my $ship = <$in>;
  (undef, @ship_lines) = reverse grep {; length } split /\n/, $ship;
}

my (@stacks1, @stacks2);

for my $line (@ship_lines) {
  my $n = 0;

  for my $crate (unpack '(a4)*', $line) {
    $n++;
    $crate =~ s/[^A-Z]*//g;
    next unless $crate;

    push $stacks1[$n]->@*, $crate;
    push $stacks2[$n]->@*, $crate;
  }
}

while (my $line = <$in>) {
  my ($n, $from, $to) = $line =~ /move (\d+) from (\d+) to (\d+)/;
  push $stacks1[$to]->@*, pop $stacks1[$from]->@*  for 1..$n;
  push $stacks2[$to]->@*, splice $stacks2[$from]->@*, -1 * $n;
}

say "part 1: " . join '', map {; $_->[-1] // '' } @stacks1;
say "part 2: " . join '', map {; $_->[-1] // '' } @stacks2;
