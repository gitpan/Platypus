# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::SessionManager;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;
    return bless {}, $class;
  }

sub construct_url
  {
    my ($self, $con, $uri, $args, $path_info) = @_;
    my $req = $con->request;
    my $ses = $con->session;
    my $id = $ses->id;

    $path_info =~ s|^/||;
    $args =~ s|^\?||;

    if ($uri)
      {
        $uri = join('/', $req->location, $uri) unless $uri =~ m|^/|;
      }
    else
      {
        $uri = $req->script_name;
        $uri =~ s|/${id}.*$||;
      }

    $uri = join("/", $uri, $id) if $id;
    $uri = join("/", $uri, $path_info) if $path_info;
    $uri = join("?", $uri, $args) if $args;

    return $uri;
  }

sub create_session
  {
    my ($self, $con) = @_;
    my $app = $con->application;
    my $req = $con->request;
    my $log = $con->log;

    my $ses = $app->factory->create_session($con);
    my $id = $ses->id;

    $log->debug("Created session $id");

    return $ses;
  }

sub extract_id
  {
    my ($self, $req) = @_;

    my $path_info = $req->path_info or
      return "";

    (my $new_path_info = $path_info) =~ s|/([^/]+)||;
    my $id = $1;
    $new_path_info ||= "";

    if ($id)
      {
        $req->path_info($new_path_info);

        my $uri = $req->uri;
        $uri =~ s|$path_info|$new_path_info|;
        $req->uri($uri);

        return $id;
      }

    return "";
  }

sub restore_session
  {
    my ($self, $con, $id) = @_;
    my $app = $con->application;
    my $req = $con->request;
    my $log = $con->log;

    my $ses = $app->factory->create_session($con, $id);

    $log->debug("Restored session $id");

    return $ses;
  }

sub save_session
  {
    my ($self, $con) = @_;
    my $ses = $con->session;
    my $log = $con->log;

    $ses->save;

    my $id = $ses->id;
    $log->debug("Saved session $id");

    return 1;
  }

1;
