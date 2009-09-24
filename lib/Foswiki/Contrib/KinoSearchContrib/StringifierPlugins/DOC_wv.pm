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

package Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::DOC_wv;
use base 'Foswiki::Contrib::KinoSearchContrib::StringifyBase';
use File::Temp qw/tmpnam/;

my $wvHtml = $Foswiki::cfg{KinoSearchContrib}{wvHtmlCmd} || 'wvHtml';

if (!defined($Foswiki::cfg{KinoSearchContrib}{WordIndexer}) || 
    ($Foswiki::cfg{KinoSearchContrib}{WordIndexer} eq 'wvHtml')) {
    # Only if wv exists, I register myself.
    if (__PACKAGE__->_programExists($wvHtml)){
        __PACKAGE__->register_handler("application/word", ".doc");
    }
}

sub stringForFile {
    my ($self, $file) = @_;
    my ($tmp_file, $tmp_dir);

    # Creates a temp file name and checks if it exists
    do {
        $tmp_file = tmpnam();
        $tmp_dir = $tmp_file;
        $tmp_dir =~ s/^(.*)\/.*$/$1/;
        $tmp_file =~ s/.*\///;
    } while (-f "$tmp_dir/$tmp_file");

    my $in;
    my $text = '';
    
    $tmp_file = "$tmp_dir/$tmp_file";
    return '' if (-f $tmp_file) || (!(-z $tmp_file));
    
    my $cmd = $wvHtml . ' --targetdir=%TMPDIR|F% \'%FILENAME|F%\' %TMPFILE|F%';
    my ($output, $exit) = Foswiki::Sandbox->sysCommand($cmd, TMPDIR => $tmp_dir, FILENAME => $file, TMPFILE => $tmp_file );
    
    return '' unless ($exit == 0);

    $text = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($tmp_file);

    # Deletes temp files (main html and images)
    $self->rmtree($tmp_file);

    return $text;
}

1;
