#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Table::Readable qw/read_table/;
use Template;

use lib "$Bin/../copied/lib";
use Perl::Build qw/get_version get_commit get_info/;
use Perl::Build::Pod ':all';
use Table::Trans qw/read_trans get_lang_trans/;
use Deploy qw/do_system older/;

my %vars;
my $trans = read_trans ("$Bin/moji-trans.txt");

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
    hentaigana => {
	en => 'Hentaigana',
	ja => '変体仮名',
    },
);

my @notes = (qw/chouon passport wapuro/);

my @functions = read_table ("$Bin/moji-functions.txt");

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
use lib '$Bin/../lib';
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
		die "Bad value '$out': expected '$function->{expect}' from\n$commands\n";
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
    if ($function->{since}) {
	$function->{desc}{en} .= "\n\nThis was added to the module in version L</$function->{since}>.\n";
	$function->{desc}{ja} .= "\n\nL</$function->{since}>から\n";
    }
}

$vars{functions} = \@functions;

my %outputs = (
    en => 'Moji.pod',
    ja => 'Moji-ja.pod',
);

my $verbose;
my $force;

$vars{module} = 'Lingua::JA::Moji';

my $dir = "$Bin/../lib/Lingua/JA";

my @examples = <$Bin/../examples/*.pl>;
for my $example (@examples) {
    my $output = $example;
    $output =~ s/\.pl$/-out.txt/;
    if (older ($output, $example) || $force) {
        do_system ("perl -I$Bin/../lib $example > $output 2>&1", $verbose);
    }
}

my $tt = Template->new (
    ENCODING => 'UTF8',
    STRICT => 1,
    ABSOLUTE => 1,
    INCLUDE_PATH => [$Bin, pbtmpl (), "$Bin/../examples", ],
    FILTERS => {
        xtidy => [
            \& xtidy,
            0,
        ],
    },
);
my %pbv = (base => "$Bin/..");
$vars{version} = get_version (%pbv);
$vars{commit} = get_commit (%pbv);
$vars{info} = get_info (%pbv);

for my $lang (qw/en ja/) {
    get_lang_trans ($trans, \%vars, $lang, $verbose);
    $vars{lang} = $lang;
    my $out;
    $tt->process ('Moji.pod.tmpl', \%vars, \$out,
                  {binmode => 'utf8'})
        or die "" . $tt->error ();
    my $ofile = "$dir/$outputs{$lang}";
    if (-f $ofile) {
	chmod 0644, $ofile or die $!;
    }
    open my $output, ">:encoding(utf8)", $ofile or die "Can't open '$outputs{$lang}': $!";
    print $output $out;
    close $output or die $!;
    chmod 0444, $ofile or die $!;
}
exit;

# Make bilingual versions of the values, falling back to English if
# Japanese is not available.

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

