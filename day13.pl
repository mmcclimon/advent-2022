use v5.36;
use experimental 'builtin';
use builtin qw(trim);

use constant RIGHT => 1;
use constant NO_OPINION => 0;
use constant WRONG => -1;

open my $in, '<', 'input/day13.txt' or die "bad open: $!";
my @pairs = do { local $/ = "\n\n"; <$in>};
close $in;

my $sum = 0;
my $i = 1;
my @all;

for my $pair (@pairs) {
  my ($l, $r) = split /\n/, trim($pair);
  my ($left)  = parse($l);
  my ($right) = parse($r);

  push @all, $left, $right;

  my $got = compare($left, $right);
  $sum += $i if $got == RIGHT;

  $i++;
}

say "part 1: $sum";

# sort the whole list
my $div1 = [[2]];
my $div2 = [[6]];
push @all, $div1, $div2;

my @sorted = sort {; compare($a, $b) * -1 } @all;
my ($idx1, $idx2) = grep {; $sorted[$_] eq $div1 || $sorted[$_] eq $div2 } keys @sorted;
say "part 2: " . ($idx1+1) * ($idx2+1);

# this is a flex: I could just use decode_json($line)
sub parse ($line) {
  my @ret;
  my $buf;

  for (my $ptr = 1; $ptr < length $line; $ptr++) {
    my $c = substr $line, $ptr, 1;

    if ($c eq '[') {
      my ($got, $len) = parse(substr $line, $ptr);
      push @ret, $got;
      $ptr += $len;
    } elsif ($c eq ',') {
      push @ret, 0 + $buf if length $buf;
      $buf = '';
    } elsif ($c eq ']') {
      push @ret, 0 + $buf if length $buf;
      return (\@ret, $ptr);
    } else {
      $buf .= $c;
    }
  }

  die "unreachable";
}

sub compare ($left, $right) {
  if (! ref $left && ! ref $right) {
    return $left == $right ? NO_OPINION
         : $left <  $right ? RIGHT : WRONG;
  }

  return compare( $left , [$right]) if   ref $left && ! ref $right;
  return compare([$left],  $right ) if ! ref $left &&   ref $right;

  # everything's a ref, compare element-wise
  for (my $i = 0; $i < @$left; $i++) {
    my $l = $left->[$i];
    my $r = $right->[$i];

    return WRONG unless defined $r;

    my $got = compare($l, $r);
    return $got if $got != NO_OPINION;
  }

  # if left and right are the same length, we have no opinion; otherwise,
  # we've fallen off the end of the left and there are still right elements
  # remaining, so we're good.
  return @$left == @$right ? NO_OPINION : RIGHT;
}
