# Test for Search.pm
package SearchTests;
use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use strict;

use Foswiki::Func;
use Foswiki::Contrib::KinoSearchContrib::Search;
use Foswiki::Contrib::KinoSearchContrib::Index;

sub new {
    my $self = shift()->SUPER::new( 'Search', @_ );

    # try and guess where our test attachments are
    $self->{attachmentDir} =
"$Foswiki::cfg{WorkingDir}/../../KinoSearchContrib/test/unit/KinoSearchContrib/attachment_examples/";
    if ( !-e $self->{attachmentDir} ) {
        die
"Can't find attachment_examples directory (tried $self->{attachmentDir})";
    }

    return $self;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();

    # Use RcsLite so we can manually gen topic revs
    $Foswiki::cfg{StoreImpl} = 'RcsLite';

    $Foswiki::cfg{KinoSearchContrib}{Debug} = 1;

    # ensure we use the tests working dir
    $Foswiki::cfg{KinoSearchContrib}{LogDirectory}   = undef;
    $Foswiki::cfg{KinoSearchContrib}{IndexDirectory} = undef;

# don't bother indexing everything, we only want the temporary webs. Makes the tests a lot quicker
    $Foswiki::cfg{KinoSearchContrib}{SkipWebs} =
      'Trash, Sandbox, System, TWiki, Main, TestCases';

    $this->registerUser( "TestUser", "User", "TestUser",
        'testuser@an-address.net' );
    $this->assert( defined $this->{test_web}, "no {test_web}" );
    Foswiki::Func::saveTopicText( $this->{test_web}, 'TopicWithoutAttachment',
        <<'HERE');
Just an example topic
Keyword: startpoint
HERE
    Foswiki::Func::saveTopicText( $this->{test_web}, 'TopicWithWordAttachment',
        <<'HERE');
Just an example topic wird MS Word
Keyword: redmond
HERE
    Foswiki::Func::saveAttachment( $this->{test_web}, "TopicWithWordAttachment",
        "Simple_example.doc",
        { file => $this->{attachmentDir} . "Simple_example.doc" } );

    Foswiki::Func::saveTopicText( $this->{test_web}, 'WebPreferences',
        <<'HERE');
   * Set WEBFORMS = BasicForm
HERE

    Foswiki::Func::saveTopicText( $this->{test_web}, 'BasicForm', <<'HERE');
| *Name:* | *Type:* | *Size:* | *Values:* | *Tooltip message:* |
| TopicClassification | select | 1 | | Classify a topic |
| TopicSummary | text |  80 | | Classify a topic |
| InterestedParties | text |  80 | |  Use for tracking and show key interested people |	
HERE

    Foswiki::Func::saveTopicText( $this->{test_web}, 'TopicWithForm', <<'HERE');
example topic woith a form
keyword: structure

%META:FORM{name="BasicForm"}%
%META:FIELD{name="TopicClassification" attributes="" title="TopicClassification" value="DeveloperDocumentation"}%
%META:FIELD{name="TopicSummary" attributes="" title="TopicSummary" value="How to run the unit test suite"}%
%META:FIELD{name="InterestedParties" attributes="" title="InterestedParties" value=""}%
HERE
}

sub tear_down {
    my $this = shift;
    $this->SUPER::tear_down();
}

sub test_newSearch {
    my $this   = shift;
    my $search = Foswiki::Contrib::KinoSearchContrib::Search->newSearch();

    $this->assert( defined($search), "Search example not created." );
}

sub test_docsForQuery {
    my $this   = shift;
    my $search = Foswiki::Contrib::KinoSearchContrib::Search->newSearch();

    # Create an index of the current situation.
    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    # Now I search for something that does not exist.
    my $docs = $search->docsForQuery("ThisDoesNotExist");
    my $hit  = $docs->fetch_hit_hashref;
    $this->assert( !defined($hit), "Bad hit found." );

    # Let's create something
    Foswiki::Func::saveTopicText( $this->{test_web}, "TopicTitleToSearch",
        <<'HERE');
Just an example topic
Keyword: BodyToSearchFor
HERE

    # Create an index of the current situation.
    $ind->createIndex();

    # Now I search for the title
    $docs = $search->docsForQuery("TopicTitleToSearch");
    $hit  = $docs->fetch_hit_hashref;
    $this->assert( defined($hit), "Hit for title not found." );
    my $topic = $hit->{topic};
    $topic =~ s/ .*//;
    $this->assert_str_equals( $topic, "TopicTitleToSearch",
        "Wrong topic for tile." );

    $docs = $search->docsForQuery("BodyToSearchFor");
    $hit  = $docs->fetch_hit_hashref;
    $this->assert( defined($hit), "Hit for body not found." );
    $topic = $hit->{topic};
    $topic =~ s/ .*//;
    $this->assert_str_equals( $topic, "TopicTitleToSearch",
        "Wrong topic for body." );
}

sub test_renderHtmlStringFor {
    my $this   = shift;
    my $search = Foswiki::Contrib::KinoSearchContrib::Search->newSearch();

    # Let's create something
    Foswiki::Func::saveTopicText( $this->{test_web}, "TopicTitleToSearch",
        <<'HERE');
Just an example topic
Keyword: BodyToSearchFor
HERE

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    # Now I search for the title
    my $docs = $search->docsForQuery("TopicTitleToSearch");
    my $hit  = $docs->fetch_hit_hashref;

    # load the template
    my $tmpl = Foswiki::Func::readTemplate("kinosearch");
    $tmpl =~ s/\%META{.*?}\%//go;    # remove %META{"parent"}%;
                                     # split the template into sections
    my ( $tmplHead, $tmplSearch, $tmplTable, $tmplNumber, $tmplTail ) =
      split( /%SPLIT%/, $tmpl );

    # prepare for the result list
    my ( $beforeText, $repeatText, $afterText ) =
      split( /%REPEAT%/, $tmplTable );

    my $nosummary = "";
    my $htmlString =
      $search->renderHtmlStringFor( $hit, $repeatText, $nosummary );

    $this->assert( index( $htmlString, $hit->{web} ), "Web not in result" );
    my $restopic = $hit->{topic};

    # For partial name search of topics, just hold the first part of the string
    if ( $restopic =~ m/(\w+)/ ) { $restopic =~ s/ .*//; }
    $this->assert( index( $htmlString, $restopic ), "Topic not in result" );

}

sub test_search {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "startpoint" );

    $this->assert_matches( "TopicWithoutAttachment", $result,
        "TopicWithoutAttachment not found" );
}

sub test_text_search {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result = $this->_search(
        $this->{test_web},           "text:Kino",
        $this->{test_user_wikiname}, "startpoint"
    );

    $this->assert_matches( "TopicWithoutAttachment", $result,
        "TopicWithoutAttachment not found" );
}

sub test_web_search {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result = $this->_search(
        $this->{test_web},
        "web:$this->{test_web} Kino",
        $this->{test_user_wikiname}, "startpoint"
    );

    $this->assert_matches( "TopicWithoutAttachment", $result,
        "TopicWithoutAttachment not found" );
}

sub test_searchAttachments {
    my $this   = shift;
    my $search = Foswiki::Contrib::KinoSearchContrib::Search->newSearch();

    # Let's create something
    Foswiki::Func::saveTopicText( $this->{test_web}, "TopicToSearch", <<'HERE');
Just an example topic
Keyword: BodyToSearchFor
HERE

    Foswiki::Func::saveAttachment( $this->{test_web}, "TopicToSearch",
        "Simple_example.txt",
        { file => $this->{attachmentDir} . "Simple_example.txt" } );

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    my $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "type:txt" );

    $this->assert_matches( "TopicToSearch", $result,
        "TopicToSearch not found for type:txt" );

    $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "name:Simple_example.txt" );

    $this->assert_matches( "TopicToSearch", $result,
        "TopicToSearch not found for name:Simple_example.txt" );
}

# form:BasicForm
sub test_search_form {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "form:BasicForm" );

    $this->assert_matches( "TopicWithForm", $result,
        "TopicWithForm not found" );
}

# form_name:BasicForm
# form_name: was what the old code specified, but the docs always said it should have been form:
# we support both
sub test_search_form_name {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "form_name:BasicForm" );

    $this->assert_matches( "TopicWithForm", $result,
        "TopicWithForm not found" );
}

# test the current form_field functionality
sub test_search_form_field {
    my $this = shift;
    my $result;

# oddly, this seems to make the test pass, as the WEBFORMS preference gets picked up
    $this->registerUser( "TestUser2", "User", "TestUser2",
        'testuser@an-address.net' );

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result = $this->_search(
        $this->{test_web}, "Kino",
        $this->{test_user_wikiname},
        "TopicClassification:DeveloperDocumentation"
    );

    $this->assert_matches( "TopicWithForm", $result,
        "TopicWithForm not found" );
}

# full text search should return values from a form field
# currently fails - see Item5581. Classed as an enhancement.
sub test_search_text_form_field {
    my $this = shift;
    my $result;

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    $result = $this->_search(
        $this->{test_web}, "Kino",
        $this->{test_user_wikiname},
        "unit test suite"
    );

    $this->expect_failure();
    $this->assert_matches( "TopicWithForm", $result,
        "TopicWithForm not found" );
}

# I check, if the access rights of the users are checked.
sub test_search_with_users {
    my $this = shift;
    my $result;

    # I add another user
    $this->registerUser( "TestUser2", "User", "TestUser2",
        'testuser@an-address.net' );

    # Now I create a topic that only "TestUser2" can read
    Foswiki::Func::saveTopicText( $this->{test_web}, "TopicWithAccesControl",
        << 'HERE');
Just an example topic
Keyword: KeepOutHere
   * Set ALLOWTOPICVIEW = TestUser2
HERE

    my $ind = Foswiki::Contrib::KinoSearchContrib::Index->newCreateIndex();
    $ind->createIndex();

    # Let's see if TestUser2 can find his topic
    $result =
      $this->_search( $this->{test_web}, "Kino", "TestUser2", "KeepOutHere" );
    $this->assert_matches( "TopicWithAccesControl", $result,
        "TopicWithAccesControl not found" );

    # No the reverse test: The normal test uses should not find the toipic
    $result =
      $this->_search( $this->{test_web}, "Kino", $this->{test_user_wikiname},
        "KeepOutHere" );

    $this->assert_does_not_match( "TopicWithAccesControl", $result,
        "TopicWithAccesControl found, and it shouldn't be" );
}

# Helper method to do a search.
sub _search {
    my ( $this, $web, $topic, $user, $searchString ) = @_;

    my $query = new Unit::Request(
        {
            web       => [$web],
            topicName => [$topic],
            search    => [$searchString],
        }
    );
    $query->path_info("$web/$topic");

    my $foswiki = new Foswiki( $user, $query );

    my $response = new Unit::Response();
    $response->charset("utf8");

    my $search = Foswiki::Contrib::KinoSearchContrib::Search->newSearch();

    # Note: With $foswiki I hand over the just defined session. Thus I have full
    # control over query etc.
    my ( $text, $result ) =
      $this->capture( \&Foswiki::Contrib::KinoSearchContrib::Search::search,
        $search, 1, $foswiki );

    $foswiki->finish();

    # returns the html result for checking
    return $result;
}

1;
