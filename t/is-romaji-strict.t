use warnings;
use strict;
use Test::More;
use Lingua::JA::Moji 'is_romaji_strict';

ok (is_romaji_strict ('Shigeru Yoshikawa'), "Shigeru Yoshikawa = Japanese");
ok (! is_romaji_strict ('Lolita'), "Lolita != Japanese");
ok (! is_romaji_strict ('Hu Piaoye'), "Hu Piaoye != Japanese");
ok (is_romaji_strict ('gottsuu suiterunen'), "gottsuu suiterunen");
ok (! is_romaji_strict ('kitchen'), "'kitchen' is not Japanese");
# Bug with upper/lower case vowels, did not put /i after qr/ for
# "$vowel_re" before "is_romaji_strict".
ok (! is_romaji_strict ('WHO'), "'WHO' is not Japanese");
ok (! is_romaji_strict ('irritate'), "double-r is not Japanese");
ok (! is_romaji_strict ('yya'), "double-y is not Japanese");
ok (! is_romaji_strict ('adithya'), "'adithya' is not Japanese");
ok (is_romaji_strict ('AREKKUSU'), "'AREKKUSU' is romaji");

# List of romanizations we don't want to allow.

my @bad_boys;
# These are bad with ye and yi.
my @ye_yi_bad = (qw/k d j t p r l n m/);
my @ye_yi = (qw/ye yi/);
for my $y (@ye_yi) {
    for my $b (@ye_yi_bad) {
	push @bad_boys, "$b$y";
    }
}
# These are bad with any vowel or with tsu or tu.
my @all_bad = (qw/v l wh wy x kw/);
my @small_bad = (qw/a i u e o tu tsu yu/);
for my $x (@small_bad) {
    for my $z (@all_bad) {
	push @bad_boys, "$z$x";
    }
}
# Other stuff we don't like.
push @bad_boys, (qw/
		       je
		       she
		       sye
		       syi
		       t'i
		       t'u
		       t'yu
		       thi
		       thy
		       thya
		       tsa
		       tse
		       tsi
		       tso
		       twu
		       we
		       wi
		  /);

my %c;

for my $bad_boy (@bad_boys) {		      
    if ($c{$bad_boy}) {
	print "duplicate $bad_boy\n";
    }
    $c{$bad_boy} = 1;
    ok (! is_romaji_strict ($bad_boy), "$bad_boy is not Japanese");
}
TODO: {
    local $TODO='bugs';
# Add bugs here.
#    ok (! is_romaji_strict ('1'), "'1' is not Japanese");
};

done_testing ();
