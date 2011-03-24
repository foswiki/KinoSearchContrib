# ---+ Extensions
# ---++ KinoSearchContrib

# **STRING**
# Comma seperated list of webs to skip
$Foswiki::cfg{KinoSearchContrib}{SkipWebs} = 'Trash, Sandbox';

# **STRING**
# Comma seperated list of extenstions to index
$Foswiki::cfg{KinoSearchContrib}{IndexExtensions} = '.txt, .html, .xml, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .pdf';

# **STRING**
# List of attachments to skip
# For example: Web.SomeTopic.AnAttachment.txt, Web.OtherTopic.OtherAttachment.pdf
$Foswiki::cfg{KinoSearchContrib}{SkipAttachments} = '';

# **STRING**
# List of topics to skip.
# Topics can be in the form of Web.MyTopic, or if you want a topic to be excluded from all webs just enter MyTopic.
# For example: Main.WikiUsers, WebStatistics
$Foswiki::cfg{KinoSearchContrib}{SkipTopics} = '';

# **STRING**
# User language setting for KinoSearch
$Foswiki::cfg{KinoSearchContrib}{UserLanguage} = 'en';

# **NUMBER**
# Summary length
$Foswiki::cfg{KinoSearchContrib}{SummaryLength} = '300';

# **NUMBER**
# Absolute maximum limit for a search
$Foswiki::cfg{KinoSearchContrib}{MaxLimit} = '2000';

# **BOOLEAN**
# If using Kino as your {RCS}{SearchAlgorithm}, enable this to search attachments
$Foswiki::cfg{KinoSearchContrib}{showAttachments} = '0';

# **BOOLEAN**
# Provide a link in the templates to search attachments only
$Foswiki::cfg{KinoSearchContrib}{SearchAttachmentsOnly} = '0';

# **STRING**
# Attachments only label. Provides a link to search for attachments only if $Foswiki::cfg{KinoSearchContrib}{SearchAttachmentsOnly} is true.
$Foswiki::cfg{KinoSearchContrib}{AttachmentsOnlyLabel} = 'Show only attachments';

# **SELECT antiword,wv,abiword**
# Select which MS Word indexer to use (you need to have antiword, abiword or wvHtml installed)
# <dl>
# <dt>antiword</dt><dd>is the default, and should be used on Linux/Unix.</dd>
# <dt>wvHtml</dt><dd> is recommended for use on Windows.</dd>
# <dt>abiword</dt><dd></dd>
# </dl>
$Foswiki::cfg{KinoSearchContrib}{WordIndexer} = 'antiword';

# **COMMAND**
# abiword command
$Foswiki::cfg{KinoSearchContrib}{abiwordCmd} = 'abiword';

# **COMMAND**
# antiword command
$Foswiki::cfg{KinoSearchContrib}{antiwordCmd} = 'antiword';

# **COMMAND**
# wvHtml command
$Foswiki::cfg{KinoSearchContrib}{wvHtmlCmd} = 'wvHtml';

# **COMMAND**
# ppthtml command
$Foswiki::cfg{KinoSearchContrib}{ppthtmlCmd} = 'ppthtml';

# **COMMAND**
# pdftotext command
$Foswiki::cfg{KinoSearchContrib}{pdftotextCmd} = 'pdftotext';

# **COMMAND**
# pptx2txt.pl command
$Foswiki::cfg{KinoSearchContrib}{pptx2txtCmd} = 'pptx2txt.pl';

# **COMMAND**
# docx2txt.pl command
$Foswiki::cfg{KinoSearchContrib}{docx2txtCmd} = 'docx2txt.pl';

# **BOOLEAN**
#If using Foswiki::Store::SearchAlgorithms::Kino, enable this for SEARCH to also show attachments (Default is false)
$Foswiki::cfg{KinoSearchContrib}{showAttachments} = 0;

# **PATH**
# Where KinoSearh logs are stored
$Foswiki::cfg{KinoSearchContrib}{LogDirectory} = '$Foswiki::cfg{WorkingDir}/work_areas/KinoSearchContrib/logs';

# **PATH**
# Where KinoSearh index is stored
$Foswiki::cfg{KinoSearchContrib}{IndexDirectory} = '$Foswiki::cfg{WorkingDir}/work_areas/KinoSearchContrib/index';

# **BOOLEAN**
# Debug setting
$Foswiki::cfg{KinoSearchContrib}{Debug} = '0';

# **PERL H**
# This setting is required to enable executing the kinosearch script from the bin directory
$Foswiki::cfg{SwitchBoard}{kinosearch} = [
          'Foswiki::Contrib::KinoSearchContrib::Search',
          'searchCgi',
          {
            'kinosearch' => 1
          }
        ];
