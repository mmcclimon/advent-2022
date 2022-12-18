use v5.36;

open my $in, '<', 'input/day17.txt' or die "bad open: $!";
chomp(my $jet = <$in>);

my $MAX = shift @ARGV // 1_000_000_000_000;

my %cave;
my $highest = 0;

# we can keep track of the highest rock in each column and make a height map
# from it
my @blocks = (0, 0, 0, 0, 0, 0, 0, 0);
my %heights;
my $jumped = 0;
my %seen;

for (my $i = 0; $i < $MAX; $i++) {
  # rock always starts two units from left wall, 3 units above tallest point
  my $shape = next_rock();
  my $rock = Rock->new($shape, $highest + 4);

  my $idx;

  while (1) {
    (my $dir, $idx) = next_jet();
    $rock->move($dir, \%cave);

    my $stopped = $rock->fall(\%cave);
    last if $stopped;
  }

  # account for this rock in the cave
  $rock->add_to_cave(\%cave, \@blocks);

  my $top = $rock->high_point;
  $highest = $top if $top > $highest;
  $heights{$i} = $highest;

  my $hmap = join ',', map { $highest - $blocks[$_] } 1..7;
  my $key = "$idx;$shape;$hmap";

  if (! $jumped && $seen{$key}) {
    # HERE: we know how much height we gain each cycle, and how high we
    # are, so we can artificially increase everything without needing to
    # compute every step
    my $start_of_cycle = $seen{$key};
    my $cycle_len = $i - $start_of_cycle;
    my $height_per_cycle = $highest - $heights{$start_of_cycle};

    # say "ahoy!! cycle len of $cycle_len, h=$height_per_cycle, starting at $start_of_cycle";
    my $n_cycles = int(($MAX - $start_of_cycle - $cycle_len - 1) / $cycle_len);

    $highest += $n_cycles * $height_per_cycle;
    $i += $n_cycles * $cycle_len;

    # for every point in the cave higher than start of the cycle, we need to add the cycle!
    for my $k (keys %cave) {
      my ($x, $y) = split /,/, $k;
      my $yy = $y + ($n_cycles * $height_per_cycle);
      $cave{"$x,$yy"} = $cave{$k} + ($n_cycles * $cycle_len);
    }

    $jumped = 1;
  }

  $seen{$key} = $i unless $jumped;
}

my $part = $MAX == 2022 ? 1 : 2;
say "part $part: $highest";

sub next_rock {
  state @rocks = qw( - + L | o );
  state $idx = 0;
  return $rocks[$idx++ % 5];
}

sub next_jet {
  state @jet = split //, $jet;
  state $len = @jet;
  state $i = 0;
  my $idx = $i++ % $len;
  return ($jet[$idx], $idx);
}


package Rock {
  # x,y coords
  sub new ($class, $which, $y) {
    if ($which eq '-') {
      return bless [
        [3, $y], [4, $y], [5, $y], [6, $y],
      ], $class;
    }

    # NB: keyed from left arm, extends
    if ($which eq '+') {
      return bless [
        [3, $y+1], [4, $y+1], [4, $y], [4, $y+2], [5, $y+1]
      ], $class;
    }

    if ($which eq 'L') {
      return bless [
        [3, $y], [4, $y], [5, $y], [5, $y+1], [5, $y+2]
      ], $class;
    }

    if ($which eq '|') {
      return bless [
        [3, $y], [3, $y+1], [3, $y+2], [3, $y+3],
      ], $class;
    }

    if ($which eq 'o') {
      return bless [
        [3, $y], [4, $y], [3, $y+1], [4, $y+1],
      ], $class;
    }

    die "wat: $which";
  }

  sub debug ($self) {
    return join q{ }, map {; join ',', @$_ } @$self;
  }

  sub move ($self, $dir, $cave) {
    if ($dir eq '>') {
      return if $self->[-1][0] == 7;

      # check if it _can_ move right
      for my $coord (@$self) {
        my $k = join ',', $coord->[0] + 1, $coord->[1];
        return if $cave->{$k};
      }

      $_->[0]++ for @$self;
    }

    if ($dir eq '<') {
      return if $self->[0][0] == 1;

      for my $coord (@$self) {
        my $k = join ',', $coord->[0] - 1, $coord->[1];
        return if $cave->{$k};
      }

      $_->[0]-- for @$self;
    }
  }

  sub fall ($self, $cave) {
    for my $coord (@$self) {
      my $k = join ',', $coord->[0], $coord->[1] - 1;
      return 1 if $cave->{$k} || $coord->[1] == 1;
    }

    $_->[1]-- for @$self;
    return;
  }

  sub add_to_cave ($self, $cave, $blocks) {
    for my $coord (@$self) {
      my $k = join ',', @$coord;
      $cave->{$k} = 1;
    }

    for my $coord (@$self) {
      my ($x, $y) = @$coord;
      $blocks->[$x] = $y if $y > $blocks->[$x];
    }
  }

  sub high_point ($self) {
    # Yes, we could just store this on construction, but also
    my $high = -1;

    for my $coord (@$self) {
      $high = $coord->[1] if $coord->[1] > $high;
    }

    return $high;
  }
}
