use v5.36;
use Data::Dumper::Concise;

open my $in, '<', 'input/day15.txt' or die "bad open: $!";
my $TARGET = 2000000;
my $MAX    = 4000000;

my %beacons;
my %sensors;
my $num = qr{-?[0-9]+};

# read the grid
while (my $line = <$in>) {
  my ($sx, $sy, $bx, $by) = $line =~ /x=($num), y=($num):.*x=($num), y=($num)/;

  # manhattan distance, then increase the coverage over its whole area
  my $dist = abs($sx - $bx) + abs($sy - $by);
  $sensors{"$sx,$sy"} = $dist;
  $beacons{"$bx,$by"} = 1;
}

close $in;

# PART 1
{
  my %pos;

  for my $k (keys %sensors) {
    my $dist = $sensors{$k};
    my ($sx, $sy) = split /,/, $k;

    my $dist_at_target = $dist - abs($sy - $TARGET);
    next if $dist_at_target <= 0;

    my $startx = $sx - ($dist_at_target);
    my $endx   = $sx + ($dist_at_target);
    for (my $x = $startx; $x <= $endx; $x++) {
      $pos{$x} = 1 unless $beacons{"$x,$TARGET"};
    }
  }

  say "part 1: " . scalar keys %pos;
}

# PART 2
# keys are y values, values are [[ax1,ax2], [bx1,bx2]]
my %blocked;

for my $k (keys %sensors) {
  # say "processing $k to discver blocked things";
  my $dist = $sensors{$k};
  my ($sx, $sy) = split /,/, $k;

  for (my $y = $sy - $dist; $y <= $sy + $dist; $y++) {
    my $xrange = $dist - abs($sy - $y);
    push $blocked{$y}->@*, [$sx - $xrange, $sx + $xrange];
  }
}

OUTER: for my $y (keys %blocked) {
  next if $y < 0 || $y > $MAX;

  my $pairs = delete $blocked{$y};
  my @sorted = sort {; $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @$pairs;

  my $right = 0;    # rightmost filled point on this line

  for my $pair (@sorted) {
    $right = $pair->[1] if $pair->[0] <= $right + 1 <= $pair->[1];
    next OUTER if $right > $MAX;
  }

  # here, the point just right of our rightmost filled spot is empty!
  $right++;
  say "part 2: " . ($right * 4_000_000 + $y);
  last;
}

