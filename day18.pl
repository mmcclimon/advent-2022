use v5.36;

open my $in, '<', 'input/day18.txt' or die "bad open: $!";

my (@min, @max);
my $map = {};

# build up the map, keeping track of max/min as we go
while (my $line = <$in>) {
  chomp $line;
  my ($x, $y, $z) = split /,/, $line;

  $map->{"$x,$y,$z"} = [ $x, $y, $z];

  $min[0] = $x if ! defined $min[0] || $x < $min[0];
  $min[1] = $y if ! defined $min[1] || $y < $min[1];
  $min[2] = $z if ! defined $min[2] || $z < $min[2];

  $max[0] = $x if ! defined $max[0] || $x > $max[0];
  $max[1] = $y if ! defined $max[1] || $y > $max[1];
  $max[2] = $z if ! defined $max[2] || $z > $max[2];
}

close $in;

# Now, we know the max/min x/y/z values, so we can get map of a sizable chunk
# of space where lava is _not_. (This would be way slow for large graphs but
# is fine for the size we're dealing with here.)
my %empty;
for my $x ($min[0] - 1 .. $max[0] + 1) {
  for my $y ($min[1] - 1 .. $max[1] + 1) {
    for my $z ($min[2] - 1 .. $max[2] + 1) {
      $empty{"$x,$y,$z"} = [$x, $y, $z] unless $map->{"$x,$y,$z"};
    }
  }
}

my $outside = join q{,}, map {; $_ - 1 } @min;
my $holes = find_holes(\%empty, $outside);

say "part 1: " . do_checks($map);
say "part 2: " . do_checks($map, $holes);

# This is just a depth-first search to find strongly-connected components, and
# we discard the component that's definitely outside (i.e., is not a hole).
# NB this consumes the graph.
sub find_holes ($empty, $outside_key) {
  my %holes;

  while (%$empty) {
    my %comp;

    my ($start) = keys %$empty;
    my @s = ($start);

    while (@s) {
      my $v = pop @s;
      next if $comp{$v};

      # say "processing $v";
      $comp{$v} = 1;

      my ($x, $y, $z) = (delete $empty->{$v})->@*;
      my @check;
      # this is so stupid
      for my $add (-1, 1) {
        push @check, join q{,}, $x + $add, $y, $z;
        push @check, join q{,}, $x, $y + $add, $z;
        push @check, join q{,}, $x, $y, $z + $add;
      }

      push @s, grep {; $empty->{$_} } @check;
    }

    next if $comp{$outside_key};

    $holes{$_} = 1 for keys %comp;
  }

  return \%holes;
}

# It feels like probably there's a better way to do this but this is
# sufficiently fast for our purposes.
sub do_checks ($map, $holes = {}) {
  my $sa = 0;

  for my $el (keys %$map) {
    my ($x, $y, $z) = $map->{$el}->@*;
    my @check;
    # this is so stupid
    for my $add (-1, 1) {
      push @check, join q{,}, $x + $add, $y, $z;
      push @check, join q{,}, $x, $y + $add, $z;
      push @check, join q{,}, $x, $y, $z + $add;
    }

    $sa += grep {; ! $map->{$_} && ! $holes->{$_} } @check;
  }

  return $sa;
}
