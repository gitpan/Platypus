# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::HTMLResponse;

use strict;
use Platypus::Response;

@Platypus::HTMLResponse::ISA = qw(Platypus::Response);

sub init
  {
    my ($self) = @_;

    $self->body(qq(<body>\n\n));
    $self->title_separator(" | ");

    return 1;
  }

sub append_to_title
  {
    my ($self, $str) = @_;

    my $title = $self->title;
    return $title unless $str;

    if ($title)
      {
        my $sep = $self->title_separator || "";
        $self->title("$title$sep$str");
      }
    else
      {
        $self->title($str);
      }

    return $self->title;
  }

sub as_string
  {
    my ($self) = @_;

    my @res = ($self->doctype,
               $self->head,
               $self->body,
               @{ $self->response },
               $self->foot);

    return join "", @res;
  }

sub author
  {
    my ($self, $author) = @_;
    $self->{_author} = $author if $author;
    return $self->{_author};
  }

sub body
  {
    my ($self, $body) = @_;
    $self->{_body} = $body if $body;
    return $self->{_body};
  }

sub content_type { 'text/html' }

sub doctype
  {
    my ($self) = @_;

    return <<EOT;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
  "http://www.w3.org/TR/REC-html40/loose.dtd">

EOT
  }

sub foot
  {
    my ($self) = @_;

    return <<EOT;
</body>
</html>
EOT
  }

sub head
  {
    my ($self) = @_;

    my @head;
    my $title = $self->title;
    my $author = $self->author;

    push @head, qq(<head>\n);
    push @head, qq(  <title>$title</title>\n) if $title;
    push @head, qq(  <link rel="made" href="mailto:$author">\n) if $author;
    push @head, qq(</head>\n);

    return <<EOT;
<html>

@head
EOT
  }

sub respond
  {
    my ($self, $fh) = @_;
    $fh ||= \*STDOUT;

    print $fh $self->doctype;
    print $fh $self->head;
    print $fh $self->body;

    foreach my $l (@{ $self->response })
      {
        print $fh $l;
      }

    print $fh $self->foot;

    return 1;
  }

sub title
  {
    my ($self, $title) = @_;
    $self->{_title} = $title if $title;
    return $self->{_title};
  }

sub title_separator
  {
    my ($self, $sep) = @_;
    $self->{_title_sep} = $sep if $sep;
    return $self->{_title_sep};
  }

1;
