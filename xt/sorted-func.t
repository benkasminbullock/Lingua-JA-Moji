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
while ($text =~ /=head1\s+([A-Z ]+)\s*\n(.*?)(?==head1)/gsm) {
    my $name = $1;
    if ($name eq 'SEE ALSO') {
	last;
    }
    my $section = $2;
    print "$name\n";
    my @sm;
    while ($section =~ /=head2\s+(.*)/g) {
	push @sm, $1;
    }
    my @sms = sort {uc $a cmp uc $b} @sm;
    is_deeply (\@sm, \@sms, "Modules in section $name are sorted");
}

done_testing ();
