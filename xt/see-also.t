# Check that the "SEE ALSO" part of the pod doesn't contain the same
# module twice and is sorted so that the modules mentioned are in
# case-insensitive alphabetical order.

use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use File::Slurper 'read_text';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

# Check no duplicates

# Read the file in & extract the section

my $text = read_text ("$Bin/../lib/Lingua/JA/Moji.pod");

$text =~ s!^.*=head1\s+SEE ALSO(.*?)=head1.*$!$1!gs;

my $mod_re = qr!=item\s+L<(.*?)>!;

my %modules;
while ($text =~ /$mod_re/g) {
    my $mod = $1;
    if ($mod eq 'Lingua::JA::Romanize::Japanese') {
	next;
    }
    ok (! $modules{$mod}, "Entry for $mod is not a duplicate");
    $modules{$mod} = 1;
}

# Check each subsection is in case-insensitive alphabetical order

while ($text =~ /=head2\s+([^\n]+)\n(.*?)(?==head2)/gsm) {
    my $name = $1;
    my $section = $2;
    $name =~ s!\n.*$!!gs;
    if ($name =~ /RFC/) {
	next;
    }
    my @sm;
    while ($section =~ /$mod_re/g) {
	push @sm, $1;
    }
    my @sms = sort {uc $a cmp uc $b} @sm;
    is_deeply (\@sm, \@sms, "Modules in section $name are sorted");
}

done_testing ();
