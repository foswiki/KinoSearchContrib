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

package Foswiki::Contrib::KinoSearchContrib::StringifyPlugins::PDF;
use base 'Foswiki::Contrib::KinoSearchContrib::StringifyBase';

my $pdftotext = $Foswiki::cfg{KinoSearchContrib}{pdftotextCmd} || 'pdftotext';

# Only if pdftotext exists, I register myself.
if (__PACKAGE__->_programExists($pdftotext)){
    __PACKAGE__->register_handler("application/pdf", ".pdf");}
use File::Temp qw/tmpnam/;

sub stringForFile {
    my ($self, $filename) = @_;
    my $tmp_file = tmpnam();
    my $in;
    my $text;
    
    return '' if (-f $tmp_file);
    
    my $cmd = $pdftotext . ' %FILENAME|F% %TMPFILE|F% -q';
    my ($output, $exit) = Foswiki::Sandbox->sysCommand($cmd, FILENAME => $filename, TMPFILE => $tmp_file);
    
    return '' unless ($exit == 0);
    
    # Note: This way, the encoding of the text is reworked in the text stringifier.
    $text = Foswiki::Contrib::KinoSearchContrib::Stringifier->stringFor($tmp_file);

    unlink($tmp_file);

    return $text;
}

1;
