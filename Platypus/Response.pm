# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Response;

use strict;

$Platypus::Response::DefaultContentType = "text/plain";

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       _response => [],
       _cacheable => 1,
       _content_type => undef,
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init {}

sub append_to_response
  {
    my ($self, $buf) = @_;

    if ($buf)
      {
        my $buf_type = ref $buf;
        if ($buf_type && $buf_type eq 'SCALAR')
          {
            push @{ $self->{_response} }, $$buf;
          }
        elsif ($buf_type && $buf_type eq 'ARRAY')
          {
            push @{ $self->{_response} }, @$buf;
          }
        else
          {
            push @{ $self->{_response} }, $buf;
          }
      }

    return 1;
  }

sub as_string
  {
    my ($self) = @_;
    return join "", @{ $self->{_response} };
  }

sub cacheable
  {
    my ($self, $flag) = @_;
    $self->{_cacheable} = $flag if defined $flag; # allow 0 to unset
    return $self->{_cacheable};
  }

sub content_type
  {
    my ($self, $ct) = @_;
    $self->{_content_type} = $ct if $ct;
    return $self->{_content_type} ||
      $Platypus::Response::DefaultContentType;
  }

sub prepend_to_response
  {
    my ($self, $buf) = @_;

    if ($buf)
      {
        my $buf_type = ref $buf;
        if ($buf_type && $buf_type eq 'SCALAR')
          {
            unshift @{ $self->{_response} }, $$buf;
          }
        elsif ($buf_type && $buf_type eq 'ARRAY')
          {
            unshift @{ $self->{_response} }, @$buf;
          }
        else
          {
            unshift @{ $self->{_response} }, $buf;
          }
      }

    return 1;
  }

sub respond
  {
    my ($self, $fh) = @_;

    $fh ||= \*STDOUT;
    foreach my $l (@{ $self->response })
      {
        print $fh $l;
      }

    return 1;
  }

sub response
  {
    my ($self) = @_;
    return $self->{_response};
  }

1;
