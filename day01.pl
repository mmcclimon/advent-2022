use v5.36;

local $/ = "\n\n";
open my $fh, '<', 'input/day01.txt' or die "bad open: $!";

my @cals;

while (my $hunk = <$fh>) {
  my $cur = 0;
  $cur += $_ for split /\n/, $hunk;
  push @cals, $cur;
}

my ($one, $two, $three) = sort { $b <=> $a } @cals;

say 'part 1: ' . $one;
say 'part 2: ' . ($one + $two + $three);
