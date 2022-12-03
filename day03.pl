use v5.36;

# open my $in, '<', \$test or die "bad open: $!";
open my $in, '<', 'input/day03.txt' or die "bad open: $!";

sub score_for ($c) {
  state $offset_l = ord('a') - 1;
  state $offset_u = ord('A') - 27;
  return ord($c) - ($c ge 'a' ? $offset_l : $offset_u);
}

my $sum1 = 0;
my $sum2 = 0;
my $n = 1;
my %group;

for my $line (<$in>) {
  chomp $line;

  my @chars = split //, $line;
  $group{$_}++ for keys { map {; $_ => 1 } @chars }->%*;

  # part 1
  my %first = map {; $_ => 1 } splice @chars, 0, @chars / 2;

  for my $c (@chars) {
    if ($first{$c}) {
      $sum1 += score_for($c);
      last;
    }
  }

  # part 2
  if ($n++ == 3) {
    my ($badge) = grep {; $group{$_} == 3 } keys %group;
    $sum2 += score_for($badge);

    $n = 1;
    %group = ();
  }
}

say "part 1: $sum1";
say "part 2: $sum2";
