use v5.36;

use constant {
  RIGHT => 0,
  DOWN  => 1,
  LEFT  => 2,
  UP    => 3,
};

my ($map, $directions) = do {
  local $/ = "\n\n";
  open my $in, '<', 'input/day22.txt' or die "bad open: $!";
  <$in>
};

# globals
my (%map, @directions);
my ($x, $y, $facing, $start_x);

setup_globals();
run_tests();
do_part(1);
do_part(2);

# read the map
sub setup_globals {
  my $y = 0;
  for my $line (split /\n/, $map) {
    $y++;
    my $x = 0;

    for my $point (split //, $line) {
      $x++;
      next unless $point eq '.' || $point eq '#';
      $start_x //= $x;
      $map{"$x,$y"} = $point;
    }
  }

  chomp $directions;
  @directions = grep {; length } split /(\d+)([RL])/, $directions;
  return;
}

sub do_part ($part) {
  $x = $start_x;
  $y = 1;
  $facing = 0;

  # say "starting at $x,$y facing $facing";

  for my $dir (@directions) {
    if ($dir =~ /^\d+$/) {
      # walk until we hit a wall or whatever
      STEP: for (1..$dir) {
        my $stepped = $facing == RIGHT ? step($part, +1, 0)
                    : $facing == DOWN  ? step($part, 0, +1)
                    : $facing == LEFT  ? step($part, -1, 0)
                    : $facing == UP    ? step($part, 0, -1)
                    : die 'wat';

        last STEP unless $stepped;
      }
    } else {
      $facing++ if $dir eq 'R';
      $facing-- if $dir eq 'L';
      $facing %= 4;
    }

    # state @f = qw(right down left up);
    # my $f = $f[$facing];
    # say "after $dir, standing at $x,$y, facing $f";
  }

  my $part1 = $y * 1000 + $x * 4 + $facing;
  say "part 1: $part1";
}

# right/down is +1, left/up is -1
sub step ($part, $inc_x, $inc_y) {
  die unless $inc_x == 0 xor $inc_y == 0;
  my $next_x = $x + $inc_x;
  my $next_y = $y + $inc_y;
  my $next_facing = $facing;

  my $wrapped = 0;
  unless (exists $map{"$next_x,$next_y"}) {
    $wrapped++;
    ($next_x, $next_y, $next_facing) =
      $part == 1 ? wrap($inc_x, $inc_y) : wrap2($inc_x, $inc_y);
      # say "at $x,$y facing $facing, will change to $next_x,$next_y facing $next_facing";
  }

  if ($map{"$next_x,$next_y"} eq '#') {
    # say "  ran into wall!" if $wrapped;
    return;
  }

  $x = $next_x;
  $y = $next_y;
  $facing = $next_facing // $facing;
  return 1;
}

sub wrap ($inc_x, $inc_y) {
  my ($next_x, $next_y) = ($x, $y);
  while (exists $map{"$next_x,$next_y"}) {
    $next_x -= $inc_x;
    $next_y -= $inc_y;
  }

  $next_x += $inc_x;
  $next_y += $inc_y;
  return ($next_x, $next_y);
}

sub wrap2 ($inc_x, $inc_y) {
  # this sucks, but I can't think of another way to do it.
  # ...this is obviously very specific to my input
  #   1122
  #   1122
  #   33
  #   33
  # 4455
  # 4455
  # 66
  # 66
  my $tile =  51 <= $x <= 100 &&   1 <= $y <=  50 ? 1
           : 101 <= $x <= 150 &&   1 <= $y <=  50 ? 2
           :  51 <= $x <= 100 &&  51 <= $y <= 100 ? 3
           :   1 <= $x <=  50 && 101 <= $y <= 150 ? 4
           :  51 <= $x <= 100 && 101 <= $y <= 150 ? 5
           :   1 <= $x <=  50 && 151 <= $y <= 200 ? 6
           : die "bad tile: $x, $y";

  if ($tile == 1) {
    return (1, 200 - (100 - $x), RIGHT)  if $facing == UP;
    return (1, 150 - ($y - 1), RIGHT)    if $facing == LEFT;
  } elsif ($tile == 2) {
    return (50 - (150 - $x), 200, UP)    if $facing == UP;
    return (100, 101 + (50 - $y), LEFT)  if $facing == RIGHT;
    return (100, 100 - (150 - $x), LEFT) if $facing == DOWN;
  } elsif ($tile == 3) {
    return (50 - (100 - $y), 101, DOWN)  if $facing == LEFT;
    return (150 - (100 - $y), 50, UP)    if $facing == RIGHT;
  } elsif ($tile == 4) {
    return (51, 100 - (50 - $x), RIGHT)  if $facing == UP;
    return (51,  1 + (150 - $y), RIGHT)  if $facing == LEFT;
  } elsif ($tile == 5) {
    return (150, 1 + (150 - $y), LEFT)   if $facing == RIGHT;
    return (50, 200 - (100 - $x), LEFT)  if ($facing == DOWN);
  } elsif ($tile == 6) {
    return (100 - (200 - $y), 1, DOWN)   if $facing == LEFT;
    return (100 - (200 - $y), 150, UP)   if $facing == RIGHT;
    return (150 - (50 - $x), 1, DOWN)    if $facing == DOWN;
  }

  die "want to wrap, currently facing $facing at $x,$y on tile $tile";
}

sub run_tests ($verbose = 0) {
  my @tests = (
    # x, y, facing, want x, want y, want facing
    [ 51, 1, UP, 1, 151, RIGHT ],      # 1u
    [ 51, 1, LEFT, 1, 150, RIGHT ],    # 1l
    [ 150, 1, UP, 50, 200, UP ],       # 2u
    [ 150, 1, RIGHT, 100, 150, LEFT ], # 2r
    [ 150, 50, DOWN, 100, 100, LEFT],  # 2d
    [ 51, 100, LEFT, 50, 101, DOWN ],  # 3l
    [ 100, 100, RIGHT, 150, 50, UP ],  # 3r
    [ 50, 101, UP, 51, 100, RIGHT],    # 4u
    [ 1, 150, LEFT, 51, 1, RIGHT ],    # 4l
    [ 100, 150, RIGHT, 150, 1, LEFT ], # 5r
    [ 100, 150, DOWN, 50, 200, LEFT ], # 5d
    [ 1, 200, LEFT, 100, 1, DOWN ],    # 6l
    [ 1, 200, DOWN, 101, 1, DOWN ],    # 6d
    [ 50, 200, DOWN, 150, 1, DOWN ],    # 6d
    [ 50, 200, RIGHT, 100, 150, UP ],  # 6r
  );

  for my $test (@tests) {
    my ($xx, $yy, $ff, $want_x, $want_y, $want_f) = @$test;
    $x = $xx;
    $y = $yy;
    $facing = $ff;

    my ($inc_x, $inc_y) = $ff == RIGHT ? (1, 0)
                        : $ff == DOWN  ? (0, 1)
                        : $ff == LEFT  ? (-1, 0)
                        :                (0, -1);

    my ($got_x, $got_y, $got_f) = wrap2($inc_x, $inc_y);
    unless ($got_x == $want_x && $got_y == $want_y && $got_f == $want_f) {
      say "bad test: @$test";
      say "got:  $got_x, $got_y, $got_f";
      say "want: $want_x, $want_y, $want_f";
      die "failed test"
    }

    say "ok: @$test" if $verbose;
  }
}
