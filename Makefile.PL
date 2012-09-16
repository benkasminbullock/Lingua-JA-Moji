use strict;
use warnings;
use ExtUtils::MakeMaker;

my $repo = 'https://github.com/benkasminbullock/Lingua-JA-Moji';

WriteMakefile (
    NAME => 'Lingua-JA-Moji',
    AUTHOR => 'Ben Bullock bkb@cpan.org',
    ABSTRACT => 'Handle many kinds of Japanese characters',
    VERSION_FROM => 'lib/Lingua/JA/Moji.pm',
    PREREQ_PM => {
        'Convert::Moji' => '0.05',
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$repo/issues",
        },
        no_index => {
            directory => 'build',
        },
    },
    LICENSE => 'perl',
    MIN_PERL_VERSION => '5.008009',
);
