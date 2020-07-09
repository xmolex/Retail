package Retail::Controller::Api;
use Dancer2 appname => 'Retail';
use Modern::Perl;
use utf8;
our $VERSION = '0.1';
use Retail::Controller::Api::Barcode;

prefix '/api';

any ['get','post'] => '' => sub {
    return '';
};

1;
