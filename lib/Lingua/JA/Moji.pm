=encoding UTF-8

=head1 NAME

Lingua::JA::Moji - Handle many kinds of Japanese characters

=head1 SYNOPSIS

Convert various types of characters into one another.

    use Lingua::JA::Moji qw/kana2romaji romaji2kana/;
    use utf8;
    my $romaji = kana2romaji ('あいうえお');
    # $romaji is now 'aiueo'.
    my $kana = romaji2kana ($romaji);
    # $kana is now 'アイウエオ'.

=head1 EXPORT

This module does not export any functions except on request.

=head1 ENCODING

All the functions in this module assume that you are using Perl's
Unicode encoding, and all input and output strings must be encoded
using Perl's so-called "utf8".

=head1 FUNCTIONS

=cut

package Lingua::JA::Moji;

use warnings;
use strict;

our $VERSION = '0.03';
use Carp;
use Lingua::JA::Moji::Convertor qw/load_convertor make_convertors/;
use Convert::Moji;
use utf8;
use File::ShareDir 'dist_file';
require Exporter;
our @ISA = qw(Exporter);

<<<<<<< HEAD
our @EXPORT_OK = qw/kana2hw
                    kana2romaji
                    romaji2kana
                    romaji2hiragana
		    hw2katakana
                    kata2hira
                    hira2kata
                    is_romaji
                    is_kana
                    is_hiragana
                    is_voiced
                    romaji_styles
                    romaji_vowel_styles
                    kana2circled
                    circled2kana
                    kana2katakana
                    normalize_romaji
                    InHankakuKatakana
                    InWideAscii/;
=======
our @EXPORT_OK = qw/
                    kana2romaji
                    romaji2hiragana
                    romaji_styles
                    romaji2kana
                    is_voiced
                    is_romaji
                    hira2kata
                    kata2hira
                    kana2hw
                    hw2katakana
                    InHankakuKatakana
                    wide2ascii
                    ascii2wide
                    InWideAscii
                    kana2morse
                    is_kana
                    is_hiragana
                    kana2katakana
                    kana2braille
                    braille2kana
                    kana2circled
                    circled2kana
                    normalize_romaji
                    /;
>>>>>>> 2ca4cb2d0af86723770ada06a3d2494a29dc4df7

our $AUTOLOAD;


# Kana ordered by consonant. Adds bogus "q" gyou for small vowels and
# "x" gyou for youon (ya, yu, yo) to the usual ones.

my %行 = (
    a => [qw/ア イ ウ エ オ/],
    k => [qw/カ キ ク ケ コ/],
    g => [qw/ガ ギ グ ゲ ゴ/],
    s => [qw/サ シ ス セ ソ/],
    z => [qw/ザ ジ ズ ゼ ゾ/],
    t => [qw/タ チ ツ テ ト/],
    d => [qw/ダ ヂ ヅ デ ド/],
    n => [qw/ナ ニ ヌ ネ ノ/],
    h => [qw/ハ ヒ フ ヘ ホ/],
    b => [qw/バ ビ ブ ベ ボ/],
    p => [qw/パ ピ プ ペ ポ/],
    m => [qw/マ ミ ム メ モ/],
    y => [qw/ヤ    ユ    ヨ/],
    xy => [qw/ャ    ュ    ョ/],
    r => [qw/ラ リ ル レ ロ/],
    w => [qw/ワ ヰ    ヱ ヲ/],
    q => [qw/ァ ィ ゥ ェ ォ/],
    v => [qw/ヴ/],
);

# Kana => consonant mapping.

my %子音;

for my $consonant (keys %行) {
    for my $kana (@{$行{$consonant}}) {
        if ($consonant eq 'a') {
            $子音{$kana} = '';
        } else {
            $子音{$kana} = $consonant;
        }
    }
}

# Vowel => kana mapping.

my %段 = (a => [qw/ア カ ガ サ ザ タ ダ ナ ハ バ パ マ ヤ ラ ワ ャ ァ/],
	  i => [qw/イ キ ギ シ ジ チ ヂ ニ ヒ ビ ピ ミ リ ヰ ィ/],
	  u => [qw/ウ ク グ ス ズ ツ ヅ ヌ フ ブ プ ム ユ ル ュ ゥ ヴ/],
	  e => [qw/エ ケ ゲ セ ゼ テ デ ネ ヘ ベ ペ メ レ ヱ ェ/],
	  o => [qw/オ コ ゴ ソ ゾ ト ド ノ ホ ボ ポ モ ヨ ロ ヲ ョ ォ/]);

# Kana => vowel mapping

my %母音;

# List of kana with a certain vowel.

my %vowelclass;

for my $vowel (keys %段) {
    my @kana_list = @{$段{$vowel}};
    for my $kana (@kana_list) {
	$母音{$kana} = $vowel;
    }
    $vowelclass{$vowel} = join '', @kana_list;
}

#for my $kana (sort keys %子音) {
#    print "$kana: ",$子音{$kana},$母音{$kana},"\n";
#}

# Kana gyou which can be preceded by a sokuon (small tsu).

# Added d to the list for ウッド BKB 2010-07-20 23:27:07
# Added z for "badge" etc.

my @takes_sokuon_行 = qw/s t k p d z/;
my @takes_sokuon = (map {@{$行{$_}}} @takes_sokuon_行);
my $takes_sokuon = join '', @takes_sokuon;

# N

# Kana gyou which need an apostrophe when preceded by an "n" kana.

my $need_apostrophe = join '', (map {@{$行{$_}}} qw/a y/);

# Gyou which turn an "n" into an "m" in some kinds of romanization

my $need_m = join '', (map {@{$行{$_}}} qw/p b m/);

# YOUON

# Small ya, yu, yo.

my $youon = join '', (@{$行{xy}});
my %youon = qw/a ャ u ュ o ョ ou ョ/;

# HEPBURN

# Hepburn irregular romanization

my %hepburn = qw/シ sh ツ ts チ ch ジ j ヅ z ヂ j フ f/;

# Hepburn map from vowel to list of kana with that vowel.

my %hep_vowel = (i => 'シチジヂ', u => 'ヅツフ');
my $hep_list = join '', keys %hepburn;

# Hepburn irregular romanization of ッチ as "tch".

my %hepburn_sokuon = qw/チ t/;
my $hep_sok_list = join '', keys %hepburn_sokuon;

# Hepburn variants for the youon case.

my %hepburn_youon = qw/シ sh チ ch ジ j ヂ j/;
my $is_hepburn_youon = join '', keys %hepburn_youon;

# Kunrei romanization

my %kunrei = qw/ヅ z ヂ z/;

my $kun_list = join '', keys %kunrei;

my %kunrei_youon = qw/ヂ z/;
my $is_kunrei_youon = join '', keys %kunrei_youon;

# LONG VOWELS

# Long vowels, another bugbear of Japanese romanization.

my @あいうえお = qw/a i u e o ou/;

# Various ways to display the long vowels.

my %長音表記;
@{$長音表記{circumflex}}{@あいうえお} = qw/â  î  û  ê  ô  ô/;
@{$長音表記{macron}}{@あいうえお}     = qw/ā  ī  ū  ē  ō  ō/;
@{$長音表記{wapuro}}{@あいうえお}     = qw/aa ii uu ee oo ou/;
@{$長音表記{passport}}{@あいうえお}   = qw/a  i  u  e  oh oh/;
@{$長音表記{none}}{@あいうえお}       = qw/a  i  u  e  o  o/;

=head2 kana2romaji

    use utf8;
    my $romaji = kana2romaji ("うれしいこども");

    # $romaji = "uresiikodomo"

Convert kana to a romanized form.

An optional second argument, a hash reference, controls the style of
conversion.

    use utf8;
    my $romaji = kana2romaji ("しんぶん", {style => "hepburn"});
    # $romaji = "shimbun"

The possible options are

=over

=item style

The style of romanization. The default form of romanization is
<<<<<<< HEAD
"Nippon-shiki". See
L<http://www.sljfaq.org/afaq/nippon-shiki.html>. The user can set the
conversion style to "hepburn" or "passport" or "kunrei". See
L<http://www.sljfaq.org/afaq/kana-roman.html>.
=======
"Nihon-shiki". See
L<http://www.sljfaq.org/afaq/nippon-shiki.html>. The user can set it
to "hepburn" or "passport" or "kunrei".
>>>>>>> 2ca4cb2d0af86723770ada06a3d2494a29dc4df7

=item use_m

If this is set to any "true" value, syllabic I<n>s (ん) which come
before "b" or "p" sounds, such as the first "n" in "shinbun" (しんぶん,
newspaper) will be converted into "m" rather than "n".

=item ve_type

C<ve_type> controls how long vowels are written. The default is to use
<<<<<<< HEAD
circumflexes to represent long vowels. If you set "ve_type" =>
"macron", then it uses macrons (the Hepburn system). If you set
C<< "ve_type" => "passport" >>, then it uses "oh" to write long "o"
vowels.
=======
circumflexes to represent long vowels. If you set C<< "ve_type" =>
"macron" >>, then it uses macrons (the Hepburn system). If you set
C<< "ve_type" => "passport" >>, then it uses "oh" to write long "o"
vowels. If you set C<< "ve_type" => "none" >>, then it does not use "h".
>>>>>>> 2ca4cb2d0af86723770ada06a3d2494a29dc4df7

=back

=cut

sub kana2romaji
{
    # Parse the options

    my ($input, $options) = @_;
    if (! utf8::is_utf8 ($input)) {
        carp "Input is not flagged as unicode: conversion will fail.";
        return;
    }
    $input = kana2katakana ($input);
    $options = {} if ! $options;
    my $debug = $options->{debug};
    my $kunrei;
    my $hepburn;
    my $passport;
    if ($options->{style}) {
        my $style = $options->{style};
        $kunrei   = 1 if $style eq 'kunrei';
	$passport = 1 if $style eq 'passport';
	$hepburn  = 1 if $style eq 'hepburn';
        if (!$kunrei && !$passport && !$hepburn && $style ne "nihon") {
            die "Unknown romanization style $options->{style}";
        }
    }
    my $wapuro;
    $wapuro   = 1 if $options->{wapuro};
#    print "wapuro is $wapuro\n";
    my $use_m = 0;
    if ($hepburn || $passport) { $use_m = 1 }
    if (defined($options->{use_m})) { $use_m = $options->{use_m} }
    my $ve_type = 'circumflex'; # type of vowel extension to use.
    if ($hepburn) {
	$ve_type = 'macron';
    }
    if ($wapuro) {
#        print "Wapuro romanization\n";
        $ve_type = 'wapuro';
    }
    if ($passport) {
	$hepburn = 1;
	$ve_type = 'passport';
	$use_m = 1;
    }
    if ($options->{ve_type}) {
	$ve_type = $options->{ve_type};
    }
    unless ($長音表記{$ve_type}) {
	print STDERR "Warning: unrecognized long vowel type '$ve_type'\n";
	$ve_type = 'circumflex';
    }

    # Start of conversion

    # 撥音 (ん)
    $input =~ s/ン(?=[$need_apostrophe])/n\'/g;
    if ($use_m) {
	$input =~ s/ン(?=[$need_m])/m/g;
    }
    $input =~ s/ン/n/g;
    # 促音 (っ)
    if ($hepburn) {
	$input =~ s/ッ([$hep_sok_list])/$hepburn_sokuon{$1}$1/g;
    }
    $input =~ s/ッ([$takes_sokuon])/$子音{$1}$1/g;
    if ($debug) {
        print "* $input\n";
    }
    # 長音 (ー)
    for my $vowel (@あいうえお) {
	my $ve = $長音表記{$ve_type}->{$vowel};
	my $vowelclass;
	my $vowel_kana;
	if ($vowel eq 'ou') {
	    $vowelclass = $vowelclass{o};
	    $vowel_kana = 'ウ';
	} else {
	    $vowelclass = $vowelclass{$vowel};
	    $vowel_kana = $段{$vowel}->[0];
	}
	# 長音 (ー) + 拗音 (きょ)
	my $y = $youon{$vowel};
#        if ($debug) { print "Before youon: $input\n"; }
	if ($y) {
	    if ($hepburn) {
		$input =~ s/([$is_hepburn_youon])${y}[ー$vowel_kana]/$hepburn_youon{$1}$ve/g;
	    }
	    $input =~ s/([$vowelclass{i}])${y}[ー$vowel_kana]/$子音{$1}y$ve/g;
	}
#        if ($debug) { print "After youon: $input\n"; }
	if ($hepburn && $hep_vowel{$vowel}) {
	    $input =~ s/([$hep_vowel{$vowel}])[ー$vowel_kana]/$hepburn{$1}$ve/g;
	}
	$input =~ s/${vowel_kana}[ー$vowel_kana]/$ve/g;
#        if ($debug) { print "Before vowelclass: $input\n"; }
	$input =~ s/([$vowelclass])[ー$vowel_kana]/$子音{$1}$ve/g; 
#        if ($debug) { print "After vowelclass: $input\n"; }
    }
    if ($debug) {
        print "** $input\n";
    }
    # 拗音 (きょ)
    if ($hepburn) {
	$input =~ s/([$is_hepburn_youon])([$youon])/$hepburn_youon{$1}$母音{$2}/g;
    }
    elsif ($kunrei) {
	$input =~ s/([$is_kunrei_youon])([$youon])/$kunrei_youon{$1}y$母音{$2}/g;
    }
    $input =~ s/([$vowelclass{i}])([$youon])/$子音{$1}y$母音{$2}/g;
    if ($debug) {
        print "*** $input\n";
    }
    # その他
    $input =~ s/([アイウエオヲ])/$母音{$1}/g;
    $input =~ s/([ァィゥェォ])/q$母音{$1}/g;
    if ($debug) {
        print "**** $input\n";
    }
    if ($hepburn) {
	$input =~ s/([$hep_list])/$hepburn{$1}$母音{$1}/g;
    }
    elsif ($kunrei) {
	$input =~ s/([$kun_list])/$kunrei{$1}$母音{$1}/g;
    }
    $input =~ s/([カ-ヂツ-ヱヴ])/$子音{$1}$母音{$1}/g;
    $input =~ s/q([aiueo])/x$1/g;
    return $input;
}

=head2 romaji2hiragana

Convert romanized Japanese into hiragana. This takes the same options
as L<romaji2kana>.

=cut

sub romaji2hiragana
{
    my $katakana = romaji2kana(@_, {wapuro => 1});
#    print "$katakana\n";
    return kata2hira ($katakana);
}


=head2 romaji_styles

    my @styles = romaji_styles ();
    # Returns a true value
    romaji_styles ("hepburn");
    # Returns the undefined value
    romaji_styles ("frogs");

Given an argument, return whether it is a legitimate style of romanization.

Without an argument, return a list of possible styles, as an array of
hash values, with each hash element containing "abbrev" as a short
name and "full_name" for the full name of the style.

=cut

sub romaji_styles
{
    my ($check) = @_;
        my @styles = 
            (
         {
          abbrev    => "hepburn",
          full_name => "Hepburn",
      },
         {
          abbrev    => 'nihon',
          full_name => 'Nihon-shiki',
      },
         {
          abbrev    => 'kunrei',
          full_name => 'Kunrei-shiki',
      }
         );
    if (! defined ($check)) {
        return (@styles);
    } else {
        for my $style (@styles) {
            if ($check eq $style->{abbrev}) {
                return 1;
            }
        }
        return;
    }
}

# Check whether this vowel style is allowed.

sub romaji_vowel_styles
{
    my ($check) = @_;
    my @styles = (
    {
        abbrev    => "macron",
        full_name => "Macron",
    },
    {
        abbrev    => 'circumflex',
        full_name => 'Circumflex',
    },
    {
        abbrev    => 'wapuro',
        full_name => 'Wapuro',
    },
    {
        abbrev    => 'passport',
        full_name => 'Passport',
    },
    {
        abbrev    => 'none',
        full_name => "Do not indicate",
    },
    );
    if (! defined ($check)) {
        return (@styles);
    } else {
        for (@styles) {
            if ($check eq $_->{abbrev}) {
                return 1;
            }
            return;
        }
    }

}

my $romaji2katakana;
my $romaji_regex;

my %longvowels;
@longvowels{qw/â  î  û  ê  ô/}  = qw/aー iー uー eー oー/;
@longvowels{qw/ā  ī  ū  ē  ō/}  = qw/aー iー uー eー oー/;
my $longvowels = join '|', sort {length($a)<=>length($b)} keys %longvowels;

=head2 romaji2kana

     my $kana = romaji2kana ('yamaguti');
     # $kana = 'ヤマグチ';


Convert romanized Japanese to kana. The romanization is highly liberal
and will attempt to convert any romanization it sees into kana.

     my $kana = romaji2kana ($romaji, {wapuro => 1});

Use an option C<< wapuro => 1 >> to convert long vowels into the
equivalent kana rather than I<chouon>.

Convert romanized Japanese (romaji) into katakana. If you want to
convert romanized Japanese into hiragana, use L<romaji2hiragana>
instead of this.

=cut

sub romaji2kana
{
    if (!$romaji2katakana) {
	$romaji2katakana = load_convertor ('romaji','katakana');
	$romaji_regex = Lingua::JA::Moji::Convertor::make_regex (keys %$romaji2katakana);
    }
    my ($input, $options) = @_;
    $input = lc $input;
    # Deal with long vowels
    $input =~ s/($longvowels)/$longvowels{$1}/g;
    if (!$options || !$options->{wapuro}) {
        # Doubled vowels to chouon
        $input =~ s/([aiueo])\1/$1ー/g;
    }
    # Deal with double consonants
    # shimbun -> しんぶん
    $input =~ s/m(?=[pb]y?[aiueo])/ン/g;
    # tcha, ccha -> っちゃ
    $input =~ s/[ct](?=(ch|t)[aiueo])/ッ/g;
    # kkya -> っきゃ etc.
    $input =~ s/([ksthmrgzdbp])(?=\1y?[aiueo])/ッ/g;
    # ssha -> っしゃ
    $input =~ s/([s])(?=\1h[aiueo])/ッ/g;
    # oh{consonant} -> oo
    $input =~ s/oh(?=[ksthmrgzdbp])/オオ/g;
    # Substitute all the kana.
    $input =~ s/($romaji_regex)/$$romaji2katakana{$1}/g;
    return $input;
}

=head2 is_voiced

    if (is_voiced ('が')) {
         print "が is voiced.\n";
    }

Given a kana or romaji input, C<is_voiced> returns a true value if the
sound is a voiced sound like I<a>, I<za>, I<ga>, etc. and the
undefined value if not.

=cut

sub is_voiced
{
    my ($sound) = @_;
    if (is_kana ($sound)) {
        $sound = kana2romaji ($sound);
    }
    elsif (my $romaji = is_romaji ($sound)) {
        # Normalize to nihon shiki so that we don't have to worry
        # about ch, j, ts, etc. at the start of the sound.
        $sound = $romaji;
    }
    if ($sound =~ /^[aiueogzbpmnry]/) {
        return 1;
    } else {
        return;
    }
}

=head2 is_romaji

    # The following line returns "undef"
    is_romaji ("abcdefg");
    # The following line returns a defined value
    is_romaji ("atarimae");

Detect whether a string of alphabetical characters, which may also
include characters with macrons or circumflexes, "looks like"
romanized Japanese. If the test is successful, returns the romaji in a
canonical form.

This functions by converting the string to kana and seeing if it
converts cleanly or not.

=cut

sub is_romaji
{
    my ($romaji) = @_;
    if ($romaji =~ /[^\sa-zāīūēōâîûêô'-]/i) {
        return;
    }
    my $kana = romaji2kana ($romaji, {wapuro => 1});
#    print "$kana\n";
    if ($kana =~ /^[ア-ンー\s]+$/) {
#    print kana2romaji ($kana, {wapuro => 1}), "\n";
        return kana2romaji ($kana, {wapuro => 1});
    }
    return;
}

=head2 hira2kata

    my $katakana = hira2kata ($hiragana);

C<hira2kata> converts hiragana into katakana. If the input is a list,
it converts each element of the list, and if required, returns a list
of the converted inputs, otherwise it returns a concatenation of the
strings.

    my @katakana = hira2kata (@hiragana);

This does not convert chouon signs.

=cut

sub hira2kata
{
    my (@input) = @_;
    for (@input) {tr/ぁ-ん/ァ-ン/}
    return wantarray ? @input : "@input";
}

=head2 kata2hira

     my $hiragana = kata2hira ('カキクケコ');
     # $hiragana = 'かきくけこ';

C<kata2hira> converts full-width katakana into hiragana. If the input
is a list, it converts each element of the list, and if required,
returns a list of the converted inputs, otherwise it returns a
concatenation of the strings.

    my @hiragana = hira2kata (@katakana);

This function does not convert chouon signs into long vowels. It also
does not convert half-width katakana into hiragana.

=cut

sub kata2hira
{
    my (@input) = @_;
    for (@input) {tr/ァ-ン/ぁ-ん/}
    return wantarray ? @input : "@input";
}

# Make the list of dakuon stuff.

sub make_dak_list
{
#    my @gyou = @_;
    my @dak_list;
    for (@_) {
	push @dak_list, @{$行{$_}};
	push @dak_list, hira2kata (@{$行{$_}});
    }
    return @dak_list;
}

my $strip_daku;

sub load_strip_daku
{
    if (!$strip_daku) {
	my %濁点;
	@濁点{(make_dak_list (qw/g d z b/))} = 
	    map {$_."゛"} (make_dak_list (qw/k t s h/));
	@濁点{(make_dak_list ('p'))} = map {$_."゜"} (make_dak_list ('h'));
	my $濁点 = join '', keys %濁点;
	$strip_daku = make_convertors("ten_joined", "ten_split", \%濁点);
    }
}

my %濁点;
@濁点{(make_dak_list (qw/g d z b/))} = 
    map {$_."゛"} (make_dak_list (qw/k t s h/));
@濁点{(make_dak_list ('p'))} = map {$_."゜"} (make_dak_list ('h'));


#my %kata2hw = reverse %{$hwtable};
#my $kata2hw = \%kata2hw;

#my $hwregex = join '|',sort { length($b) <=> length($a) } keys %{$hwtable};
#print $hwregex,"\n";

sub kana2hw2
{
    my $conv = Convert::Moji->new (["oneway", "tr", "あ-ん", "ア-ン"],
				   ["file",
				    getdistfile("katakana2hw_katakana")]);
    return $conv;
}

my $kata2hw;

=head2 kana2hw

     my $half_width = kana2hw ('あいウカキぎょう。');
     # $half_width = 'ｱｲｳｶｷｷﾞｮｳ｡'

C<kana2hw> converts hiragana, katakana, and fullwidth Japanese
punctuation to halfwidth katakana and halfwidth punctuation. Its
function is similar to the Emacs command C<japanese-hankaku-region>.
For the opposite function,
see L<hw2katakana>.

=cut

sub kana2hw
{
   my ($input) = @_;
   $input = hira2kata ($input);
   if (!$kata2hw) {
       $kata2hw = make_convertors ('katakana','hw_katakana');
#       print $kata2hw->{カ},"\n";
   }
#   $input =~ tr/あ-ん/ア-ン/;
#   while ($input =~ /([ア-ン])/g) {
#       print ".";
#       print $$kata2hw{$1};
#   }
#   $input =~ s/([ア-ン])/$$kata2hw{$1}/g;
   
   return $kata2hw->convert ($input);
}

=head2 hw2katakana

     my $full_width = kana2hw ('ｱｲｳｶｷｷﾞｮｳ｡');
     # $full_width = 'アイウカキギョウ。'；

C<hw2katakana> converts halfwidth katakana and Japanese punctuation to
fullwidth katakana and punctuation. Its function is similar to the
Emacs command C<japanese-zenkaku-region>. For the opposite function,
see L<kana2hw>.

=cut

sub hw2katakana
{
    my ($input) = @_;
   if (!$kata2hw) {
       $kata2hw = make_convertors ('katakana','hw_katakana');
#       print $kata2hw->{カ},"\n";
   }
#    $input =~ s/($hwregex)/${$hwtable}{$1}/g;
    return $kata2hw->invert ($input);
}

=head2 InHankakuKatakana

    use Lingua::JA::Moji qw/InHankakuKatakana/;
    use utf8;
    if ('ｱ' =~ /\p{InHankakuKatakana}/) {
        print "ｱ is half-width katakana\n";
    }

C<InHankakuKatakana> is a character class for use in regular
expressions with C<\p> which can validate halfwidth katakana.

=cut

sub InHankakuKatakana
{
    return <<'END';
+utf8::Katakana
&utf8::InHalfwidthAndFullwidthForms
END
}

=head2 wide2ascii

     my $ascii = wide2ascii ('ａｂＣＥ０１９');
     # $ascii = 'abCE019'

Convert the "wide ASCII" used in Japan (fullwidth ASCII, 全角英数字)
into usual ASCII symbols (半角英数字).

=cut

sub wide2ascii
{
    my ($input) = @_;
    $input =~ tr/\x{3000}\x{FF01}-\x{FF5E}/ -~/;
    return $input;
}

=head2 ascii2wide

Convert usual ASCII symbols (半角英数字) into the "wide ASCII" used in
Japan (fullwidth ASCII, 全角英数字).


=cut

sub ascii2wide
{
    my ($input) = @_;
    $input =~ tr/ -~/\x{3000}\x{FF01}-\x{FF5E}/;
    return $input;
}

=head2 InWideAscii

    use Lingua::JA::Moji qw/InWideAscii/;
    use utf8;
    if ('Ａ' =~ /\p{InWideAscii}/) {
<<<<<<< HEAD
        print "Ａ is wide ascii\n";
=======
        print "Ａ is half-width katakana\n";
>>>>>>> 2ca4cb2d0af86723770ada06a3d2494a29dc4df7
    }

This is a character class for use with \p which matches a "wide ascii"
(全角英数字).

=cut

sub InWideAscii
{
    return <<'END';
FF01 FF5E
3000
END
}

my $kana2morse;

sub load_kana2morse
{
    if (!$kana2morse) {
	$kana2morse = Lingua::JA::Moji::make_convertors ('katakana', 'morse');
    }
}

=head2 kana2morse

Convert Japanese kana into Morse code

=cut

sub kana2morse
{
    my ($input) = @_;
    load_kana2morse;
    $input = hira2kata ($input);
    $input =~ tr/ァィゥェォャュョ/アイウエオヤユヨ/;
    load_strip_daku;
    $input = $strip_daku->convert ($input);
    $input = join ' ', (split '', $input);
    $input = $kana2morse->convert ($input);
    return $input;
}


sub getdistfile
{
    my ($filename) = @_;
    my $file = dist_file ('Lingua-JA-Moji', $filename.".txt");
    return $file;
}

sub sin {my @y=split ''; join ' ',@y}
sub sout {my @y=split ' '; join '',@y}

sub kana2morse2
{
    my $file = getdistfile ('katakana2morse');
    my $conv = Convert::Moji->new (["oneway","tr", "あ-ん", "ア-ン"],
				   ["oneway","tr", "ァィゥェォャュョ", "アイウエオヤユヨ"],
				   ["table", \%濁点],
				   ["code", \&sin , \&sout],
				   ["file", $file],
			       );
    return $conv;
}

sub morse2kana
{
    my ($input) = @_;
    load_kana2morse;
    my @input = split ' ',$input;
    for (@input) {
	$_ = $kana2morse->invert ($_);
    }
    $input = join '',@input;
    $input = $strip_daku->invert ($input);
    return $input;
}

my $kana2braille;

sub load_kana2braille
{
    if (!$kana2braille) {
	$kana2braille = Lingua::JA::Moji::make_convertors ('katakana', 'braille');
    }
}

my %nippon2kana;

for my $k (keys %行) {
    for my $ar (@{$行{$k}}) {
	my $vowel = $母音{$ar};
	my $nippon = $k.$vowel;
	$nippon2kana{$nippon} = $ar;
# 	print "$nippon $ar\n";
    }
}

=head2 is_kana

Returns a true value if its argument is a string of kana, or an
undefined value if not.

=cut

sub is_kana
{
    my ($may_be_kana) = @_;
    if ($may_be_kana =~ /^[あ-んア-ン]+$/) {
        return 1;
    }
    return;
}

=head2 is_hiragana

Returns a true value if its argument is a string of kana, or an
undefined value if not.

=cut

sub is_hiragana
{
    my ($may_be_kana) = @_;
    if ($may_be_kana =~ /^[あ-ん]+$/) {
        return 1;
    }
    return;
}

=head2 kana2katakana

Convert either katakana or hiragana to katakana.

=cut

sub kana2katakana
{
    my ($input) = @_;
    $input = hira2kata($input);
    if ($input =~ /\p{InHankakuKatakana}/) {
	$input = hw2katakana($input);
    }
    return $input;
}

sub brailleon
{
    s/(.)゛([ャュョ])/'⠘'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    s/(.)゜([ャュョ])/'⠨'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    s/(.)([ャュョ])/'⠈'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    s/([$vowelclass{o}])ウ/$1ー/g;
    return $_;
}

sub brailleback
{
    s/⠘(.)/$nippon2kana{$子音{$1}.'i'}.'゛'.$youon{$母音{$1}}/eg;
    s/⠨(.)/$nippon2kana{$子音{$1}.'i'}.'゜'.$youon{$母音{$1}}/eg;
    s/⠈(.)/$nippon2kana{$子音{$1}.'i'}.$youon{$母音{$1}}/eg;
    return $_;
}

sub brailletrans {s/(.)([⠐⠠])/$2$1/g;return $_}
sub brailletransinv {s/([⠐⠠])(.)/$2$1/g;return $_}

sub kana2braille2
{
    my $conv = Convert::Moji->new (["table",\%濁点],
				   ["code",\&brailleon,\&brailleback],
				   ["file",getdistfile ("katakana2braille")],
				   ["code",\&brailletrans,\&brailletransinv],
			       );
    return $conv;
}

=head2 kana2braille

Converts kana into the equivalent Japanese braille (I<tenji>) forms.

=cut


sub kana2braille
{
    my ($input) = @_;
    load_kana2braille;
    $input = kana2katakana ($input);
    load_strip_daku;
    $input = $strip_daku->convert ($input);
    $input =~ s/(.)゛([ャュョ])/'⠘'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    $input =~ s/(.)゜([ャュョ])/'⠨'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    $input =~ s/(.)([ャュョ])/'⠈'.$nippon2kana{$子音{$1}.$母音{$2}}/eg;
    $input =~ s/([$vowelclass{o}])ウ/$1ー/g;
#    print $input,"\n";
    $input = $kana2braille->convert ($input);
    $input =~ s/(.)([⠐⠠])/$2$1/g;
#    print $input,"\n";
    return $input;
}

=head2 braille2kana

Converts Japanese braille (I<tenji>) into the equivalent katakana.

=cut

sub braille2kana
{
    my ($input) = @_;
    load_kana2braille;
    $input =~ s/([⠐⠠])(.)/$2$1/g;
    $input = $kana2braille->invert ($input);
    $input =~ s/⠘(.)/$nippon2kana{$子音{$1}.'i'}.'゛'.$youon{$母音{$1}}/eg;
    $input =~ s/⠨(.)/$nippon2kana{$子音{$1}.'i'}.'゜'.$youon{$母音{$1}}/eg;
    $input =~ s/⠈(.)/$nippon2kana{$子音{$1}.'i'}.$youon{$母音{$1}}/eg;
    $input = $strip_daku->invert ($input);
    return $input;
}

my $circled_conv;

sub load_circled_conv
{
    if (!$circled_conv) {
	$circled_conv = make_convertors ("katakana", "circled");

    }
}

=head2 kana2circled

C<kana2circled> converts kana into the "circled katakana" of Unicode.

=cut

sub kana2circled
{
    my ($input) = @_;
    $input = kana2katakana($input);
    load_strip_daku;
    $input = $strip_daku->convert($input);
    load_circled_conv;
    $input = $circled_conv->convert ($input);
    return $input;
}

=head2 circled2kana

C<circled2kana> converts the "circled katakana" of Unicode into the
usual katakana.

=cut

sub circled2kana
{
    my ($input) = @_;
    load_circled_conv;
    $input = $circled_conv->invert ($input);
    $input = $strip_daku->invert($input);
    return $input;
}

=head2 normalize_romaji

C<normalize_romaji> converts romanized Japanese to a canonical form,
which is based on the Nippon-shiki romanization, but without
representing long vowels using a circumflex.

=cut

sub normalize_romaji
{
    my ($romaji) = @_;
    my $kana = romaji2kana ($romaji, {ve_type => 'wapuro'});
    $kana =~ s/[っッ]/xtu/g;
    my $romaji_out = kana2romaji ($kana, {ve_type => 'wapuro'});
}

# sub AUTOLOAD {
#     my ($input) = @_;
#     my $name = $AUTOLOAD;
#     $name =~ s/.*://;   # strip fully-qualified portion
#     if ($name =~ /(\w+)2(\w+)/) {
# 	my $incode = $1;
# 	if ($incode eq 'kana') {
# 	    $input = kana2katakana($input);
# 	    $incode = 'katakana';
# 	}
# 	my $conv = make_convertors ($incode, $2);
# 	if ($conv) {
# 	    return $conv->convert($input);
# 	}
#     }
#     print STDERR "Can't find a suitable convertor for '$name'.\n";
#     return;
# }

1; # End of Lingua::JA::Moji


__END__

=head1 AUTHOR

Ben Bullock, C<< <bkb@cpan.org> >>

=head1 SUPPORT

=head2 Mailing list

I have set up a mailing list for this module and L<Convert::Moji> at
L<http://groups.google.com/group/perl-moji>. If you have any questions
about either of these modules, please ask on the mailing list rather
than sending me email, because I would prefer that a record of the
conversation can be kept for the future reference of other users.

=head2 Examples

For examples of this module in use, see my website
L<http://www.lemoda.net/lingua-ja-moji/index.html>. This page links to
examples which I've set up on the web specifically to show this module
in action.

=head2 Bugs

Please send bug reports to the Perl bug tracker at rt.cpan.org, or
send them to the mailing list.

There are some known bugs or issues with romaji to kana conversion and
vice-versa. I'm still working on these.

=head1 STATUS

This module is "alpha" (that is a computerese euphemism for "the
module is badly-formed and unfinished") and the external interface is
liable to change drastically in the future. If you have a request,
please speak up.

Please also note that some of this documentation is not finished yet,
some of the functions documented here don't exist yet.

=head1 SEE ALSO

There are some other useful Perl modules already on CPAN as follows.

=head2 Japanese kana/romanization

=over

=item L<Data::Validate::Japanese>

This is where I got several of the ideas for this module from. It
contains validators for kanji and kana.

=item L<Lingua::JA::Kana>

This is where I got several of the ideas for this module from. It
contains convertors for hiragana, katakana (fullwidth only), and
romaji. The romaji conversion is less complete than this module but
more compact and probably much faster, if you need high speed
romanization.

=item L<Lingua::JA::Romanize::Japanese>

Romanization of Japanese. The module also includes romanization of
kanji via the kakasi kanji to romaji convertor, and other functions.

=item L<Lingua::JA::Romaji::Valid>

Validate romanized Japanese.

=item L<Lingua::JA::Hepburn::Passport>

=back

=head2 Other

=over

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008-2010 Ben Bullock, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
