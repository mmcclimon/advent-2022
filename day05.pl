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

my $ship;
{
  local $/ = "\n\n";
  $ship = <$in>;
}

# read the ship
my @ship_lines = reverse grep {; length } split /\n/, $ship;

# header
my @keys = grep {; /\d/ } split /(\d)/, shift @ship_lines;

my @stacks1;
my @stacks2;

for my $line (@ship_lines) {
  my $n = 0;

  while ($line) {
    $n++;

    my $crate = substr $line, 0, 4, '';
    next unless $crate =~ /[A-Z]/;

    $crate =~ s/[^A-Z]*//g;
    push $stacks1[$n]->@*, $crate;
    push $stacks2[$n]->@*, $crate;
  }
}

while (my $line = <$in>) {
  my ($n, $from, $to) = $line =~ /move (\d+) from (\d+) to (\d+)/;

  # part 1
  for (1..$n) {
    push $stacks1[$to]->@*, pop $stacks1[$from]->@*;
  }

  # part 2
  my @to_push;
  for (1..$n) {
    push @to_push, pop $stacks2[$from]->@*;
  }

  push $stacks2[$to]->@*, reverse @to_push;
}

my $answer1 = join '', map {; $_->[-1] } grep {; defined } @stacks1;
my $answer2 = join '', map {; $_->[-1] } grep {; defined } @stacks2;

say $answer1;
say $answer2;
