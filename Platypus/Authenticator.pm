# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Authenticator;

use strict;

sub new
  {
    my ($type, $con, @args) = @_;
    my $class = ref($type) || $type;

    my $self = bless {}, $class;
    $self->init($con, @args);

    return $self;
  }

sub init {}

sub authenticate { 1 }

sub challenge {}

1;
