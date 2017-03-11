#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use File::Slurper 'read_text';
use FindBin '$Bin';
use JSON::Create 'create_json';
use Lingua::JA::Moji qw/romaji2hiragana InKana/;
my $text = read_text ("$Bin/hentaigana.txt");
my @h;
my $last = 0x1b001;
while ($text =~ /
		    ([0-9A-F]{5}).*
		    HENTAIGANA\sLETTER\s
		    (.*)\s*•\sderived\sfrom\s
		    (\S*)\s(.)
		/gx) {
    my $unicode = $1;
    my $kana = $2;
    my $der = $3;
    my $dcheck = $4;
    if (ord ($dcheck) != hex ($der)) {
	die "Mismatch $der $dcheck.\n";
    }
    if ($dcheck !~ /^\p{InCJKUnifiedIdeographs}$/) {
	die "Bad boy $dcheck.\n";
    }
    # Chouons look like hyphens so whap them before conving
    $kana =~ s/-//g;

    $kana = romaji2hiragana ($kana);
    # Remove non-kana characters
    $kana =~ s/[^\p{InKana}]//g;
    push @h, {
	# Unicode
	u => hex ($unicode),
	# Hiragana
	hi => $kana,
	# Kanji
	ka => $dcheck,
    };
    if (hex ($unicode) != $last + 1) {
	printf "Gap %x-$unicode.\n", $last;
    }
    $last = hex ($unicode);
}
#printf ("There are %d hentaigana.\n", scalar (@h));
binmode STDOUT, ":encoding(utf8)";
print create_json (\@h);
