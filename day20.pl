use v5.36;

open my $in, '<', 'input/day20.txt' or die "bad open: $!";
my @arr = <$in>;
chomp (@arr);

do_part(1);
do_part(2);

sub do_part ($n) {
  my $loop;
  my $key = $n == 1 ? 1 : 811589153;

  for my $line (@arr) {
    my $node = Node->new($key * $line);

    if ($loop) {
      $loop->add($node);
    } else {
      $loop = Loop->new($node);
    }
  }

  my $times = $n == 1 ? 1 : 10;

  $loop->mix for 1..$times;

  say "part $n: " . $loop->grove_coords;
}



package Node {
  sub new ($class, $val) { bless { value => $val }, $class }
}

package Loop {
  sub new ($class, $root) {
    $root->{prev} = $root;
    $root->{next} = $root;

    bless {
      len => 1,
      cur => $root,
      arr => [ $root ],
      head => $root,
    }, $class;
  }

  sub add ($self, $node) {
    my $prev = $self->{cur};
    my $succ = $prev->{next};

    $succ->{prev} = $node;
    $prev->{next} = $node;

    $node->{next} = $succ;
    $node->{prev} = $prev;

    push $self->{arr}->@*, $node;
    $self->{cur} = $node;
    $self->{len}++;

    return;
  }

  sub debug ($self) {
    my @s;
    my $cur = $self->{head};

    for (1..$self->{len}) {
      push @s, $cur->{value};
      $cur = $cur->{next};
    }

    return join q{, }, @s;
  }

  sub mix ($self, $debug = 0) {
    for my $node ($self->{arr}->@*) {
      my $to_move = $node->{value} % ($self->{len} - 1);
      next unless $to_move;

      $self->{head} = $node->{next} if $node eq $self->{head};

      for (0.. $to_move - 1) {
        my $prev = $node->{prev};
        my $next = $node->{next};

        $node->{prev} = $next;
        $node->{next} = $next->{next};
        $node->{next}{prev} = $node;

        $prev->{next} = $next;
        $next->{next} = $node;
        $next->{prev} = $prev;
      }
    }
  }

  sub grove_coords ($self) {
    my %relevant = map {; ($_ % $self->{len}) => 1 }  (1000, 2000, 3000);
    die "ohno, grove coordinates are the same?" unless %relevant == 3;

    # start from 0.
    my $cur = $self->{head};
    while ($cur->{value} != 0) {
      $cur = $cur->{next};
    }

    my @grove;
    for my $i (0..$self->{len} - 1) {
      if ($relevant{$i}) {
        push @grove, $cur->{value};
        last if @grove == 3;
      }

      $cur = $cur->{next};
    }

    return $grove[0] + $grove[1] + $grove[2];
  }
}

