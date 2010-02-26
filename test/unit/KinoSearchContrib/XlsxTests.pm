# Test for XLSX.pm
package XlsxTests;
use base qw( FoswikiFnTestCase );

use strict;

use Foswiki::Contrib::KinoSearchContrib::StringifyBase;
use Foswiki::Contrib::KinoSearchContrib::Stringifier;

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
    $this->{attachmentDir} = 'attachment_examples/';
    if (! -e $this->{attachmentDir}) {
        #running from foswiki/test/unit
        $this->{attachmentDir} = 'KinoSearchContrib/attachment_examples/';
    }
}

sub tear_down {
    my $this = shift;
    $this->SUPER::tear_down();
}

sub test_stringForFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.xlsx');
    my $text2 = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($this->{attachmentDir}.'Simple_example.xlsx');

    $this->assert(defined($text), "No text returned.");
    $this->assert_str_equals($text, $text2, "XLSX stringifier not well registered.");

    my $ok = $text =~ /dummy/;
    $this->assert($ok, "Text dummy not included")
}

sub test_SpecialCharacters {
    # check that special characters are not destroyed by the stringifier

    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.xlsx');
    
    $this->assert($text =~ m\Gr��er\, "Text Gr��er not found.");
		  
    $text  = $stringifier->stringForFile($this->{attachmentDir}.'Portuguese_example.xlsx');
    
    $this->assert($text =~ m\Formata��o\, "Text Formata��o not found.");		  
    $this->assert(!($text =~ m\GENERAL\), "Bad string GENERAL appeares.");
}

sub test_Numbers {
    # I check, that numbers are found

    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.xlsx');

    $this->assert($text =~ m\200\,  "Number 200 not found.");
    $this->assert($text =~ m\0.23\, "Number 0,23 not found.");
    $this->assert($text =~ m\4711\, "Number 4711 not found.");
    $this->assert($text =~ m\312\,  "Number 312 Euro not found.");
}

sub test_calculatedNumbers {
    # I check, that calculated numbers are found

    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.xlsx');

    $this->assert(($text =~ m\217\)==1,  "Number 200 + 17 not found.");
    $this->assert(($text =~ m\5\)==1, "Number 5 not found.");
}

# test for Passworded_example.xlsx
# Note that the password for that file is: foswiki
sub test_passwordedFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Passworded_example.xlsx');
    
    $this->assert_equals('', $text, "Protected file generated some text?");
}

# test what would happen if someone uploaded a png and called it a .xlsx
sub test_maliciousFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::XLSX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Im_a_png.xlsx');

    $this->assert_equals('', $text, "Malicious file generated some text?");
}

1;