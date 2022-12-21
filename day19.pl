use v5.36;

use constant {
  ORE => 0,
  CLAY => 1,
  OBSIDIAN => 2,
  GEODE => 3,
};

sub descend ($costs, $robots, $resources, $time, $depth = 0, $answer = []) {
  if ($time <= 0) {
    say "returning $resources->[-1] from $depth";
    return $resources->[GEODE];
  }

  state $seen = 0;
  $seen++;
  say "time $time, seen=$seen";

  # check what you can afford
  my @to_buy;
  TYPE: for my $i (keys @$costs) {
    my $cost = $costs->[$i];
    # say "at time $time, checking cost for $i (@$cost)";

    # we can afford to buy it if we have 
    for my $j (keys @$cost) {
      next TYPE unless $resources->[$j] >= $cost->[$j];
      push @to_buy, $i;
    }
  }

  for (0..3) {
    $resources->[$_] += $robots->[$_];
  }

  # say "pushing no-op onto answer from $iter";
  push @$answer, descend(
    $costs,
    $robots,
    $resources,
    $time - 1,
    $depth + 1,
    $answer,
  );

  for my $to_buy (@to_buy) {
    my @new_robots = @$robots;
    $new_robots[$to_buy] += 1;

    my @new_resources = @$resources;

    for my $i (keys $costs->[$to_buy]->@*) {
      $new_resources[$i] -= $costs->[$to_buy][$i];
    }

    # say "pushing buy $to_buy onto answer from $iter";
    push @$answer, descend(
      $costs,
      \@new_robots, 
      \@new_resources,
      $time - 1,
      $depth + 1,
      $answer,
    );
  }

  # say "at depth $iter, returning " . Dumper($answer);

  say "returning answer from $depth";
  return @$answer;
}

# ore, clay, obsidian, geode
my $costs = [
  [ 4, 0, 0 ],
  [ 2, 0, 0 ],
  [ 3, 0, 14 ],
  [ 3, 0, 7 ],
];

my $robots = [ 1, 0, 0, 0 ];
my $resources = [ 0, 0, 0, 0 ];

my @ans = descend($costs, $robots, $resources, 24);

warn "@ans";
