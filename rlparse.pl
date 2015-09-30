#!/usr/bin/perl
use strict;
use warnings;

use File::Slurp;
use Lib::RE;
use Data::Dumper;


my $script_file = $ARGV[0];
my $node = $ARGV[1];

my $script = read_file($script_file);
my $pc = RE::query($script,$node);

print qq{ $pc \n};
