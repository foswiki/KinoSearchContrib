# Test for DOC_wv.pm
package Doc_wvTests;
use base qw( FoswikiFnTestCase );

use strict;

use Foswiki::Contrib::KinoSearchContrib::StringifyBase;
use Foswiki::Contrib::KinoSearchContrib::Stringifier;

sub set_up {
        my $this = shift;

    $this->{attachmentDir} = 'attachement_examples/';
    if (! -e $this->{attachmentDir}) {
        #running from foswiki/test/unit
        $this->{attachmentDir} = 'KinoSearchContrib/attachement_examples/';
    }

    $this->SUPER::set_up();
    # Use RcsLite so we can manually gen topic revs
    $Foswiki::cfg{StoreImpl} = 'RcsLite';
    $Foswiki::cfg{KinoSearchContrib}{WordIndexer} = 'wvHtml';

    $this->registerUser("TestUser", "User", "TestUser", 'testuser@an-address.net');

#    $this->{session}->{store}->saveTopic($this->{session}->{user},$this->{users_web}, "TopicWithWordAttachment", <<'HERE');
#Just an example topic wird MS Word
#Keyword: redmond
#HERE
#    $this->{session}->{store}->saveAttachment($this->{users_web}, "TopicWithWordAttachment", "Simple_example.doc",
#                                            $this->{session}->{user}, {file => "attachement_examples/Simple_example.doc"})
}

sub tear_down {
    my $this = shift;
    $this->SUPER::tear_down();
}

sub test_stringForFile {
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOC_wv->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.doc');
    #my $text2 = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($this->{attachmentDir}.'Simple_example.doc');

    #print "Test : $text\n";
    #print "Test2: $text2\n";

    $this->assert(defined($text), "No text returned.");
    #$this->assert_str_equals($text, $text2, "DOC_wv stringifier not well registered.");

    my $ok = $text =~ /dummy/;
    $this->assert($ok, "Text dummy not included")
}

sub test_SpecialCharacters {
    # check that special characters are not destroyed by the stringifier
    
    my $this = shift;
    my $stringifier = Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOC_antiword->new();

    my $text  = $stringifier->stringForFile($this->{attachmentDir}.'Simple_example.doc');

    $this->assert(($text =~ m\Größer\)==1, "Text Größer not found.");
}

1;
