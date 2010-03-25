# Test for HTML.pm
package HtmlTests;
use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

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
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::HTML->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.html');
    my $text2 = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($this->{attachmentDir}.'Simple_example.html');

    $this->assert(defined($text), "No text returned.");
    $this->assert_str_equals($text, $text2, "HTML stringifier not well registered.");

    my $ok = $text =~ /Cern/;
    $this->assert($ok, "Text Cern not included");

    $ok = $text =~ /geöffnet/;
    $this->assert($ok, "Text geöffnet not included");
}

sub test_SpecialCharacters {
    # check that special characters are not destroyed by the stringifier
    
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::HTML->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.html');

    $this->assert_matches('geöffnet', $text, "Text geöffnet not found.");
}

# test what would happen if someone uploaded a png and called it a .html
sub test_maliciousFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::HTML->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Im_a_png.html');

    $this->assert_equals('', $text, "Malicious file generated some text?");
}

1;
