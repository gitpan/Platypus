# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::MemorySession;

use strict;
use Apache::Session::SingleThread ();
use Platypus::Session ();

@Platypus::MemorySession::ISA = qw(Platypus::Session);

sub init
  {
    my ($self, $con, $id) = @_;

    undef $id unless length($id); # uhhh

    $self->{_impl} =
      tie %{ $self->{_dictionary} }, 'Apache::Session::SingleThread', $id;
    die "Session binding failed: $!\n" unless $self->{_dictionary};

    return 1;
  }

sub id
  {
    my ($self) = @_;
    return $self->{_dictionary}->{_session_id};
  }

1;
