# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Request;

use strict;
use Apache::Request ();

@Platypus::Request::ISA = qw(Apache::Request);

sub new
  {
    my ($type, $rr) = @_;
    my $class = ref($type) || $type;
    return bless new Apache::Request($rr), $class;
  }

1;
