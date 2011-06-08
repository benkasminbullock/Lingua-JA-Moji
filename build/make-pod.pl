#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Table::Readable qw/read_table/;
use ReadTranslations qw/read_translations_table get_lang_trans/;
use Template;
use utf8;

my %vars;
my $trans = read_translations_table ('moji-trans.txt');
my $tt = Template->new (ENCODING => 'UTF8');

my %names = (
    kana => {
        en => 'kana',
        ja => '仮名',
    },
    hiragana => {
        en => 'hiragana',
        ja => 'ひらがな',
    },
    katakana => {
        en => 'katakana',
        ja => 'カタカナ',
    },
    circled => {
        en => 'circled katakana',
        ja => '丸付けカタカナ',
    },
    romaji => {
        en => 'romaji',
        ja => 'ローマ字',
    },
);

my @functions = read_table ('moji-functions.txt');

for my $function (@functions) {
    $function->{eg} =~ s/^\s+|\s+$//g;
    if ($function->{name} =~ /^([a-z]+)2([a-z]+)$/ &&
        $names{$1} && $names{$2}) {
        my ($from, $to) = ($1, $2);
        $function->{abstract}->{en} = "Convert $names{$from}{en} to $names{$to}{en}";
        $function->{abstract}->{ja} = "$names{$from}{ja}を$names{$to}{ja}に変換";
    }
    $function->{desc} = {};
    $function->{desc}{en} = $function->{"desc.en"};
    $function->{desc}{ja} = $function->{"desc.ja"};
}

$vars{functions} = \@functions;

my %outputs = (
    en => 'Moji.pod',
    ja => 'Moji-ja.pod',
);

my $verbose;

$vars{module} = 'Lingua::JA::Moji';

for my $lang (qw/en ja/) {
    get_lang_trans ($trans, \%vars, $lang, $verbose);
    $vars{lang} = $lang;
    $tt->process ('Moji.pod.tmpl', \%vars, $outputs{$lang},
                  {binmode => 'utf8'})
        or die "" . $tt->error ();
}

