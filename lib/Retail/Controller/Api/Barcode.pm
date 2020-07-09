package Retail::Controller::Api::Barcode;
use Dancer2 appname => 'Retail';
use Modern::Perl;
use utf8;
our $VERSION = '0.1';
use Retail::Controller::Api::Barcode::Tobacco;

prefix '/api/barcode';

any ['get','post'] => '' => sub {
    return '';
};

1;
