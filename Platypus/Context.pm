# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Context;

use strict;

sub new
  {
    my ($type, $rr) = @_;
    my $class = ref($type) || $type;
    return bless {}, $class;
  }

sub application
  {
    my ($self, $app) = @_;
    $self->{_app} = $app if $app;
    return $self->{_app};
  }

sub config
  {
    my ($self, $cfg) = @_;
    $self->{_cfg} = $cfg if $cfg;
    return $self->{_cfg};
  }

sub log
  {
    my ($self) = @_;
    return undef unless $self->{_app};
    return $self->{_app}->log;
  }

sub request
  {
    my ($self, $req) = @_;
    $self->{_req} = $req if $req;
    return $self->{_req};
  }

sub response
  {
    my ($self, $res) = @_;
    $self->{_res} = $res if $res;
    return $self->{_res};
  }

sub session
  {
    my ($self, $ses) = @_;
    $self->{_ses} = $ses if $ses;
    return $self->{_ses};
  }

sub session_manager
  {
    my ($self) = @_;
    return undef unless $self->{_app};
    return $self->{_app}->session_manager;
  }

1;
