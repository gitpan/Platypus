# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::FileSession;

use strict;
use Apache::Session::File ();
use Platypus::Session ();

@Platypus::FileSession::ISA = qw(Platypus::Session);
$Platypus::FileSession::DefaultSessionBase = "/tmp";

sub init
  {
    my ($self, $con, $id, $opts) = @_;

    $opts = {} unless ($opts && ref($opts) eq "HASH");
    $opts->{Directory} ||= $Platypus::FileSession::DefaultSessionBase;

    $self->{_impl} =
      tie %{ $self->{_dictionary} }, 'Apache::Session::File', $id, $opts;
    die "Session binding failed: $!\n" unless $self->{_dictionary};

    return 1;
  }

sub id
  {
    my ($self) = @_;
    return $self->{_dictionary}->{_session_id};
  }

1;
