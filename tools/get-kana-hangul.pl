#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use Deploy 'file_slurp';
my $in = 'hangul.txt';
my %first2hangul;
my %rest2hangul;
binmode STDOUT, ":utf8";
open my $i, "<:encoding(utf8)", $in or die $!;

my $col = 0;
my $row = 0;
my @values;
my @row;
while (<$i>) {
    if (/<tr.*>/i) {
        $col = 0;
    }
    elsif (m!</tr>!i) {
        my @copy = @row;
#        print "$row: @copy\n";
        push @values, \@copy;
        $row++;
        
        @row = ();
    }
    elsif (m!<td.*colspan=5.*>（同左）</td>!i) {
#        print "yes\n";
        @row[10..14] = @row[5..9];
    }
    elsif (m!<td.*colspan=5.*>（同上）</td>!i) {
#        print "yes\n";
        @row[5..9] = @{$values[-1]}[5..9];
    }
    elsif (m!<td.*>(.*)</td>!i) {
        my $e = $1;
        $e =~ s/&#(\d+);/chr ($1)/ge;
        $e =~ s/[()（）\s]//g;
#        print "$e\n";
        $row[$col] = $e;
        $col++;
    }
}
close $i or die $!;

for my $row (@values) {
    for my $i (0..4) {
        my $kana = $row->[$i];
        if ($kana) {
            my $first = $row->[$i + 5];
            my $rest = $row->[$i + 10];
            $first2hangul{$kana} = $first;
            $rest2hangul{$kana} = $first;
        }
    }
}

my @files = qw/first2hangul rest2hangul/;
my @lists = (\%first2hangul, \%rest2hangul);
for my $i (0, 1) {
    my $a = $lists[$i];
    my $o;
    open $o, ">:utf8", "$files[$i].txt" or die $!;
    for my $k (sort keys %$a) {
        if ($a->{$k}) {
            print $o "$k $a->{$k}\n";
        }
    }
    close $o;
}
