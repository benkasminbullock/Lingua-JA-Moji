use inc::Module::Install;

name 'Lingua-JA-Moji',
all_from 'lib/Lingua/JA/Moji.pm',
#author   'Ben Kasmin Bullock <benkasminbullock@gmail.com>';
requires('File::ShareDir');
requires('Convert::Moji');

build_requires 'Test::More';

install_share;
#install_script 'moji';
auto_install;
WriteAll;

