# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Cfg;

use strict;
use Apache::ModuleConfig ();
use DynaLoader ();

if ($ENV{MOD_PERL})
  {
    no strict;
    @ISA = qw(DynaLoader);
    __PACKAGE__->bootstrap;
  }

sub new
  {
    my ($type, $req, $opts) = @_;
    my $class = ref($type) || $type;

    my $self = Apache::ModuleConfig->get($req, __PACKAGE__);
    bless $self, $class;

    $self->{Opts} = {};
    if ($opts && ref($opts) eq 'HASH')
      {
        foreach (keys %$opts)
          {
            $self->{Opts}->{$_} = $opts->{$_};
          }
      }

    return $self;
  }

sub get
  {
    my ($self, $key) = @_;
    return $self->{Opts}->{$key} || $self->{__PACKAGE__}->{$_};
  }

sub PlatypusAuthenRequire ($$$)
  {
    my ($cfg, $parms, $switch) = @_;
    $cfg->{Platypus}{AuthenRequire} = $switch;
  }

sub PlatypusCompileCheck ($$$)
  {
    my ($cfg, $parms, $switch) = @_;
    $cfg->{Platypus}{CompileCheck} = $switch;
  }

sub PlatypusComponentReload ($$$)
  {
    my ($cfg, $parms, $switch) = @_;
    $cfg->{Platypus}{ComponentReload} = $switch;
  }

sub PlatypusSessionBase ($$$)
  {
    my ($cfg, $parms, $arg) = @_;
    $cfg->{Platypus}{SessionBase} = $arg;
  }

sub PlatypusSessionMethod ($$$)
  {
    my ($cfg, $parms, $arg) = @_;
    $cfg->{Platypus}{SessionMethod} = $arg;
  }

1;
