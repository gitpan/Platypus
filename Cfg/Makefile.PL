# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Platypus::Cfg;

use strict;
use lib "..";

use ExtUtils::MakeMaker qw(WriteMakefile);
use Apache::ExtUtils qw(command_table);
use Apache::src ();

my $ap_directives =
  [
   {
    name => 'PlatypusAuthenRequire',
    errmsg => 'On or Off',
    args_how => 'FLAG',
   },
   {
    name => 'PlatypusCompileCheck',
    errmsg => 'On or Off',
    args_how => 'FLAG',
   },
   {
    name => 'PlatypusComponentReload',
    errmsg => 'On or Off',
    args_how => 'FLAG',
   },
   {
    name => 'PlatypusSessionBase',
    errmsg => 'absolute path name',
    args_how => 'TAKE1',
   },
   {
    name => 'PlatypusSessionMethod',
    errmsg => 'File or Memory',
    args_how => 'TAKE1',
   },
  ];

my %make_args =
  (
   'NAME' => __PACKAGE__,
   'INC' => Apache::src->new->inc,
   'clean' => { FILES => "Cfg.xs" },
  );

command_table($ap_directives);
WriteMakefile(%make_args);
