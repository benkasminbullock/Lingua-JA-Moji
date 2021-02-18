#!/home/ben/software/install/bin/perl
use Z;
use File::Versions 'make_backup';
my @files = <t/*.t>;
my $newuse = <<'EOF';
use FindBin '$Bin';
use lib "$Bin";
use LJMT;
EOF
for my $file (@files) {
    my $text = read_text ($file);
    if ($text =~ /use\s+LJMT/) {
	next;
    }
    print "-----------\n$file\n----------\n";
    if ($text =~ s!^.*use\s+Lingua::JA::Moji[^\n]+\n!$newuse!s) {
	$text =~ s!\s*use utf8;\s*!!;
	$text =~ s!binmode Test::More.*!!g;
	$text =~ s!use Test::More;!!;
	$text =~ s!^exit;!!gm;
#	print "$text";
	make_backup ($file);
	write_text ($file, $text);
    }
    else {
	print "$file failed\n";
    }
}
