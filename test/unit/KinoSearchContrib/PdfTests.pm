# Test for PDF.pm
package PdfTests;
use base qw( FoswikiFnTestCase );

use strict;

use Foswiki::Func;
use Foswiki::Contrib::KinoSearchContrib::StringifyBase;
use Foswiki::Contrib::KinoSearchContrib::Stringifier;

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
    
    $this->{attachmentDir} = 'attachement_examples/';
    if (! -e $this->{attachmentDir}) {
        #running from foswiki/test/unit
        $this->{attachmentDir} = 'KinoSearchContrib/attachement_examples/';
    }
}

sub tear_down {
    my $this = shift;
    $this->SUPER::tear_down();
}

sub test_stringForFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::PDF->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.pdf');
    my $text2 = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($this->{attachmentDir}.'Simple_example.pdf');

    $this->assert(defined($text), "No text returned.");
    $this->assert_str_equals($text, $text2, "PDF stringifier not well registered.");

    my $ok = $text =~ /Adobe/;
    $this->assert($ok, "Text Adobe not included");

    $ok = $text =~ /Äußerung/;
    $this->assert($ok, "Text Äußerung not included");
}

sub test_SpecialCharacters {
    # check that special characters are not destroyed by the stringifier
    
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::PDF->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.pdf');

    $this->assert_matches('Überflieger', $text, "Text Überflieger not found.");
}

# test what would happen if someone uploaded a png and called it a .pdf
sub test_maliciousFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::PDF->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Im_a_png.pdf');

    $this->assert_equals('', $text, "Malicious file generated some text?");
}

1;
