use warnings;
use strict;
use Test::More;
use Lingua::JA::Moji 'is_romaji';

my @tests = (
{
    word => 'Maractite',
    is => undef,
},
);

my @bugs = (
);

run (@tests);
TODO: {
    local $TODO = 'bugs';
    run (@bugs);
}
done_testing ();
exit;

sub run
{
    my (@list) = @_;
    for my $test (@list) {
        my $message = '';
        is (is_romaji ($test->{word}), $test->{is}, $message);
    }
}

