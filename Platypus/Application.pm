# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Application;

use strict;

use Apache ();
use Apache::Constants qw(:common OPT_EXECCGI);
use Apache::Log ();
use Apache::Request ();
use Platypus::ObjectFactory ();

sub new
  {
    my ($type, $opts) = @_;
    my $class = ref($type) || $type;

    my $self = bless {}, $class;

    $self->opts($opts);
    $self->init;

    my $log = Apache->server->log;
    $self->log($log);

    my $ses_mgr = $self->factory->create_session_manager($log);
    $self->session_manager($ses_mgr);

    return $self;
  }

sub init
  {
    my ($self) = @_;
    $self->factory(new Platypus::ObjectFactory);
  }

sub handle_request ($$)
  {
    my ($self, $rr) = @_;
    my $factory = $self->factory;
    my $ses_mgr = $self->session_manager;

    my $cfg = $factory->create_config($rr, $self->opts);
    my $rc = $self->checkup($rr, $cfg);
    return $rc unless $rc == OK;

    my ($con, $req, $res, $ses);
    eval
      {
        $con = $factory->create_context;
        $con->application($self);
        $con->config($cfg);

        $req = $factory->create_request($rr);
        $con->request($req);

        $res = $factory->create_response($con);
        $con->response($res);

        my $ses_id = $ses_mgr->extract_id($req);
        if ($ses_id)
          {
            $ses = $ses_mgr->restore_session($con, $ses_id);
          }
        else
          {
            my $do_authen = $cfg->get('AuthenRequire');
            if ($do_authen)
              {
                my $authen = $factory->create_authenticator($con);
                return $authen->challenge($con) unless
                  $authen->authenticate($con);
              }
            $ses = $ses_mgr->create_session($con);
          }
        $con->session($ses);

        my $comp = $factory->create_component($con);
        $comp->output($con);

        if ($res->cacheable)
          {
            $req->header_out("Cache-control" => "no-cache");
            $req->header_out("Expires" =>
                             Apache::Request::expires($req, '-1d'));
          }

        $req->send_http_header($res->content_type);
        return OK if $req->header_only;

        $res->respond;
      };
    if ($@)
      {
        $req ||= $rr;
        chomp($@);
        $rc = $self->abort($con, $@);
      }

    eval
      {
        $ses_mgr->save_session($con) if $ses;
      };
    if ($@)
      {
        chomp($@);
        $rc = $self->cleanup_error($con, $@);
      }

    return $rc;
  }

sub abort
  {
    my ($self, $con, $err) = @_;
    $con->log->error($err);
    return SERVER_ERROR;
  }

sub checkup
  {
    my ($self, $rr, $cfg) = @_;

    my $do_compile_checks = $cfg->get('CompileCheck');

    if (-r $rr->finfo && -s _)
      {
        return DECLINED if -d _;

        if ($do_compile_checks)
          {
            $self->log->debug("Performing compile checks");
            unless ($rr->allow_options & OPT_EXECCGI)
              {
                $rr->log_reason("Options ExecCGI is off in this directory",
                                $rr->filename);
                return FORBIDDEN;
              }
            unless (-x _)
              {
                $rr->log_reason("file permissions deny server execution",
                                $rr->filename);
                return FORBIDDEN;
              }
          }

        return OK;
      }

    return NOT_FOUND;
  }

sub cleanup_error
  {
    my ($self, $con, $err) = @_;
    $con->log->error($err);
    return OK;
  }

sub factory
  {
    my ($self, $factory) = @_;
    $self->{_factory} = $factory if $factory;
    return $self->{_factory};
  }

sub log
  {
    my ($self, $log) = @_;
    $self->{_log} = $log if $log;
    return $self->{_log};
  }

sub opts
  {
    my ($self, $opts) = @_;
    $self->{_opts} = $opts if $opts;
    return $self->{_opts};
  }

sub session_manager
  {
    my ($self, $mgr) = @_;
    $self->{_session_manager} = $mgr if $mgr;
    return $self->{_session_manager};
  }

1;
