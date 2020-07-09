package Retail::Model::Client;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Retail::Subs;
use Retail::DB;

use constant MAX_LEN_NAME = 255;

sub new {
    my $class = shift;
	bless {}, $class;
}

sub get {
    my ( $self, $id ) = @_;
    return unless is_num $id;

    my $strin = db->prepare("SELECT id, name FROM clients WHERE id = ?;");
    $strin->execute($id);
    if (db->errstr) { log( 'error', "SQL: Retail::Model::Client::get: database error: '" . db->errstr . "'" ); }

    my @val = $strin->fetchrow_array;
    $self->set_id($val[0]);
    $self->set_name($val[1]);

    return 1;
}

sub save {
    my $self = shift;
    return unless $self->id;



}

# проверки на формат параметров объекта
sub is_wrong_format_name {
    my $self = shift;
    if (! $self->name) {
        return "name is null";
    }

    if ( length $self->name > MAX_LEN_NAME ) {
        return "name is too big";
    }

    return;
}

sub id {return $_[0]->{id}}
sub name {return $_[0]->{name}}
sub err {return $_[0]->{err}}

sub set_id {$_[0]->{id} = $_[1];}
sub set_name {$_[0]->{name} = $_[1];}
sub set_err  {$_[0]->{err} = $_[1];}

1;