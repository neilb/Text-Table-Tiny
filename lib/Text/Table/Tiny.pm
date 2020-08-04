package Text::Table::Tiny;

use 5.010;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use Carp         qw/ croak /;
use Ref::Util    qw/ is_arrayref is_ref /;
our @EXPORT_OK = qw/ generate_table /;

# Legacy package globals, that can be used to customise the look.
# These are only used in the "classic" style.
# I wish I could drop them, but I don't want to break anyone's code.
our $COLUMN_SEPARATOR     = '|';
our $ROW_SEPARATOR        = '-';
our $CORNER_MARKER        = '+';
our $HEADER_ROW_SEPARATOR = '=';
our $HEADER_CORNER_MARKER = 'O';

my %charsets = (
    classic => { TLC => '+', TT => '+', TRC => '+', HR => '-', VR => '|', FHR => '=', LT => '+', RT => '+', FLT => 'O', FRT => 'O', HC => '+', FHC => 'O', BLC => '+', BT => '+', BRC => '+' },
    boxrule => { TLC => '┌', TT => '┬', TRC => '┐', HR => '─', VR => '│', FHR => '═', LT => '├', RT => '┤', FLT => '╞', FRT => '╡', HC => '┼', FHC => '╪', BLC => '└', BT => '┴', BRC => '┘' },
    norule  => { TLC => ' ', TT => ' ', TRC => ' ', HR => ' ', VR => ' ', FHR => ' ', LT => ' ', RT => ' ', FLT => ' ', FRT => ' ', HC => ' ', FHC => ' ', BLC => ' ', BT => ' ', BRC => ' ' },
);

sub generate_table
{
    my %param   = @_;
    my $rows    = $param{rows} or croak "you must pass the 'rows' argument!";
    my @rows    = @$rows;
    my @widths  = _calculate_widths($rows);
    $param{style} //= 'classic';
    my $style   = $param{style};
    croak "unknown style '$style'" if not exists($charsets{ $style });
    my $char    = $charsets{$style};

    if ($style eq 'classic') {
        $char->{TLC} = $char->{TRC} = $char->{TT} = $char->{LT} = $char->{RT} = $char->{HC} = $char->{BLC} = $char->{BT} = $char->{BRC} = $CORNER_MARKER;
        $char->{HR} = $ROW_SEPARATOR;
        $char->{VR} = $COLUMN_SEPARATOR;
        $char->{FLT} = $char->{FRT} = $char->{FHC} = $HEADER_CORNER_MARKER;
        $char->{FHR} = $HEADER_ROW_SEPARATOR;
    }

    my $header;
    my @align;
    if (defined $param{align}) {
        @align = is_arrayref($param{align})
               ? @{ $param{align} }
               : ($param{align}) x int(@widths)
               ;
    }
    else {
        @align = ('l') x int(@widths);
    }

    $header = shift @rows if $param{header_row};

    my $table = _top_border(\%param, \@widths, $char)
                ._header_row(\%param, $header, \@widths, \@align, $char)
                ._header_rule(\%param, \@widths, $char)
                ._body(\%param, \@rows, \@widths, \@align, $char)
                ._bottom_border(\%param, \@widths, $char);
    chop($table);

    return $table;
}

sub _top_border
{
    my ($param, $widths, $char) = @_;

    return '' if $param->{top_and_tail};
    return _rule_row($param, $widths, $char->{TLC}, $char->{HR}, $char->{TT}, $char->{TRC});

    return '' if $param->{top_and_tail};
    my $pad = $param->{compact} ? '' : $char->{HR};

    return $char->{TLC}
           .join($char->{TT}, map { $pad.($char->{HR} x $_).$pad } @$widths)
           .$char->{TRC}
           ."\n"
           ;
}

sub _bottom_border
{
    my ($param, $widths, $char) = @_;

    return '' if $param->{top_and_tail};
    return _rule_row($param, $widths, $char->{BLC}, $char->{HR}, $char->{BT}, $char->{BRC});
}

sub _rule_row
{
    my ($param, $widths, $le, $hr, $cross, $re) = @_;
    my $pad = $param->{compact} ? '' : $hr;

    return $le
           .join($cross, map { $pad.($hr x $_).$pad } @$widths)
           .$re
           ."\n"
           ;
}

sub _header_row
{
    my ($param, $row, $widths, $align, $char) = @_;
    return '' unless $param->{header_row};

    return _text_row($param, $row, $widths, $align, $char);
}

sub _header_rule
{
    my ($param, $widths, $char) = @_;
    return '' unless $param->{header_row};
    my $fancy = $param->{separate_rows} ? 'F' : '';

    return _rule_row($param, $widths, $char->{"${fancy}LT"}, $char->{"${fancy}HR"}, $char->{"${fancy}HC"}, $char->{"${fancy}RT"});
}

sub _body
{
    my ($param, $rows, $widths, $align, $char) = @_;
    my $divider = $param->{separate_rows} ? _rule_row($param, $widths, $char->{LT}, $char->{HR}, $char->{HC}, $char->{RT}) : '';

    return join($divider, map { _text_row($param, $_, $widths, $align, $char) } @$rows);
}

sub _text_row
{
    my ($param, $row, $widths, $align, $char) = @_;
    my @columns = @$row;
    my $text = $char->{VR};

    for (my $i = 0; $i < @$widths; $i++) {
        $text .= _format_column($columns[$i] // '', $widths->[$i], $align->[$i] // 'l', $param, $char);
        $text .= $char->{VR};
    }
    $text .= "\n";

    return $text;
}

sub _format_column
{
    my ($text, $width, $align, $param, $char) = @_;
    my $pad = $param->{compact} ? '' : ' ';

    if ($align eq 'r' || $align eq 'right') {
        return $pad.' ' x ($width - length($text)).$text.$pad;
    }
    elsif ($align eq 'c' || $align eq 'center' || $align eq 'centre') {
        my $total_spaces = $width - length($text);
        my $left_spaces  = int($total_spaces / 2);
        my $right_spaces = $left_spaces;
        $right_spaces++ if $total_spaces % 2 == 1;
        return $pad.(' ' x $left_spaces).$text.(' ' x $right_spaces).$pad;
    }
    else {
        return $pad.$text.' ' x ($width - length($text)).$pad;
    }
}

sub _calculate_widths
{
    my $rows = shift;
    my @widths;
    foreach my $row (@$rows) {
        my @columns = @$row;
        for (my $i = 0; $i < @columns; $i++) {
            next unless defined($columns[$i]);
            $widths[$i] = length($columns[$i]) if !defined($widths[$i])
                                              || length($columns[$i]) > $widths[$i];
        }
    }
    return @widths;
}

# Back-compat: 'table' is an alias for 'generate_table', but isn't exported
*table = \&generate_table;

1;

__END__

=pod

=head1 NAME

Text::Table::Tiny - generate simple text tables from 2D arrays

=head1 SYNOPSIS

    use Text::Table::Tiny 0.04 qw/ generate_table /;

    my $rows = [
        ['Name',  'Rank',     'Serial'],    # header row
        ['alice', 'pvt',      '123456'],    # body rows
        ['bob',   'cpl',      '98765321'],
        ['carol', 'brig gen', '8745'],
    ];
    print generate_table(rows => $rows, header_row => 1);


=head1 DESCRIPTION

This module provides a single function, C<generate_table>, which formats
a two-dimensional array of data as a text table.
There are a number of options for adjusting the output format,
but the intention is that the default option is good enough for most uses.

The example shown in the SYNOPSIS generates the following table:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    +-------+----------+----------+
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

B<NOTE>: the interface changed with version 0.04, so if you
use the C<generate_table()> function illustrated above,
then you need to require at least version 0.04 of this module,
as shown in the SYNOPSIS.


=head2 generate_table()

The C<generate_table> function understands a number of arguments,
which are passed as a hash.
The only required argument is B<rows>.

=over 4


=item *

rows

Takes an array reference which should contain one or more rows
of data, where each row is an array reference.


=item *

header_row

If given a true value, the first row in the data will be interpreted
as a header row, and separated from the rest of the table with a ruled line.


=item *

separate_rows

If given a true value, a separator line will be drawn between every row in
the table,
and a thicker line will be used for the header separator.

=item *

top_and_tail

If given a true value, then the top and bottom border lines will be skipped.
This reduces the vertical height of the generated table.

=item *

align

This takes an array ref with one entry per column,
to specify the alignment of that column.
Legal values are 'l', 'c', and 'r'.
You can also specify a single alignment for all columns.

=item *

style

Specifies the format of the output table.
The default is C<'classic'>,
but other options are C<'boxrule'> and C<'norule'>.

=item *

compact

If set to a true value then we omit the single space padding on either
side of every column.

=back


=head2 EXAMPLES

If you just pass the data and no other options:

 generate_table(rows => $rows);

You get minimal ruling:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    | alice | pvt      | 123456   |
    | bob   | cpl      | 98765321 |
    | carol | brig gen | 8745     |
    +-------+----------+----------+

If you want lines between every row, and also want a separate header:

 generate_table(rows => $rows, header_row => 1, separate_rows => 1);

You get the maximally ornate:

    +-------+----------+----------+
    | Name  | Rank     | Serial   |
    O=======O==========O==========O
    | alice | pvt      | 123456   |
    +-------+----------+----------+
    | bob   | cpl      | 98765321 |
    +-------+----------+----------+
    | carol | brig gen | 8745     |
    +-------+----------+----------+


=head1 SEE ALSO

My L<blog post|http://neilb.org/2019/08/06/text-table-tiny-changes.html>
where I described changes to formatting;
this has more examples.

There are many modules for formatting text tables on CPAN.
A good number of them are listed in the
L<See Also|https://metacpan.org/pod/Text::Table::Manifold#See-Also>
section of the documentation for L<Text::Table::Manifold>.


=head1 REPOSITORY

L<https://github.com/neilb/Text-Table-Tiny>


=head1 AUTHOR

Neil Bowers <neilb@cpan.org>

The original version was written by Creighton Higgins <chiggins@chiggins.com>,
but the module was entirely rewritten for 0.05_01.


=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Neil Bowers.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

