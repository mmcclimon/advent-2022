use v5.36;
use Data::Dumper::Concise;

my $test = <<EOF;
30373
25512
65332
33549
35390
EOF

# open my $in, '<', \$test or die "bad open: $!";
open my $in, '<', 'input/day08.txt' or die "bad open: $!";

my @grid = map {; [ chomp && split // ] } <$in>;

my %visible;

# $y is pos in grid, $x is pos in row

# horizontal
for my $y (0..$#grid) {
  my @row = $grid[$y]->@*;
  my $len = $#row;
  my $max_lr = my $max_rl = -1;

  for my $x (0..$len) {
    my $tree = $row[$x];
    if ($tree > $max_lr) {
      $visible{"$y,$x"} = 1;
      $max_lr = $tree;
    }
  }

  for (my $x = $len; $x >= 0; $x--) {
    my $tree = $row[$x];
    if ($tree > $max_rl) {
      $visible{"$y,$x"} = 1;
      $max_rl = $tree;
    }
  }
}

# verticals
for my $x (0..$grid[0]->$#*) {
  my $len = $#grid;
  my $max_tb = my $max_bt = -1;

  for my $y (0..$len) {
    my $tree = $grid[$y]->[$x];
    if ($tree > $max_tb) {
      $visible{"$y,$x"} = 1;
      $max_tb = $tree;
    }
  }

  for (my $y = $len; $y >= 0; $y--) {
    my $tree = $grid[$y]->[$x];
    if ($tree > $max_bt) {
      $visible{"$y,$x"} = 1;
      $max_bt = $tree;
    }
  }
}

say "part 1: " . keys %visible;

# PART 2
my $max = 0;

for my $y (0..$#grid) {
  my @row = $grid[$y]->@*;

  for my $x (0..$#row) {
    my $height = $row[$x];

    my ($left, $right, $up, $down) = (0, 0, 0, 0);

    LEFT: for (my $xx = $x - 1; $xx >= 0; $xx--) {
      $left++;
      last LEFT if $row[$xx] >= $height;
    }

    RIGHT: for (my $xx = $x + 1; $xx < @row; $xx++) {
      $right++;
      last RIGHT if $row[$xx] >= $height;
    }

    UP: for (my $yy = $y - 1; $yy >= 0; $yy--) {
      $up++;
      last UP if $grid[$yy]->[$x] >= $height;
    }

    DOWN: for (my $yy = $y + 1; $yy < @grid; $yy++) {
      $down++;
      last DOWN if $grid[$yy]->[$x] >= $height;
    }

    my $score = $left * $right * $up * $down;
    $max = $score if $score > $max;
  }
}

say "part 2: $max";
