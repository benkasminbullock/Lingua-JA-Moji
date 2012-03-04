#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Table::Readable qw/read_table/;
use ReadTranslations qw/read_translations_table get_lang_trans/;
use Template;
use utf8;
use FindBin;

my %vars;
my $trans = read_translations_table ("$FindBin::Bin/moji-trans.txt");

my %names = (
    kana => {
        en => 'kana',
        ja => '仮名',
    },
    hiragana => {
        en => 'hiragana',
        ja => 'ひらがな',
    },
    hira => {
        en => 'hiragana',
        ja => 'ひらがな',
    },
    katakana => {
        en => 'katakana',
        ja => 'カタカナ',
    },
    kata => {
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
    hw => {
        en => 'halfwidth katakana',
        ja => '半角カタカナ',
    },
    ascii => {
        en => 'printable ASCII characters',
        ja => '半角英数字',
    },
    wide => {
        en => 'wide ASCII characters',
        ja => '全角英数字',
    },
    braille => {
        en => 'Japanese braille',
        ja => '点字',
    },
    morse => {
        en => 'Japanese morse code (wabun code)',
        ja => '和文モールス符号',
    },
    new => {
        en => 'Modern kanji',
        ja => '親字体',
    },
    new_kanji => {
        en => 'Modern kanji',
        ja => '親字体',
    },
    old => {
        en => 'Pre-1949 kanji',
        ja => '旧字体',
    },
    old_kanji => {
        en => 'Pre-1949 kanji',
        ja => '旧字体',
    },
    cyrillic => {
        en => 'the Cyrillic (Russian) alphabet',
        ja => 'キリル文字',
    },
);

my @functions = read_table ("$FindBin::Bin/moji-functions.txt");

for my $function (@functions) {
    if ($function->{class}) {
        if ($function->{"explain.en"}) {
            bilingualize ($function, 'explain');
        }
        next;
    }
    if ($function->{eg}) {
        $function->{eg} =~ s/^\s+|\s+$//g;
    if ($function->{out} && $function->{expect}) {
        my $out;
        my $commands =<<EOF;
use lib '$FindBin::Bin/../lib';
use Lingua::JA::Moji '$function->{name}';
my $function->{out};
$function->{eg}
\$out = $function->{out};
EOF
        eval $commands;
        if ($@) {
            die "Eval died with $@ during\n$commands\n";
        }
        if ($out ne $function->{expect}) {
            die "Bad value '$out': expected '$function->{expect}'";
        }
    }
    }

    if ($function->{name} =~ /^([a-z_]+)2([a-z_]+)$/ &&
        $names{$1} && $names{$2}) {
        my ($from, $to) = ($1, $2);
        $function->{abstract}->{en} = "Convert $names{$from}{en} to $names{$to}{en}";
        $function->{abstract}->{ja} = "$names{$from}{ja}を$names{$to}{ja}に";
    }
    bilingualize ($function, 'desc');
    if ($function->{"bugs.en"}) {
        bilingualize ($function, 'bugs');
    }
}

$vars{functions} = \@functions;

my %outputs = (
    en => 'Moji.pod',
    ja => 'Moji-ja.pod',
);

my $verbose;

$vars{module} = 'Lingua::JA::Moji';

my $dir = "$FindBin::Bin/../lib/Lingua/JA";

my $tt = Template->new (
    ENCODING => 'UTF8',
    STRICT => 1,
    ABSOLUTE => 1,
    INCLUDE_PATH => [$FindBin::Bin],
);

for my $lang (qw/en ja/) {
    get_lang_trans ($trans, \%vars, $lang, $verbose);
    $vars{lang} = $lang;
    $tt->process ('Moji.pod.tmpl', \%vars, "$dir/$outputs{$lang}",
                  {binmode => 'utf8'})
        or die "" . $tt->error ();
}
exit;

sub bilingualize
{
    my ($function, $field) = @_;
    $function->{$field} = {};
    $function->{$field}{en} = $function->{"$field.en"};
    if ($function->{"$field.ja"}) {
        $function->{$field}{ja} = $function->{"$field.ja"};
    }
    else {
        $function->{$field}{ja} = $function->{"$field.en"};
    }
}

