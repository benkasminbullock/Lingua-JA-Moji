use warnings;
use strict;
use Test::More tests => 8;
use Lingua::JA::Moji qw/kana2cyrillic cyrillic2katakana/;
use utf8;
binmode STDOUT, ':utf8';
my %examples = (
    'シンブン',  'симбун',      
    'サンカ',   'санка',        
    'カンイ',   'канъи',       
    'ホンヤ',   'хонъя',       
);

for my $kana (keys %examples) {
#    print "$kana\n";
    my $expect = $examples{$kana};
    my $cyrillic = kana2cyrillic ($kana);
#    print "$cyrillic $expect\n";
    ok ($cyrillic eq $expect);
    my $roundtrip = cyrillic2katakana ($cyrillic);
#    print "$roundtrip\n";
    ok ($roundtrip eq $kana);
}
