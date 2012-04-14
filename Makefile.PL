use inc::Module::Install;

name ('Lingua-JA-Moji');
author ('Ben Bullock bkb@cpan.org');
abstract ('Handle many kinds of Japanese characters');
version_from ('lib/Lingua/JA/Moji.pm');
requires ('File::ShareDir');
requires ('Convert::Moji' => 0.03);
build_requires ('Test::More');
no_index (directory => 'build');
license ('perl');

my $repo = 'https://github.com/benkasminbullock/Lingua-JA-Moji';

resources (
    MailingList => 'http://groups.google.com/group/perl-moji',
    repository => $repo,
    bugtracker => "$repo/issues",
);
install_share ();
auto_install ();
WriteAll ();
