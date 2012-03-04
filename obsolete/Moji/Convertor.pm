package Lingua::JA::Moji::Convertor;
use warnings;
use strict;

use File::ShareDir ':ALL';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/load_convertor make_convertors/;

sub print_error
{
    print STDERR __PACKAGE__,(caller(1))[3],": ",@_,"\n";
    return;
}


=head2 load_convertor

Load a specified convertor from the shared directory.

=cut

sub load_convertor
{
    my ($in, $out) = @_;
    my $filename = $in."2".$out.'.txt';
    my $file = dist_file ('Lingua-JA-Moji', $filename);
    if (! $file || ! -f $file) {
	print_error "Could not find distribution file '$filename'";
	return;
    }
    my $file_in;
    if (! open $file_in, "<:utf8", $file) {
	print_error "Could not open '$file' for reading: $!";
	return;
    }
    my %converter;
    while (<$file_in>) {
	chomp;
	my ($left, $right) = split /\s+/;
	$converter{$left} = $right;
    }
    close $file_in or die "Could not close '$file': $!";
    return \%converter;
}

sub length_one
{
    for (@_) {
	return if !/^.$/;
    }
    return 1;
}

sub make_regex
{
    my @inputs = @_;
    # Quote any special characters. We could also do this with join
    # '\E|\Q', but the regexes then become even longer.
    for (@inputs) { s/([\$\\\/*\.^()+*?{}])/\\$1/g }
    return join '|',sort { length($b) <=> length($a) } @inputs;
}

# mapping to/from keys and values is unambiguous both ways

sub unambiguous
{
    my ($table) = @_;
    my %inverted;
    for (keys %$table) {
#	print "$_ -> $$table{$_}\n";
	return if $inverted{$_};
	$inverted{$_} = 1;
    }
    %inverted = ();
    for (values %$table) {
#	print "$_\n";
	return if $inverted{$_};
	$inverted{$_} = 1;
    }
    return 1;
}

sub add_boilerplate
{
    my ($code, $name) = @_;
    $code =<<EOSUB;
sub convert_$name
{
    my (\$conv,\$input,\$convert_type) = \@_;
    $code
    return \$input;
}
EOSUB
$code .= "\\\&".__PACKAGE__."::convert_$name;";
#    print $code,"\n";
    return $code;
}

sub ambiguous_reverse
{
    my ($table) = @_;
    my %inverted;
    for (keys %$table) {
	my $val = $table->{$_};
#	print "Valu is $val\n";
	push @{$inverted{$val}}, $_;
#	print "key $_ stuff ",join (' ',@{$inverted{$val}}),"\n";
    }
    return \%inverted;
}

# Callback

sub split_match
{
    my ($conv, $input, $convert_type) = @_;
    $convert_type = "all" if (!$convert_type);
#    print "Convert type is '$convert_type'\n";
    my @input = split '', $input;
    my @output;
    for (@input) {
	my $in = $conv->{out2in}->{$_};
#	print "$_ $in\n";
	# No conversion defined.
	if (! $in) {
	    push @output, $_;
	    next;
	}
	# Unambigous case
	if (@{$in} == 1) {
	    push @output, $in->[0];
	    next;
	}
	if ($convert_type eq 'all') {
	    push @output, $in;
	} elsif ($convert_type eq 'first') {
	    push @output, $in->[0];
	} elsif ($convert_type eq 'random') {
	    my $pos = int rand @$in;
#	    print "RANDOM $pos\n";
	    push @output, $in->[$pos];
	}
    }
    return \@output;
}

sub make_convertors
{
    my $conv = {};
    my ($in, $out, $table) = @_;
    if (!$table) {
	$table = load_convertor ($in, $out);
    }
    $conv->{in2out} = $table;
    my @keys = keys %{$table};
    my @values = values %{$table};
    my $sub_in2out;
    my $sub_out2in;
    if (length_one(@keys)) {
	my $lhs = join '', @keys;

	# Improvement: one way tr/// for the ambiguous case lhs/rhs only.

	if (length_one(@values) && unambiguous($table)) {
#	    print "Not ambiguous\n";
	    # can use tr///;
	    my $rhs = join '', @values;
	    $sub_in2out = "\$input =~ tr/$lhs/$rhs/;";
	    $sub_out2in = "\$input =~ tr/$rhs/$lhs/;";
	} else {
	    $sub_in2out = "\$input =~ s/([$lhs])/\$conv->{in2out}->{\$1}/eg;";
	    my $rhs = make_regex (@values);
	    if (unambiguous($conv->{in2out})) {
		my %out2in_table = reverse %{$conv->{in2out}};
		$conv->{out2in} = \%out2in_table;
		$sub_out2in = "\$input =~ s/($rhs)/\$conv->{out2in}->{\$1}/eg;";
	    } else {
#		print "Unambiguous inversion is not possible with $in, $out.\n";
		$conv->{out2in} = ambiguous_reverse ($conv->{in2out});
		$sub_out2in = "\$input = \$conv->split_match (\$input, \$convert_type);";
	    }
	}
    } else {
	my $lhs = make_regex (@keys);
	$sub_in2out = "\$input =~ s/($lhs)/\$conv->{in2out}->{\$1}/eg;";
	my $rhs = make_regex (@values);
	if (unambiguous($conv->{in2out})) {
	    my %out2in_table = reverse %{$conv->{in2out}};
	    $conv->{out2in} = \%out2in_table;
	    $sub_out2in = "    \$input =~ s/($rhs)/\$conv->{out2in}->{\$1}/eg;";
	} else {
#	    print "Unambiguous inversion is not possible with $in, $out.\n";
	}
    }
    $sub_in2out = add_boilerplate ($sub_in2out, "${in}2$out");
    my $sub1 = eval $sub_in2out;
#    if ($@) {
#	print "Errors are ",$@,"\n";
#	print "\$sub1 = ",$sub_in2out,"\n";
#	print "\$sub1 = ",$sub1,"\n";
#    }
    $conv->{in2out_sub} = $sub1;
    if ($sub_out2in) {
	$sub_out2in = add_boilerplate ($sub_out2in, "${out}2$in");
#	print $sub_out2in,"\n\n";
	my $sub2 = eval $sub_out2in;
	if ($@) {
	    print "Errors are ",$@,"\n";
	    print "\$sub2 = ",$sub2,"\n";
	}
	$conv->{out2in_sub} = $sub2;
    }
    bless $conv;
    return $conv;
}

sub convert
{
    my ($conv, $input) = @_;
    return &{$conv->{in2out_sub}}($conv, $input);
}

sub invert
{
    my ($conv, $input, $convert_type) = @_;
    return &{$conv->{out2in_sub}}($conv, $input, $convert_type);
}

1;
