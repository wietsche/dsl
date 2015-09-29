#!/usr/bin/perl
use File::Slurp;
use Lib::RE;

$script_file = $ARGV[0];
$script = read_file($script_file);

my $pc = RE::query($script,'');
print qq{ \r\r $pc \r\r};
