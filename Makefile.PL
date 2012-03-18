use inc::Module::Install;

name 'Lingua-JA-Moji',
author 'Ben Bullock bkb@cpan.org',
version_from 'lib/Lingua/JA/Moji.pm',
requires ('File::ShareDir');
requires ('Convert::Moji' => 0.03);
build_requires 'Test::More';
no_index directory => 'build';
license 'perl';
install_share;
auto_install;
resources (
    MailingList => 'http://groups.google.com/group/perl-moji'
);
WriteAll;
