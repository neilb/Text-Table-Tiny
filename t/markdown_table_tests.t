use strict;
use Test::More;# tests => 5;
use lib qw(t/lib);

use Text::Table::Tiny qw/ generate_markdown_table /;

my $rows = [
   [ 'Elvis', 'Priscilla' ],
   [ 'Liquor', 'Beer', 'Wine' ],
   [ undef, undef, undef, "That's showbiz!" ],
];

my $t3 =
  generate_markdown_table( rows => $rows );
is($t3,q%| Elvis  | Priscilla |      |                 |
|--------|-----------|------|-----------------|
| Liquor | Beer      | Wine |                 |
|        |           |      | That's showbiz! |%,
'markdown');

done_testing();