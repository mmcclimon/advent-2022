use v5.36;

open my $in, '<', 'input/day04.txt' or die "bad open: $!";

my $bad1 = 0;
my $bad2 = 0;

while (my $line = <$in>) {
  chomp $line;
  my ($ls, $le, $rs, $re) = $line =~ /(\d+)-(\d+),(\d+)-(\d+)/;

  if ($ls == $rs) {
    $bad1++;
    $bad2++;
  } elsif ($ls < $rs) {
    $bad1++ if $rs <= $le && $re <= $le;
    $bad2++ if $rs <= $le;
  } else {
    $bad1++ if $ls <= $re && $le <= $re;
    $bad2++ if $ls <= $re;
  }
}

say "part 1: $bad1";
say "part 2: $bad2";
