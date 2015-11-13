use strict;
use Test::More tests => 5;
use Text::Table::Tiny qw/ generate_table /;

my $rows = [
   [ 'Group', 'Member' ],
   [ 'Elvis', 'Priscilla' ],
   [ 'Elvis', 'Lisa Marie' ],
   [ 'Liquor', 'Beer' ],
   [ 'Liquor', 'Wine' ],
   [ 'Liquor', 'Brandy' ],
   [ 'Liquor', 'Rum' ],
   [ undef, "That's showbiz!" ],
];

my $t0 = generate_table( rows => $rows );
# print $t0, $/;
is($t0, q%+--------+-----------------+
| Group  | Member          |
| Elvis  | Priscilla       |
| Elvis  | Lisa Marie      |
| Liquor | Beer            |
| Liquor | Wine            |
| Liquor | Brandy          |
| Liquor | Rum             |
|        | That's showbiz! |
+--------+-----------------+%,
'just rows'
);

my $t1 = generate_table( rows => $rows, header_row => 1 );
# print $t1, $/;
is($t1, q%+--------+-----------------+
| Group  | Member          |
+--------+-----------------+
| Elvis  | Priscilla       |
| Elvis  | Lisa Marie      |
| Liquor | Beer            |
| Liquor | Wine            |
| Liquor | Brandy          |
| Liquor | Rum             |
|        | That's showbiz! |
+--------+-----------------+%,
'rows and header row'
);

my $t2 = generate_table( rows => $rows, header_row => 1, group_rows_by => [0] );
# print $t2, $/;
is($t2, q%+--------+-----------------+
| Group  | Member          |
O========O=================O
| Elvis  | Priscilla       |
| Elvis  | Lisa Marie      |
+--------+-----------------+
| Liquor | Beer            |
| Liquor | Wine            |
| Liquor | Brandy          |
| Liquor | Rum             |
+--------+-----------------+
|        | That's showbiz! |
+--------+-----------------+%,
'header row and rows grouped by first column'
);

my $t3 = generate_table( rows => $rows, header_row => 1, group_rows_by => [1] );
# print $t3, $/;
is($t3, q%+--------+-----------------+
| Group  | Member          |
O========O=================O
| Elvis  | Priscilla       |
+--------+-----------------+
| Elvis  | Lisa Marie      |
+--------+-----------------+
| Liquor | Beer            |
+--------+-----------------+
| Liquor | Wine            |
+--------+-----------------+
| Liquor | Brandy          |
+--------+-----------------+
| Liquor | Rum             |
+--------+-----------------+
|        | That's showbiz! |
+--------+-----------------+%,
'header row and rows grouped by non-first column'
);

my $t4 = generate_table( rows => $rows, header_row => 1, separate_rows => 1, group_rows_by => [0] );
# print $t4, $/;
is($t4, q%+--------+-----------------+
| Group  | Member          |
O========O=================O
| Elvis  | Priscilla       |
+--------+-----------------+
| Elvis  | Lisa Marie      |
O========O=================O
| Liquor | Beer            |
+--------+-----------------+
| Liquor | Wine            |
+--------+-----------------+
| Liquor | Brandy          |
+--------+-----------------+
| Liquor | Rum             |
O========O=================O
|        | That's showbiz! |
O========O=================O%,
'header row, rows grouped by first column, and separate rows'
);
