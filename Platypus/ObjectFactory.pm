# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::ObjectFactory;

use strict;

use Apache ();
use Platypus::Authenticator ();
use Platypus::Cfg ();
use Platypus::Context ();
use Platypus::HTMLResponse ();
use Platypus::Request ();
use Platypus::FileSession ();
use Platypus::MemorySession ();
use Platypus::NullSession ();
use Platypus::SessionManager ();

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;
    return bless { _components => {} }, $class;
  }

sub component_base { "Platypus::Component" }

sub create_authenticator
  {
    my ($self, $con) = @_;
    return Platypus::Authenticator->new($con);
  }

sub create_component
  {
    my ($self, $con) = @_;
    my $req = $con->request;
    my $log = $con->log;
    my $cfg = $con->config;

    my $do_reload = $cfg->get('ComponentReload');
    my $mtime = -M $req->finfo;

    my $package = $self->_calculate_component_package($req);
    my $comp_ref = $self->{_components}{$package};
    if ($comp_ref)
      {
        if ($do_reload)
          {
            my $cached_mtime = $comp_ref->{mtime};
            return $package->new if ($package && $cached_mtime &&
                                     $cached_mtime <= $mtime);
            $log->debug("Reloading $package");
          }
        else
          {
            return $package->new;
          }
      }

    my $filename = $req->filename;
    my $code = $self->_wrap_component($filename, $package);

    $log->debug("Compiling $package");
    $self->_compile_component($code);

    $self->{_components}{$package} =
      {
       filename => $filename,
       code => $code,
       mtime => $mtime,
      };

    return $package->new;
  }

sub create_config
  {
    my ($self, $req, $opts) = @_;
    my $cfg = Platypus::Cfg->new($req, $opts);
    return $cfg;
  }

sub create_context
  {
    my ($self, $log) = @_;
    return Platypus::Context->new($log);
  }

sub create_request
  {
    my ($self, $rr, $log) = @_;
    return Platypus::Request->new($rr, $log);
  }

sub create_response
  {
    my ($self, $con) = @_;
    return Platypus::HTMLResponse->new($con);
  }

sub create_session
  {
    my ($self, $con, $id) = @_;
    my $cfg = $con->config;

    my $method = $cfg->get('SessionMethod');
    if ($method && $method eq 'Memory')
      {
        return Platypus::MemorySession->new($con, $id);
      }
    elsif ($method && $method eq 'None')
      {
        return Platypus::NullSession->new($con, $id);
      }

    my $opts = { Directory => $cfg->get('SessionBase') };

    return Platypus::FileSession->new($con, $id, $opts);
  }

sub create_session_manager
  {
    my ($self, $log) = @_;
    return Platypus::SessionManager->new($log);
  }

sub _calculate_component_package
  {
    my ($self, $req) = @_;

    my $uri = $req->uri;
    $uri = "/__INDEX__" if $uri eq "/";

    my $script_name = $req->path_info ?
      substr($uri, 0, length($uri)-length($req->path_info)) :
        $uri;

    # Escape everything into valid perl identifiers
    $script_name =~ s/([^A-Za-z0-9\/])/sprintf("_%2x",unpack("C",$1))/eg;

    # second pass cares for slashes and words starting with a digit
    $script_name =~ s{
			  (/+)       # directory
			  (\d?)      # package's first character
			 }[
			   "::" . ($2 ? sprintf("_%2x",unpack("C",$2)) : "")
			  ]egx;

    return $self->component_base . $script_name;
  }

sub _compile_component
  {
    my ($self, $code) = @_;

    Apache->untaint($$code);
    {
      no strict;
      eval $$code;
    }
    die $@ if $@;

    return 1;
  }

sub _slurp_file
  {
    my ($self, $filename) = @_;

    open FILE, $filename or
      die "Can't open $filename: $!\n";
    local $/ = undef;
    my $contents = <FILE>;
    close FILE;

    return \$contents;
  }

sub _wrap_component
  {
    my ($self, $filename, $package) = @_;

    my $script = $self->_slurp_file($filename);
    my $component_base = $self->component_base;

    if ($$script !~ m|sub output|)
      {
        $$script = join $$script, "sub output {\n", "\n}\n";
      }

    my $code = join('',
                    'package ', $package, ";\n",
                    'use ', $component_base, " ();\n",
                    "use Apache qw(exit);\n",
                    '@ISA = qw(', $component_base, ");\n",
                    $$script,
                    "1;\n");

    return \$code;
  }

1;
