# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::NullSession;

use strict;
use Platypus::Session ();

@Platypus::NullSession::ISA = qw(Platypus::Session);

sub init
  {
    my ($self, $con) = @_;
    $self->{_impl} = {};
    return 1;
  }

sub destroy {}

sub save {}

sub id { "" }

1;
