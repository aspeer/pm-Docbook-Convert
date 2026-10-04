# Docbook::Convert

Convert DocBook documentation to Markdown. For large guides, the new
Pandoc pipeline expands included examples and preserves section IDs and MkDocs
admonitions using the filters supplied with this distribution.

## Installation

Install the released distribution and its Perl prerequisites from CPAN:

```sh
cpanm Docbook::Convert
```

Install Pandoc, xmllint and xsltproc through your system package manager.

## GitHub Attestations

The release workflow generates [GitHub artifact attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
for distribution archives. Install the [GitHub CLI](https://cli.github.com/)
with `gh attestation` support and authenticate with `gh auth login`.

To verify a CPAN release archive separately, download
`Docbook-Convert-VERSION.tar.gz` from MetaCPAN or a CPAN mirror, replace
`VERSION`, and run:

```sh
gh attestation verify Docbook-Convert-VERSION.tar.gz --repo aspeer/pm-Docbook-Convert
```

A successful verification confirms that the archive checksum matches an
attestation from this repository. The workflow publishes the same archive to
GitHub Releases and CPAN. Older releases and GitHub's automatically generated
source-code archives are not covered.

## Installation Pre-requisites

Docbook::Convert depends on external system libraries for conversion. It either uses itself - or its downstream dependencies need - the following are installed:
* `xmllint`
* `xsltproc/libxlt`
* `pandoc`
* `expat/expat-devel`
Use your system packaging tool to install *before* installing the module


## Convert

```sh
docbook-convert --pandoc doc/guide.xml > doc/guide.md
```

```perl
use Docbook::Convert::Pandoc;
my $markdown=Docbook::Convert::Pandoc->new()->convert_file('doc/guide.xml');
```

See [the Pandoc API](lib/Docbook/Convert/Pandoc.pm.md) and
[the examples](examples/README.md).

A custom Markdown renderer is also available through `docbook-convert --markdown`.
A failed Pandoc conversion does not silently fall back to it.  

For checkout development, install the documentation integration from CPAN with
`cpanm ASPEER::MakeMaker::Markdown::Pod`, then rerun `perl Makefile.PL` to
enable this distribution's own `make doc` targets.
