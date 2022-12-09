use v5.36;

open my $in, '<', 'input/day09.txt' or die "bad open: $!";
my @directions = <$in>;

my %DIR = (
  R => [ 1,  0],
  L => [-1,  0],
  U => [ 0,  1],
  D => [ 0, -1],
);

sub clamp ($n) {
  return $n >  1  ? 1
       : $n < -1 ? -1
       : $n;
}

sub knots_are_touching ($head, $tail) {
  my $xdiff = abs($head->[0] - $tail->[0]);
  my $ydiff = abs($head->[1] - $tail->[1]);
  return $xdiff <= 1 && $ydiff <= 1;
}

sub do_rope ($n) {
  my $rope = [ map {; [0, 0] } 1..$n ];
  my %seen;

  DIRECTION: for my $line (@directions) {
    my ($dir, $amt) = split /\s/, $line;
    my $to_add = $DIR{$dir};

    STEP: for (0..$amt - 1) {
      # move the head of the rope
      $rope->[0][0] += $to_add->[0];
      $rope->[0][1] += $to_add->[1];

      # for every knot remaining, process it and its immediate neighbor
      KNOT: for my $i (1..$#$rope) {
        my $leader = $rope->[$i - 1];
        my $follower = $rope->[$i];

        next KNOT if knots_are_touching($leader, $follower);

        my $x = clamp($leader->[0] - $follower->[0]);
        my $y = clamp($leader->[1] - $follower->[1]);
        $follower->[0] += $x;
        $follower->[1] += $y;
      }

      # mark this tail position as seen
      my $k = join q{,}, $rope->[-1]->@*;
      $seen{$k} = 1;
    }
  }

  return scalar keys %seen;
}

say "part 1: " . do_rope(2);
say "part 2: " . do_rope(10);
