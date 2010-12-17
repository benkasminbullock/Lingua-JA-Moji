use strict;
use warnings;
use charnames ':full';
use Encode;
use Encode::JP::H2Z;
use open qw/:utf8 :std/;

for my $line (split /\n/, do "unicore/Name.pl") {
    next unless $line =~ /^(\S+)\s+(.+)$/;
    my ($hex, $name) = ($1, $2);
    
    next unless $name =~ /^KATAKANA/;
    
    my $zenkana = chr charnames::vianame($name);
    my $hankana = do {
        my $c = Encode::encode('euc-jp', $zenkana);
        Encode::JP::H2Z::z2h(\$c);
        Encode::decode('euc-jp', $c);
    };
    
    next if $hankana eq '?'; # KATAKANA LETTER SMALL KU etc...

    printf "%s %s\n", $zenkana, $hankana;
}
