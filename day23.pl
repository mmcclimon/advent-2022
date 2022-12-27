use v5.36;

open my $in, '<', 'input/day23.txt' or die "bad open: $!";
my @lines = <$in>;
chomp @lines;

# Build the starting map
my $map;
for my $y (0..$#lines) {
  my @chars = split //, $lines[$y];
  for my $x (0..$#chars) {
    next if $chars[$x] eq '.';
    $map->{"$x,$y"} = 1;
  }
}

for (my $round = 1, my $moved; 1; $round++) {
  ($map, $moved) = do_step($map);

  say "part 1: " . count_empty_tiles($map) if $round == 10;

  if (! $moved) {
    say "part 2: $round";
    last;
  }
}

sub do_step ($map) {
  state @PREF = qw( N S W E );
  state %PREF = (N => 8, S => 4, W => 2, E => 1);

  my %new_map;
  my %next;
  my $moved = 0;

  KEY: for my $k (keys %$map) {
    my ($x, $y) = split /,/, $k;

    my $avail = get_avail($map, $x, $y);

    if ($avail == 0) {
      $new_map{$k} = 1;
      next KEY;
    }

    for my $dir (@PREF) {
      unless ($avail & $PREF{$dir}) {
        # say "$k: $dir";
        my $next_x = $dir eq 'W' ? $x - 1 : $dir eq 'E' ? $x + 1 : $x;
        my $next_y = $dir eq 'N' ? $y - 1 : $dir eq 'S' ? $y + 1 : $y;
        push $next{"$next_x,$next_y"}->@*, $k;
        next KEY;
      }
    }

    push $next{$k}->@*, $k;
  }

  for my $k (keys %next) {
    my @vals = $next{$k}->@*;

    if (@vals == 1) {
      # only one thing proposed to move here, let's do it.
      $new_map{$k} = 1;
      $moved = 1;
    } else {
      # more than one thing, so we add the originals back
      $new_map{$_} = 1 for @vals;
    }
  }

  push @PREF, shift @PREF;
  return (\%new_map, $moved);
}

# This returns a bitfield of directions where things are
sub get_avail ($map, $x, $y) {
  my $res = 0;

  $res |= 8 | 2  if $map->{join ',', $x-1, $y-1};  # NW
  $res |= 8      if $map->{join ',', $x+0, $y-1};  # N
  $res |= 8 | 1  if $map->{join ',', $x+1, $y-1};  # NE
  $res |= 2      if $map->{join ',', $x-1, $y};    # W
  $res |= 1      if $map->{join ',', $x+1, $y};    # E
  $res |= 4 | 2  if $map->{join ',', $x-1, $y+1};  # SW
  $res |= 4      if $map->{join ',', $x+0, $y+1};  # S
  $res |= 4 | 1  if $map->{join ',', $x+1, $y+1};  # SE

  return $res;
}

sub count_empty_tiles ($map) {
  my $min_x = 1e8;
  my $min_y = 1e8;
  my $max_x = -1;
  my $max_y = -1;

  for my $k (keys %$map) {
    my ($x, $y) = split /,/, $k;
    $min_x = $x if $x < $min_x;
    $min_y = $y if $y < $min_y;
    $max_x = $x if $x > $max_x;
    $max_y = $y if $y > $max_y;
  }

  my $count = 0;

  for (my $y = $min_y; $y <= $max_y; $y++) {
    for (my $x = $min_x; $x <= $max_x; $x++) {
      $count++ unless $map->{"$x,$y"};
    }
  }

  return $count;
}
