use strict;
use warnings;
package Text::Table::Tiny;
use List::Util qw();

# ABSTRACT: makes simple tables from two-dimensional arrays, with limited templating options


our $COLUMN_SEPARATOR = '|';
our $ROW_SEPARATOR = '-';
our $CORNER_MARKER = '+';
our $HEADER_ROW_SEPARATOR = '=';
our $HEADER_CORNER_MARKER = 'O';

sub table {

    my %params = @_;
    my $rows = $params{rows} or die "Must provide rows!";

    # foreach col, get the biggest width
    my $widths = _maxwidths($rows);
    my $max_index = _max_array_index($rows);

    # use that to get the field format and separators
    my $format = _get_format($widths);
    my $row_sep = _get_row_separator($widths);
    my $head_row_sep = _get_header_row_separator($widths);

    # here we go...
    my @table;
    push @table, $row_sep;

    # if the first row's a header:
    my $data_begins = 0;
    if ( $params{header_row} ) {
        my $header_row = $rows->[0];
	$data_begins++;
        push @table, sprintf(
	    $format, 
	    map { defined($header_row->[$_]) ? $header_row->[$_] : '' } (0..$max_index)
	);
        push @table, $params{separate_rows} ? $head_row_sep : $row_sep;
    }

    # then the data
    foreach my $row ( @{ $rows }[$data_begins..$#$rows] ) {
        push @table, sprintf(
	    $format, 
	    map { defined($row->[$_]) ? $row->[$_] : '' } (0..$max_index)
	);
        push @table, $row_sep if $params{separate_rows};
    }

    # this will have already done the bottom if called explicitly
    push @table, $row_sep unless $params{separate_rows};
    return join("\n",grep {$_} @table);
}

sub _get_cols_and_rows ($) {
    my $rows = shift;
    return ( List::Util::max( map { scalar @$_ } @$rows), scalar @$rows);
}

sub _maxwidths {
    my $rows = shift;
    # what's the longest array in this list of arrays?
    my $max_index = _max_array_index($rows);
    my $widths = [];
    for my $i (0..$max_index) {
        # go through the $i-th element of each array, find the longest
        my $max = List::Util::max(map {defined $$_[$i] ? length($$_[$i]) : 0} @$rows);
        push @$widths, $max;
    }
    return $widths;
}

# return highest top-index from all rows in case they're different lengths
sub _max_array_index {
    my $rows = shift;
    return List::Util::max( map { $#$_ } @$rows );
}

sub _get_format {
    my $widths = shift;
    return "$COLUMN_SEPARATOR ".join(" $COLUMN_SEPARATOR ",map { "%-${_}s" } @$widths)." $COLUMN_SEPARATOR";
}

sub _get_row_separator {
    my $widths = shift;
    return "$CORNER_MARKER$ROW_SEPARATOR".join("$ROW_SEPARATOR$CORNER_MARKER$ROW_SEPARATOR",map { $ROW_SEPARATOR x $_ } @$widths)."$ROW_SEPARATOR$CORNER_MARKER";
}

sub _get_header_row_separator {
    my $widths = shift;
    return "$HEADER_CORNER_MARKER$HEADER_ROW_SEPARATOR".join("$HEADER_ROW_SEPARATOR$HEADER_CORNER_MARKER$HEADER_ROW_SEPARATOR",map { $HEADER_ROW_SEPARATOR x $_ } @$widths)."$HEADER_ROW_SEPARATOR$HEADER_CORNER_MARKER";
}

1;

__END__
=pod

=head1 NAME

Text::Table::Tiny - makes simple tables from two-dimensional arrays, with limited templating options

=head1 VERSION

version 0.03

=head1 OPTIONS

=over 4

=item *

header_row

true/false, designate first row in $rows as a header row and separate with a line

=item *

separate_rows

true/false put a separator line between rows and use a thicker line for header separator

=back

=head1 SYNOPSIS

    use Text::Table::Tiny;
    my $rows = [
        # header row
        ['Name', 'Rank', 'Serial'],
        # rows
        ['alice', 'pvt', '123456'],
        ['bob',   'cpl', '98765321'],
        ['carol', 'brig gen', '8745'],
    ];
    # separate rows puts lines between rows, header_row says that the first row is headers
    print Text::Table::Tiny::table(rows => $rows, separate_rows => 1, header_row => 1);

  Example in the synopsis: Text::Table::Tiny::table(rows => $rows);

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

  with header_row: Text::Table::Tiny::table(rows => $rows, header_row => 1);

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    +-------+----------+----------+
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

  with header_row and separate_rows: Text::Table::Tiny::table(rows => $rows, header_row => 1, separate_rows => 1);

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    O=======O==========O==========O
    | alice | pvt      | 123456   |
    +-------+----------+----------+
    | bob   | cpl      | 98765321 |
    +-------+----------+----------+
    | carol | brig gen | 8745     |
    +-------+----------+----------+

=head1 FORMAT VARIABLES

=over 4

=item *

$Text::Table::Tiny::COLUMN_SEPARATOR = '|';

=item *

$Text::Table::Tiny::ROW_SEPARATOR = '-';

=item *

$Text::Table::Tiny::CORNER_MARKER = '+';

=item *

$Text::Table::Tiny::HEADER_ROW_SEPARATOR = '=';

=item *

$Text::Table::Tiny::HEADER_CORNER_MARKER = 'O';

=back

=head1 AUTHOR

Creighton Higgins <chiggins@chiggins.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Creighton Higgins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

