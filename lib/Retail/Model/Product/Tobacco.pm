package Retail::Model::Product::Tobacco;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Retail::Subs;
use Retail::DB;
use parent 'Retail::Model::Product';

sub new {
    my $class = shift;
	bless {}, $class;
}

1;
