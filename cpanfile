requires 'HTML::Entities';
requires 'Test::Simple', '0.44';
requires 'Text::Table';
requires 'XML::Twig', '3.40';
requires 'perl', '5.006';
suggests 'Image::Magick';
suggests 'LWP::UserAgent';
suggests 'PPI';

on configure => sub {
    requires 'ExtUtils::MakeMaker';
    requires 'perl', '5.006';
};

on build => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Digest::MD5';
    requires 'Test::More';
};
