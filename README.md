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

The custom Markdown renderer remains available through `docbook-convert --markdown`.
A failed Pandoc conversion does not silently fall back to it. Direct DocBook-to-POD
conversion is retired; use Markdown::Pod::Embed for Perl sidecar documentation.

For checkout development, install the documentation integration from CPAN with
`cpanm ASPEER::MakeMaker::Markdown::Pod`, then rerun `perl Makefile.PL` to
enable this distribution's own `make doc` targets.
