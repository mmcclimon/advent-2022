use v5.36;

open my $in, '<', 'input/day14.txt' or die "bad open: $!";

my %grid;
my $MAX_Y = 0;

# read the grid (this sorta stinks)
while (my $line = <$in>) {
  chomp $line;
  my @coords = map {; [ split /,/ ] } split / -> /, $line;

  while (@coords > 1) {
    my ($sx, $sy) = (pop @coords)->@*;
    my ($ex, $ey) = $coords[-1]->@*;

    # Feels like I should be able to do this generically, but meh
    if ($sx == $ex) {
      my $inc = $sy > $ey ? -1 : 1;
      for (my $y = $sy; $y != $ey + $inc; $y += $inc) {
        $grid{"$sx,$y"} = '#';
        $MAX_Y = $y if $y > $MAX_Y;
      }
    }

    if ($sy == $ey) {
      my $inc = $sx > $ex ? -1 : 1;
      for (my $x = $sx; $x != $ex + $inc; $x += $inc) {
        $grid{"$x,$sy"} = '#';
      }
    }
  }
}

sub do_simulation ($grid, $part = 1) {
  my $floor = $MAX_Y + 2;
  my $grains = 0;

  GRAIN: while (1) {
    my $x = 500;
    my $y = 0;

    TICK: while ($y <= $floor) {
      my $cy = $y + 1;  # $cy is check-y

      if ($cy == $floor) {
        last GRAIN if $part == 1;   # falls forever, we're done

        $grid->{"$x,$y"} = 'o';
        last TICK;
      }

      if ($grid->{"$x,$cy"}) {
        # blocked, we cannot continue moving downward
        my $l = $x - 1;
        my $r = $x + 1;

        if (! $grid->{"$l,$cy"}) {
          $x = $l;
        } elsif (! $grid->{"$r,$cy"}) {
          $x = $r;
        } else {
          $grid->{"$x,$y"} = 'o';
          last TICK;
        }
      }

      $y++;
    }

    $grains++;
    last if "$x,$y" eq '500,0';
  }

  return $grains;
}


say "part 1: " . do_simulation({ %grid }, 1);
say "part 2: " . do_simulation({ %grid }, 2);
