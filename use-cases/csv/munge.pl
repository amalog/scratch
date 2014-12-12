use strict;
use warnings;
use autodie qw( :all );

use List::Util qw( max );
use Text::CSV_XS;

my $csv = Text::CSV_XS->new();
open my $fh, "<:encoding(utf8)", "secondary-notes.csv";
open my $out, ">", "secondary-munged.csv";

# set/generate column names
$csv->column_names( $csv->getline($fh) );
my @columns = qw(
  past_due_days
  age
  fico_delta
  fico
  diligent
  subgrade
  par_value
);
print $out join( ',', @columns ), "\n";

while ( my $row = $csv->getline_hr($fh) ) {

    # some fields can be copied across unchanged
    $row->{par_value} = $row->{'Principal + Interest'};

    # some fields require munging
    $row->{past_due_days} = past_due_days($row);
    $row->{fico}          = fico($row);
    $row->{fico_delta}    = fico_delta($row);
    $row->{subgrade}      = subgrade($row);
    $row->{age}           = age($row);
    $row->{diligent}      = diligent($row);

    print $out join( ',', @{$row}{@columns} ), "\n";
}
close $fh;

close $out;

sub past_due_days {
    my ($row) = @_;
    my $status = $row->{Status};
    return 0 if $status eq 'Issued';
    return 0 if $status eq 'Current';
    return 0 if $row->{DaysSinceLastPayment} eq 'null';
    return max( 0, $row->{DaysSinceLastPayment} - 30 );
}

sub fico {
    my ($row) = @_;
    my ( $low, $high ) = $row->{'FICO End Range'} =~ /^(\d+)-(\d*)$/;
    return 499 if $low eq '499' && $high eq '';
    return $high + 0;
}

sub fico_delta {
    my ($row) = @_;
    my $dir = $row->{CreditScoreTrend};
    return -1 if $dir eq 'DOWN';
    return 0  if $dir eq 'FLAT';
    return 1  if $dir eq 'UP';
    die "What kind of direction is ''$dir'?";
}

sub subgrade {
    my ($row) = @_;
    my $class = $row->{'Loan Class'};
    my ( $grade, $tier ) = $class =~ /^([A-G])([1-5])$/;
    die "Can't parse subgrade: $class" if not $grade;
    return ( ord($grade) - ord('A') ) * 5 + $tier;
}

sub age {
    my ($row) = @_;

    my $term               = $row->{'Loan Maturity'};
    my $remaining_payments = $row->{'Remaining Payments'};
    return ( $term - $remaining_payments ) / $term;
}

sub diligent {
    my ($row) = @_;
    return '' if $row->{age} == 0;

    my $is_current = $row->{past_due_days} == 0;
    my $was_late   = $row->{NeverLate} eq 'false';
    return 1 if $is_current && !$was_late;
    return 0 if $is_current && $was_late;
    return -1 if !$is_current;
    die "Unexpected diligence combination";
}
