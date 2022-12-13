use v5.36;

my $test = <<EOF;
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
EOF

# open my $in, '<', \$test or die "bad open: $!";
open my $in, '<', 'input/day12.txt' or die "bad open: $!";

my @rows = <$in>;
chomp @rows;

my (%grid, $start, $end);

for (my $y = 0; $y < @rows; $y++) {
  my @chars = split //, $rows[$y];
  for (my $x = 0; $x < @chars; $x++) {
    my $c = $chars[$x];
    my $k = "$x,$y";

    if ($c eq 'S') {
      $grid{$k} = 'a';
      $start = $k;
    } elsif ($c eq 'E') {
      $grid{$k} = 'z';
      $end = $k;
    } else {
      $grid{$k} = $c;
    }
  }
}

{
  my $dist = dijkstra(\%grid, $start);
  say "part 1: $dist->{$end}";
}

# run it again starting from the end
{
  my $dist     = dijkstra(\%grid, $end, 2);
  my %relevant = map {; $_ => $dist->{$_} }
                 grep {; $grid{$_} eq 'a' }
                 keys %grid; # @a_keys;

  my ($min) = sort {; $a <=> $b }
              grep {; defined }
              values %relevant;

  say "part 2: $min";
}

sub dijkstra ($grid, $start, $part = 1) {
  my %q = map {; $_ => 1 } keys %grid;
  my %dist = ($start => 0);

  QUEUE: while (%q) {
    # this is pretty inefficient
    my ($u) = map  {; $_->[0] }
              sort {; $a->[1] <=> $b->[1] }
              grep {; defined $_->[1] }
              map  {; [$_, $dist{$_}] }
              keys %q;


    # BAH, the input is not strongly connected!
    last QUEUE unless defined $u;

    delete $q{$u};

    my $height = $grid->{$u};

    for my $v (valid_neighbors($grid, $u, $part)) {
      next unless $q{$v};

      my $alt = $dist{$u} + 1;
      if (! defined $dist{$v} || $alt < $dist{$v}) {
        $dist{$v} = $alt;
      }
    }
  }

  return \%dist;
}

sub valid_neighbors ($grid, $key, $part) {
  my ($x, $y) = split /,/, $key;
  my $height = $grid->{$key};

  my @valid;

  for my $k (
    sprintf("%s,%s", $x-1, $y), # left
    sprintf("%s,%s", $x+1, $y), # right
    sprintf("%s,%s", $x, $y-1), # up
    sprintf("%s,%s", $x, $y+1), # down
  ) {
    next unless my $nh = $grid->{$k};

    if ($part == 1) {
      next if ord($nh) > ord($height) && ord($nh) - ord($height) > 1;
    } else {
      next if ord($nh) < ord($height) && ord($height) - ord($nh) > 1;
    }


    push @valid, $k;
  }

  return @valid;

}

