use v5.36;

use constant TEST => 1;

my $test = <<EOF;
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
EOF


my ($map, $directions) = do {
  local $/ = "\n\n";
  my $f = TEST ? \$test : 'input/day22.txt';
  open my $in, '<', $f or die "bad open: $!";
  <$in>
};

chomp $directions;
my @dir = grep {; length } split /(\d+)([RL])/, $directions;

# globals
my %map;
my $start_x;
my ($x, $y, $facing);

{
  my $y = 0;
  for my $line (split /\n/, $map) {
    $y++;
    my $this_x = 0;

    for my $point (split //, $line) {
      $this_x++;
      next unless $point eq '.' || $point eq '#';
      $start_x //= $this_x;
      $map{"$this_x,$y"} = $point;
    }
  }
}

part1();

sub part1 {
  $x = $start_x;
  $y = 1;
  $facing = 0;

  for my $dir (@dir) {
    if ($dir =~ /^\d+$/) {
      # walk until we hit a wall or whatever
      STEP: for (1..$dir) {
        my $stepped = $facing == 0 ? step(+1, 0)
                    : $facing == 1 ? step(0, +1)
                    : $facing == 2 ? step(-1, 0)
                    : $facing == 3 ? step(0, -1)
                    : die 'wat';

        last STEP unless $stepped;
      }

      next;
    }

    $facing++ if $dir eq 'R';
    $facing-- if $dir eq 'L';
    $facing %= 4;
  }

  my $part1 = $y * 1000 + $x * 4 + $facing;
  say "part 1: $part1";
}


# right/down is +1, left/up is -1
sub step ($inc_x, $inc_y) {
  die unless $inc_x == 0 xor $inc_y == 0;
  my $next_x = $x + $inc_x;
  my $next_y = $y + $inc_y;

  unless (exists $map{"$next_x,$next_y"}) {
    ($next_x, $next_y) = wrap($inc_x, $inc_y);
  }

  return if $map{"$next_x,$next_y"} eq '#';

  $x = $next_x;
  $y = $next_y;
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

