# -*- Mode: Perl; indent-tabs-mode: nil -*-

use strict;
use lib ".";

use ExtUtils::MakeMaker qw(WriteMakefile);

my %make_args =
  (
   'NAME' => 'Platypus',
   'VERSION_FROM' => 'Platypus.pm',
  );

WriteMakefile(%make_args);
