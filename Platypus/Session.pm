# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Session;

use strict;

sub new
  {
    my ($type, @args) = @_;
    my $class = ref($type) || $type;

    my $self = {};
    $self->{_dictionary} = {};
    bless $self, $class;

    $self->init(@args);

    die "Platypus::Session subclass needs to implement storage\n" unless
      $self->{_impl};

    return $self;
  }

sub init {}

sub destroy
  {
    my ($self) = @_;
    return $self->{_impl}->delete;
  }

sub get
  {
    my ($self, $key) = @_;
    return $self->{_dictionary}->{$key};
  }

sub id
  {
    my ($self, $id) = @_;
    $self->{_id} = $id if $id;
    return $self->{_id};
  }

sub save
  {
    my ($self) = @_;
    return $self->{_impl}->save;
  }

sub set
  {
    my ($self, $key, $val) = @_;
    return undef unless $key;
    my $oldval = $self->{_dictionary}->{$key};
    $self->{_dictionary}->{$key} = $val;
    return $oldval;
  }

1;
