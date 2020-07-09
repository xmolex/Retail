package Retail::Model::Product;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Retail::Subs;
use Retail::DB;

sub new {
    my $class = shift;
	bless {}, $class;
}

1;