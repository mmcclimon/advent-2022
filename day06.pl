use v5.36;

open my $in, '<', 'input/day06.txt' or die "bad open: $!";
my $msg = <$in>;
chomp $msg;

sub find_marker ($len) {
  for (my $i = 0; $i < length($msg) - $len; $i++) {
    my %set = map {; $_ => 1 } split //, substr $msg, $i, $len;
    return $i + $len if %set == $len;
  }
}

say "part 1: " . find_marker(4);
say "part 2: " . find_marker(14);
