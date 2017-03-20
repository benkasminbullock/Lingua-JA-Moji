use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
use Perl::Build::Pod ':all';
use Pod::Coverage;
my @files = (
    "$Bin/../lib/Lingua/JA/Moji.pod",
    "$Bin/../lib/Lingua/JA/Moji-ja.pod",
);

for my $filepath (@files) {
    my $errors = pod_checker ($filepath);
    ok (@$errors == 0, "No errors");
    ok (pod_encoding_ok ($filepath), "Pod encoding OK");
    ok (pod_no_cut ($filepath), "No stray =cut in POD");
}

my $pc = Pod::Coverage->new(
    package => 'Lingua::JA::Moji',
    private => [
	qr/(load|make)_.*|getdistfile|(co|i)nvert|split_match|ambiguous_reverse|add_boilerplate|hangul2kana/,
    ],
);
ok ($pc->coverage == 1, "Pod coverage OK");
if ($pc->coverage != 1) {
    my @undoc = $pc->naked ();
    for (@undoc) {
	note ("$_ is undocumented");
    }
}
done_testing ();
