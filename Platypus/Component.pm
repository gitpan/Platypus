# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Component;

use strict;
use URI::Escape qw(uri_escape);

sub new
  {
    my ($type, @args) = @_;
    my $class = ref($type) || $type;

    my $self = bless {}, $class;
    $self->init(@args);

    return $self;
  }

sub init {}

sub link
  {
    my ($self, $con, @args) = @_;
    return $con->session_manager->construct_url($con,
                                                map { uri_escape($_) } @args);
  }

sub output
  {
    my ($self, $con) = @_;
    return 1;
  }

sub self_link
  {
    my ($self, $con, @args) = @_;
    return $con->session_manager->construct_url($con,
                                                undef,
                                                map { uri_escape($_) } @args);
  }

1;
