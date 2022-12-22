use v5.36;

open my $in, '<', 'input/day19.txt' or die "bad open: $!";

# This is _mostly_ stolen from musifter on reddit.

my %blueprints;

# man, this sucks
while (my $line = <$in>) {
  chomp $line;

  my @bot_costs;

  my ($num, $rest) = $line =~ /Blueprint (\d+): (.*)/;
  my @sentences = split /\.\s*/, $rest;

  for my $sent (@sentences) {
    my @costs = (0, 0, 0, 0);

    my ($ore_cost) = $sent =~ /costs (\d+) ore/;
    $costs[0] = $ore_cost;

    if ($sent =~ /and (\d+) (\w+)/) {
      state %cost_idx = ( ore => 0, clay => 1, obsidian => 2, geode => 3);
      my ($cost, $material) = ($1, $2);
      my $idx = $cost_idx{$material};
      $costs[$idx] = $cost;
    }

    push @bot_costs, \@costs;
  }

  $blueprints{$num} = \@bot_costs;
}

sub run_blueprint ($num, $time_left) {
  my $best = -1;
  my $best_geode_bots = 0;
  my $bp = $blueprints{$num};

  # max need is how many of each robot we need
  my @max_need = (0, 0, 0, 1e8);
  for my $cost (@$bp) {
    for my $i (0..3) {
      $max_need[$i] = $cost->[$i] if $cost->[$i] > $max_need[$i];
    }
  }

  my $old_time = $time_left;
  my %seen;
  my @queue = ([$time_left, [1,0,0,0], [0,0,0,0]]);

  STATE: while (my $state = shift @queue) {
    my ($time, $robots, $resources, $built_last_round) = @$state;

    # if ($time == $time_limit) {
    if ($time == 0) {
      $best = $resources->[3] if $resources->[3] > $best;
      next STATE;
    }

    next STATE if $seen{"@$robots:@$resources"}++       # already seen this combo
               || $robots->[3] < $best_geode_bots - 1;  # we're too far behind to win

    # We want to build if: we have the resources builds, we don't have enough,
    # and we didn't build this robot last turn (?).
    my (@to_buy, %built);
    TYPE: for my $i (keys @$bp) {
      next TYPE if $built_last_round->{$i};
      next TYPE if $robots->[$i] >= $max_need[$i];

      my $cost = $bp->[$i];

      for my $j (keys @$cost) {
        next TYPE unless $resources->[$j] >= $cost->[$j];
      }

      push @to_buy, $i;
      $built{$i} = 1;
    }

    $resources->[$_] += $robots->[$_] for 0..3;

    for my $robot (reverse @to_buy) {
      my @new_resources = @$resources;
      $new_resources[$_] -= $bp->[$robot][$_] for 0..3;

      my @new_robots = @$robots;
      $new_robots[$robot]++;

      push @queue, [$time - 1, \@new_robots, \@new_resources];

      if ($robot == 3 && $new_robots[3] > $best_geode_bots) {
        $best_geode_bots = $new_robots[3];
      }
    }

    # Wait for something new, keep track of what we're passing on (so we don't
    # redo the same one more than once)
    push @queue, [$time - 1, $robots, $resources, \%built];
  }

  warn "[$num] Best: $best\n";
  return $best;
}

# part 1
my $sum = 0;
for my $num (sort { $a <=> $b } keys %blueprints) {
  $sum += $num * run_blueprint($num, 24);
}

say "part 1: $sum";

# part 2
my $prod = 1;
for my $num (1..3) {
  $prod *= run_blueprint($num, 32);
}

say "part 2: $prod";
