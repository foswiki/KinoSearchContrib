#!/usr/bin/perl -w
#
# Copyright (C) 2007 Markus Hesse
# Copyright (C) 2009 Foswiki Contributors
#
# For licensing info read LICENSE file in the Foswiki root.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at 
# http://www.gnu.org/copyleft/gpl.html
# Set library paths in @INC, at compile time

package Foswiki::Contrib::KinoSearchContrib::KinoSearch;

use Foswiki;
use Foswiki::Func;
use Error qw( :try );
use Time::Local;
use IO::File;

use KinoSearch::InvIndexer;
use KinoSearch::Analysis::PolyAnalyzer;

#use Foswiki::Contrib::KinoSearchContrib::Stringifier;
use strict;

# Create a new instance of self.
# parameter: Type may be "index", "update" or "search"
# QS
sub new {
    my $handler = shift;
    my $type    = shift;
    my $self = bless {}, $handler;

    if (!($type eq "search") ) {$self->{Log} = $self->openLog($type)};
    $self->{Debug}   = $self->debugPref();

    $self
}

sub openLog {
    my ($self, $type) = (@_);

    my $LOGFILE = new IO::File;
    my $fileName = $self->logFileName($type);

    $LOGFILE->open(">>$fileName") || die "Logfile cannot be opend in $fileName.";
    autoflush $LOGFILE;

    $LOGFILE;
}

sub log {
    my ($self, $logString, $force) = (@_);
 
    if ($self->{Debug} || $force || 0) {
	my $logtime = Foswiki::Func::formatTime( time(), '$rcs', 'servertime' ); 
	$self->{Log}->print( "| $logtime | $logString |\n");

	#print STDERR "$logString\n";
    }
    $self->{Debug} && Foswiki::Func::writeDebug( $logString );
}

# Yields the directory, I want to do logs
# I take $Foswiki::cfg{KinoSearchLogDir} or if not given 
# Foswiki::Func::getPubDir()/../kinosearch/logs
# QS
sub logDirName {
    my $log = $Foswiki::cfg{KinoSearchContrib}{LogDirectory};

    if (!$log) {
	$log = Foswiki::Func::getPubDir();
	$log .="/../kinosearch/logs";
    }

    return $log;
}

sub logFileName {
    my ($self, $prefix) = (@_);
    my $logdir = logDirName();
    my $time = Foswiki::Func::formatTime( time(), '$year$mo$day', 'servertime');

    return "$logdir/$prefix-$time.log";
}


# Path where the index is stored
# QS
sub indexPath {
    my $idx = $Foswiki::cfg{KinoSearchContrib}{IndexDirectory};

    if (!$idx) {
	$idx = Foswiki::Func::getPubDir();
	$idx .="/../kinosearch/index";
    }

    return $idx;
}

# Path where the attachments are stored.
# QS
sub pubPath {
    return Foswiki::Func::getPubDir(); 
}

# List of webs that shall not be indexed
# QS
sub skipWebs {
    
    my $to_skip = $Foswiki::cfg{KinoSearchContrib}{SkipWebs} || "Trash, Sandbox";
    my %skipwebs;

    foreach my $tmpweb ( split( /\,\s+|\,|\s+/, $to_skip ) ) {
	$skipwebs{$tmpweb} = 1;
    }
    return %skipwebs;
}

# List of attachments to be skipped.
# QS
sub skipAttachments {
    my $to_skip = $Foswiki::cfg{KinoSearchContrib}{SkipAttachments} || '';
    my %skipattachments;

    foreach my $tmpattachment ( split( /\,\s+/, $to_skip ) ) {
	$skipattachments{$tmpattachment} = 1;
    }
    
    return %skipattachments;
}

# List of topics to be skipped.
sub skipTopics {
    my $to_skip = $Foswiki::cfg{KinoSearchContrib}{SkipTopics} || '';
    my %skiptopics;

    foreach my $t ( split( /\,\s+/, $to_skip ) ) {
	$skiptopics{$t} = 1;
    }
    
    return %skiptopics;
}

# List of file extensions to be indexed
# QS
sub indexExtensions {
    my $extensions = $Foswiki::cfg{KinoSearchContrib}{IndexExtensions} || ".txt, .html, .xml, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .pdf";
    my %indexextensions;

    foreach my $tmpextension ( split( /\,\s+/, $extensions ) ) {
	$indexextensions{$tmpextension} = 1;
    }

    return %indexextensions;
}

# QS
sub analyserLanguage {
    return $Foswiki::cfg{KinoSearchContrib}{UserLanguage} || 'en';
}

sub summaryLength {
    return $Foswiki::cfg{KinoSearchContrib}{SummaryLength} || 300;
}

# Returns, if debug statements etc shall be shown
# QS
sub debugPref {
    return $Foswiki::cfg{KinoSearchContrib}{Debug} || 0;
}

# Returns an analyser
# QS
sub analyser {
    my ($self, $language) = @_;

    return KinoSearch::Analysis::PolyAnalyzer->new( language => $language);
}

1;
