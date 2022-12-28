use v5.36;

open my $in, '<', 'input/day25.txt' or die "bad open: $!";

run_tests();

my $sum = 0;
while (my $line = <$in>) {
  chomp $line;
  $sum += snafu_to_dec($line);
}

say dec_to_snafu($sum);

sub snafu_to_dec ($s) {
  my $pow = 0;
  my $num = 0;

  for my $digit (reverse split //, $s) {
    my $place = $digit eq '-' ? -1 : $digit eq '=' ? -2 : $digit;
    $num += (5 ** $pow++) * $place;
  }

  return $num;
}

sub dec_to_snafu ($n) {
  my @digits;
  my $pow = int(log($n) / log(5));

  while ($pow >= 0) {
    my $place = 5 ** $pow--;
    my $got = int($n / $place);
    $n -= $got * $place;
    unshift @digits, $got;
  }

  my @snafu;

  # now, we need to walk down the digits, carrying as necessary!
  for (my $i = 0; $i < @digits; $i++) {
    my $num = $digits[$i];

    while ($num >= 5) {
      $digits[$i + 1]++;
      $num -= 5;
    }

    $digits[$i + 1]++ if $num == 3 || $num == 4;
    push @snafu, $num == 3 ? '=' : $num == 4 ? '-' : $num;
  }

  return join q{}, reverse @snafu;
}

sub run_tests {
  for my $test (
    [1, '1'],
    [2, '2'],
    [3, '1='],
    [4, '1-'],
    [5, '10'],
    [6, '11'],
    [7, '12'],
    [8, '2='],
    [9, '2-'],
    [10, '20'],
    [15, '1=0'],
    [20, '1-0'],
    [2022, '1=11-2'],
    [12345, '1-0---0'],
    [314159265, '1121-1110-1=0'],
  ) {
    my $dec = snafu_to_dec($test->[1]);

    unless ($dec == $test->[0]) {
      die "$test->[1]: wanted $test->[0], got $dec\n";
    }

    my $snafu = dec_to_snafu($test->[0]);

    unless ($snafu eq $test->[1]) {
      die "$test->[0]: wanted $test->[1], got $snafu\n";
    }
  }
}

# say dec_to_snafu(12345);
