# Docbook::Convert 3 #

# NAME #

Docbook::Convert - Convert Docbook articles and refentry&#39;s to other formats such as Markup and POD

# SYNOPSIS #

```
# Use on file handle
#
use Docbook::Convert;
open FILE, 'docbook.xml' or die $!;
print Docbook::Convert->markdown(*FILE);
print Docbook::Convert->pod(*FILE);

# Use on existing file
#
print Docbook::Convert->markdown_file('docbook.xml');

# Use on existing string
#
print Docbook::Convert->markdown($docbook);

# Specify output options
#
print Docbook::Convert->markdown($docbook, { meta_display_top=>1 });
```

# Description #

Docbook::Convert Perl will convert between Docbook and other formats \- currently Markdown and POD. It is intended to let authors write documentation in Docbook, and then output it to more easily publishable formats such as Markdown \- or have it converted to POD and optionally merged into a perl programs or module.

It currently supports as subset of Docbook tags, and its intent is to convert Docbook 4+ article and refentry templates with common entites into manual pages or other documentation.

# Methods #

The following public methods are supplied:

* **process($xml, \%opt)**

    Convert an XML string or file handle into a different format. Unless directed via the handler option the default conversion will be to Markdown

* **process_file($filename, \%opt)**

    Convert an XML file \- specified in $filename \- into a different format. As per the process method the default convertsion if not otherwise specified will be Markdown.

* **markdown($xml, \%opt)**

    A shortcut to the process method with the Markdown handler implied

* **markdown_file**

    A shortcut to the process_file method with the Markdown handler implied

* **pod($xml, \%opt)**

    A shortcut to the process method with the POD handler implied

* **pod_file($xml, \%opt)**

    A shortcut to the process_file method with the POD handler implied

# Options #

The following options can be supplied to the process methods as a hash reference as per the synopsis example:

* **meta_display_top**

    If the Docbook Refentry or Article contains metadata \(author, publication date etc.) display it at the top of the file in &quot;key: value&quot; format. By default metadata is not displayed. Supply as boolean.

* **meta_display_bottom**

    As per meta_display_top but output at bottom.

* **meta_display_title**

    If the metadata is to be prefixed with a title supply as a string.

* **meta_display_title_h_style**

    If a title is supplied the option will set which heading style is used to generate it. By default output is the equivalent of &quot;Heading 1&quot;. Supported values are &#39;h1&#39; through to &#39;h4&#39;

* **no_html**

    Do not comingle HTML with the generated output. For some output handlers where the desired output outcome is not available natively HTML may be supplied \(e.g. Markdown). Setting this option to 1 will suppress any HTML output. Naturally this may limit the completeness of any conversion

* **no_image_fetch**

    For some Docbook image entities attributes that control the scaling of images may be supplied. If they are found in some cases the images may need to be fetched to generate the appropriate HTML width paramaters. Setting this option to 1 will suppress any remote image fetching and thus will disable any image scaling in conversions.

* **no_warn_unhandled**

    By default Docbook entites that are not handled in the conversion process \(because the code does not yet cater for them) generate a warning. Setting this option to 1 will suppress any warnings.

# Environment #

The following environment variables will alter the behaviour or the module as per their Option equivalent:

* META_DISPLAY_TOP

* META_DISPLAY_BOTTOM

* META_DISPLAY_TITLE

* META_DISPLAY_TITLE_H_STYLE

* NO_HTML

* NO_IMAGE_FETCH

* NO_WARN_UNHANDLED

# Files #

The file  `&lt;sitelibpath&gt;/Docbook/Convert/Constants.pm`  contains global settings which influence the behaviour of the module. Whilst this file can be edited any changes will be overwritten if the module is updated. If a file named  `&lt;sitelibpath&gt;/Docbook/Convert/Constants.pm.local`  exists, then any entries in that file will override the local globals. The file format should be that of an anoymous hash reference, e.g file contents of:

```
{
    NO_HTML         => 1,
    NO_IMAGE_FETCH  => 1
}
```

Will change the defaults for the named globals. The syntax needs to be perl correct \- check file has no errors when run against  `perl -c -w <dir>/Constants.pm.local`

# Caveats #

This module does not puport to handle all Docbook entity tags or templates. It operates on a limited subset of entity tags commonly used for describing manual pages for Perl modules and other Unix utilities.

# Author #

Andrew Speer  <aspeer@cpan.org>

# LICENSE and COPYRIGHT #

This file is part of Docbook::Convert.

This software is copyright \(c) 2017 by Andrew Speer &lt;andrew.speer@isolutions.com.au&gt;.

This is free software; you can redistribute it and/or modify it underthe same terms as the Perl 5 programming language system itself.

Full license text is available at:

&lt;http://dev.perl.org/licenses/&gt;