# Test for DOCX.pm
package DocxTests;
use base qw( FoswikiFnTestCase );

use strict;

use Foswiki::Func;
use Foswiki::Contrib::KinoSearchContrib::StringifyBase;
use Foswiki::Contrib::KinoSearchContrib::Stringifier;

sub set_up {
    my $this = shift;
    
    $this->{attachmentDir} = 'attachment_examples/';
    if (! -e $this->{attachmentDir}) {
        #running from foswiki/test/unit
        $this->{attachmentDir} = 'KinoSearchContrib/attachment_examples/';
    }

    $this->SUPER::set_up();
}

sub tear_down {
    my $this = shift;
    $this->SUPER::tear_down();
}

sub test_stringForFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOCX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.docx');
    my $text2 = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($this->{attachmentDir}.'Simple_example.docx');
    
    $this->assert(defined($text) && $text ne "", "No text returned.");
    $this->assert_str_equals($text, $text2, "DOCX stringifier not well registered.");

    my $ok = $text =~ /dummy/;
    $this->assert($ok, "Text dummy not included")
}

sub test_SpecialCharacters {
    # check that special characters are not destroyed by the stringifier
    
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOCX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.docx');

    $this->assert_matches('Größer', $text, "Text Größer not found.");
}

# test for Passworded_example.docx
# Note that the password for that file is: foswiki
sub test_passwordedFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOCX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Passworded_example.docx');

    $this->assert_equals('', $text, "Protected file generated some text?");
}

# test what would happen if someone uploaded a png and called it a .docx
sub test_maliciousFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOCX->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Im_a_png.docx');

    $this->assert_equals('', $text, "Malicious file generated some text?");
}

1;