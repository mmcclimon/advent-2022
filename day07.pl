use v5.36;

open my $in, '<', 'input/day07.txt' or die "bad open: $!";

my @path;
my %sizes;

while (my $line = <$in>) {
  chomp $line;

  if ($line =~ /^\$ cd (.*)/) {
    my $target = $1;

    if ($target eq '/') {
      @path = ('');
    } elsif ($target eq '..') {
      pop @path;
    } else {
      push @path, $target;
    }
  } elsif ($line =~ /^(\d+) \w+/) {
    my $size = $1;

    # the size of this file counts for everything all the way up
    for my $i (0..$#path) {
      my $k = (join '/', @path[0..$i]) || '/';
      $sizes{$k} += $size;
    }
  }
}

# part 1
my $sum = 0;
$sum += $_ for grep {; $_ <= 100_000 } values %sizes;

# part 2
my $unused      = 70_000_000 - $sizes{'/'};
my ($to_delete) = sort {; $a <=> $b }
                  grep {; $unused + $_ >= 30_000_000 }
                  values %sizes;

say "part 1: $sum";
say "part 2: $to_delete";
