use v5.36;
use Data::Dumper::Concise;

# NOTE: This solution is entirely stolen from Noah Clements:
# https://github.com/noah-clements/AoC2022/blob/master/day16/day16.py

my ($valves, $dist) = parse('input/day16.txt');
part1($valves, $dist);
part2($valves, $dist);

package Valve {
  sub new ($class, $name, $rate, $conn) { bless [ $name, $rate, $conn], $class }
  sub name { $_[0]->[0] }
  sub rate { $_[0]->[1] }
  sub connects_to ($self, $other) { !! grep {; $_ eq $other } $self->[2]->@* }
}

sub parse ($infile) {
  my %store;
  my %dist;
  open my $in, '<', $infile or die "bad open: $!";

  while (my $line = <$in>) {
    my ($name, $flow_rate, $conn) =
      $line =~ /Valve (\w+) has flow rate=(\d+);.*to valves? (.*)/;
    my @conn = split /, /, $conn;
    $store{$name} = Valve->new($name, $flow_rate, \@conn);
  }


  # This is the Floyd-Warshall algorithm
  my $INF = 1e8;
  for my $x (keys %store) {
    for my $y (keys %store) {
      $dist{$x}->{$y} = $store{$x}->connects_to($y) ? 1 : $INF;
    }
  }

  my sub min ($x, $y) { $x < $y ? $x : $y }

  for my $k (keys %dist) {
    for my $i (keys %dist) {
      for my $j (keys %dist) {
        $dist{$i}->{$j} = min($dist{$i}->{$j}, $dist{$i}->{$k} + $dist{$k}->{$j});
      }
    }
  }

  # non-zero valve sizes
  my %valves = map  {; $_->name => $_ }
               grep {; $_->rate > 0 }
               values %store;

  return (\%valves, \%dist);
}

sub max ($x, $y) { $x > $y ? $x : $y }

sub part1 ($valves, $dist) {
  my $i = 0;
  my %state = map {; $_ => 1 << $i++ } keys %$valves;

  my $answers = traveling_elf($valves, $dist, \%state, 'AA', 30, 0, 0);

  my $max = 0;
  $max = max($max, $_) for values %$answers;

  say "part 1: $max";
}

sub part2 ($valves, $dist) {
  my $i = 0;
  my %state = map {; $_ => 1 << $i++ } keys %$valves;

  my $paths = traveling_elf($valves, $dist, \%state, 'AA', 26, 0, 0);

  my $max = 0;
  for my $k1 (keys %$paths) {
    for my $k2 (keys %$paths) {
      $max = max($max, $paths->{$k1} + $paths->{$k2}) unless $k1 & $k2;
    }
  }

  say "part 2: $max";
}

sub traveling_elf ($valves, $dist, $state, $last_valve, $time, $this_state, $flow, $answer = {}) {
  $answer->{$this_state} = max($answer->{$this_state} // 0, $flow);

  for my $valve (keys %$valves) {
    my $minutes = $time - $dist->{$last_valve}{$valve} - 1;

    # We're done if we've already seen this valve (bitmasked in $state)
    # or we're out of time.
    next if $state->{$valve} & $this_state || $minutes <= 0;

    # recurse with this valve
    traveling_elf(
      $valves,
      $dist,
      $state,
      $valve,
      $minutes,
      $this_state | $state->{$valve},
      $flow + ($minutes * $valves->{$valve}->rate),
      $answer,
    );
  }

  return $answer;
}
