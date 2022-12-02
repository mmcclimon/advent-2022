use v5.36;

open my $in, '<', 'input/day02.txt' or die "bad open: $!";

sub result1 ($them, $me) {
  return $me eq 'X' ? 3 : $me eq 'Y' ? 6 : 0 if $them eq 'A';
  return $me eq 'X' ? 0 : $me eq 'Y' ? 3 : 6 if $them eq 'B';
  return $me eq 'X' ? 6 : $me eq 'Y' ? 0 : 3;
}

sub result2 ($them, $res) {
  return $res eq 'X' ? 3 : $res eq 'Y' ? 1 : 2 if $them eq 'A';
  return $res eq 'X' ? 1 : $res eq 'Y' ? 2 : 3 if $them eq 'B';
  return $res eq 'X' ? 2 : $res eq 'Y' ? 3 : 1;
}

my ($total1, $total2);

for my $line (<$in>) {
  my ($them, $me) = split /\s+/, $line;
  $total1 += ($me eq 'X' ? 1 : $me eq 'Y' ? 2 : 3) + result1($them, $me);
  $total2 += ($me eq 'X' ? 0 : $me eq 'Y' ? 3 : 6) + result2($them, $me);
}

say "part 1: $total1";
say "part 2: $total2";
