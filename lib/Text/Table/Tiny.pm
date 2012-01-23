use strict;
use warnings;
package Text::Table::Tiny;

our $COLUMN_SEPARATOR = '|';
our $ROW_SEPARATOR = '-';
our $CORNER_MARKER = '+';
our $HEADER_ROW_SEPARATOR = '=';
our $HEADER_CORNER_MARKER = 'O';

sub table {

    my %params = @_;

    my $rows = $params{rows} or die "Must provide rows!";

    # foreach col, get the maxlength
    my $widths = _maxlengths($rows);

    # use that to get the field format
    my $format = _get_format($widths);

    # get the length of the resulting string
    my $row_sep = _get_row_separator($widths);
    my $head_row_sep = _get_header_row_separator($widths);

    # here we go...
    my @table;
    push @table, $row_sep;

    if ( $params{header_row} ) {
        my $header_row = shift @$rows;
        push @table, sprintf($format,@$header_row);
        push @table, $params{separate_rows} ? $head_row_sep : $row_sep;
    }

    foreach my $row (@$rows) {
        push @table, sprintf($format,map { $_ || '' } @$row);
        push @table, $row_sep if $params{separate_rows};
    }
    # this will have already done the bottom if called explicitly
    push @table, $row_sep unless $params{separate_rows};
    return join("\n",grep {$_} @table);
}

sub _get_cols_and_rows ($) {
    my $rows = shift;
    return (_maxnum( map { scalar @$_ } @$rows), scalar @$rows);
}

sub _maxnum {
    my @list = @_;
    my $max = 0;
    do{$max = $_ if $_ > $max} foreach (@list);
    return $max;
}

sub _maxlengths {
    my $rows = shift;
    # what's the longest array in this list of arrays?
    my $max_index = _maxnum(map { $#$_ } @$rows);
    my $widths = [];
    for my $i (0..$max_index) {
        my $max = 0;
        # go through the $i-th element of each array, find the longest
        do{$max = $_ if $_ > $max} foreach (map {defined $$_[$i] ? length($$_[$i]) : 0} @$rows);
        push @$widths, $max;
    }
    return $widths;
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

#ABSTRACT: makes simple text tables

=head1 NAME

  Text::Table::Tiny

=head1 SYNOPSIS

    use Text::Table::Tiny;
    my $rows   = [
                  ['Name', 'Rank', 'Serial'];
                  ['alice', 'pvt', '123456'],
                  ['bob',   'cpl', '98765321'],
                  ['carol', 'brig gen', '8745']
                 ];
    # separate rows puts lines between rows, header_row says that the first row is headers
    print Text::Table::Tiny::table(rows => $rows, separate_rows => 1, header_row => 1);

=head1 DESCRIPTION

    Text::Table::Tiny provides a simple static method for building text tables for terminal scripts that require tablular rows.

=head1 METHODS

=item table

    my $table = Text::Table::Tiny::table( rows => $arrayref_of_arrayrefs );

  creates a text table from an arrayref of arrayrefs.

  options:
  - header_row:    tells table() that the first row in $rows is a header row
  - separate_rows: puts a separator line between rows, makes the header separator
                   line um... special.

  So, the above example, called as:

    Text::Table::Tiny::table(rows => $rows);

  would return:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

  called with header_row:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    +-------+----------+----------+
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

  called with header_row and separate_rows would return:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    O=======O==========O==========O
    | alice | pvt      | 123456   |
    +-------+----------+----------+
    | bob   | cpl      | 98765321 |
    +-------+----------+----------+
    | carol | brig gen | 8745     |
    +-------+----------+----------+

=head1 CLASS VARS

  If you want to change the characters used for making the lines and separators, these are the class vars to use:

    $Text::Table::Tiny::COLUMN_SEPARATOR = '|';
    $Text::Table::Tiny::ROW_SEPARATOR = '-';
    $Text::Table::Tiny::CORNER_MARKER = '+';
    $Text::Table::Tiny::HEADER_ROW_SEPARATOR = '=';
    $Text::Table::Tiny::HEADER_CORNER_MARKER = 'O';

=cut

