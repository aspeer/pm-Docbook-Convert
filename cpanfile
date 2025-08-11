requires 'Test::Simple', '0.44';
requires 'Text::Table';
requires 'XML::Twig', '3.40';
requires 'perl', '5.006';

on configure => sub {
    requires 'ExtUtils::MakeMaker';
};

on build => sub {
    requires 'ExtUtils::MakeMaker';
};
