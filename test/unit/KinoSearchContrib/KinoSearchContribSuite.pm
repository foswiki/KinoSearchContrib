package KinoSearchContribSuite;
use Unit::TestSuite;
our @ISA = qw( Unit::TestSuite );

sub include_tests {
    qw( KinoSearchTests IndexTests SearchTests );
}

1;
