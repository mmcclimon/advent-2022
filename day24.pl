use v5.36;

use constant TEST => 0;

my $test = <<EOF;
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
EOF

my $file = TEST ? \$test : 'input/day24.txt';
open my $in, '<', $file or die "bad open: $!";
my (undef, @lines) = <$in>;
pop @lines;
chomp @lines;

# globals
my $y_len     = @lines;
my $x_len     = (length $lines[0]) - 2;
my $cycle_len = TEST ? 24 : 300;   # or I could write lcm
my (%times, %maps);

generate_initial_map();

my $time1 = do_leg(1);
say "part 1: $time1";
my $time2 = do_leg(2, $time1);
my $time3 = do_leg(3, $time2);
say "part 2: $time3";

sub generate_initial_map {
  my @blizzards;

  for my $y (0..$#lines) {
    my (undef, @chars) = split //, $lines[$y];
    pop @chars;

    for my $x (0..$#chars) {
      my $char = $chars[$x];
      next if $char eq '.';
      push @blizzards, [ $char, $x, $y ];
    }
  }

  $times{0} = \@blizzards;

  for my $bl (@blizzards) {
    my $k = join q{,}, $bl->[1], $bl->[2];
    $maps{0}->{$k} = 1;
  }
}

sub map_for_time ($time) {
  return $maps{$time} if $maps{$time};

  state $done = 0;
  state %inc = (
    '>' => [ 1,  0],
    '<' => [-1,  0],
    'v' => [ 0,  1],
    '^' => [ 0, -1],
  );

  for (my $i = $done + 1; $i <= $time; $i++) {
    my @blizz;

    for my $blizz ($times{$i - 1}->@*) {
      my ($dir, $x, $y) = @$blizz;
      my $inc = $inc{$dir};

      my $xx = ($x + $inc->[0]) % $x_len;
      my $yy = ($y + $inc->[1]) % $y_len;
      push @blizz, [ $dir, $xx, $yy ];
    }

    $times{$i} = \@blizz;

    for my $bl (@blizz) {
      my $k = join q{,}, $bl->[1], $bl->[2];
      $maps{$i}->{$k} = 1;
    }
  }


  $done = $time;
  return $maps{$time};
}

sub do_leg ($leg, $time = 1) {
  my @start  = $leg == 2 ? ($x_len - 1, $y_len) : (0, -1);
  my $target = $leg == 2 ? "0,-1" : join q{,}, ($x_len - 1, $y_len);
  my @queue = [$time, @start];

  my $best = ~0;
  my %seen;

  while (my $todo = shift @queue) {
    my ($time, $x, $y) = @$todo;
    next if $time > $best;

    my $k = join q{,}, $time % $cycle_len, $x, $y;
    next if $seen{$k}++;

    my $map = map_for_time($time % $cycle_len);

    push @queue, [ $time + 1, $x, $y] unless $map->{"$x,$y"};

    for my $inc (
      [ 1,  0],   # right
      [-1,  0],   # left
      [ 0,  1],   # down
      [ 0, -1],   # up
    ) {
      my $xx = $x + $inc->[0];
      my $yy = $y + $inc->[1];

      if ("$xx,$yy" eq $target) {
        $best = $time if $time < $best;
        # say "hey! found a thing at $xx,$yy.";
        next;
      }

      next if $xx < 0 || $xx >= $x_len || $yy < 0 || $yy >= $y_len; # out of bounds
      next if $map->{"$xx,$yy"}; # occupied!
      push @queue, [ $time + 1, $xx, $yy ];
    }
  }

  return $best;
}

