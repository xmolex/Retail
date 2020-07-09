package Retail::Controller::Api::Barcode::Tobacco;
use Dancer2 appname => 'Retail';
use Modern::Perl;
use utf8;
use Retail::DB;
use Retail::Subs;
our $VERSION = '0.1';

use constant TOBACCO_TYPE => '1';

prefix '/api/barcode/tobacco';

get '' => sub {

    my $result = {};

    my $inn = query_parameters->get('inn');
    if ( ! $inn || ( $inn && ! is_num($inn) ) ) {
        $result->{is_fail} = 1;
        $result->{error_mess} = to_crlc_str("не указан ИНН");
        return to_crlc(encode_json($result));
    }

    my $strin = db->prepare("SELECT barcode FROM barcodes WHERE inn = ? AND type = ?;");
    $strin->execute(
        $inn,
        TOBACCO_TYPE,
    );
    if (db->errstr) { log( 'error', "SQL: Retail::Controller::Api::Barcode::Tobacco::get: database error: '" . db->errstr . "'" ); }

    my @barcodes;
    while ( my @val = $strin->fetchrow_array ) {
        push @barcodes, $val[0];
    }

    $result->{is_success} = 1;
    $result->{barcodes}   = \@barcodes;
    return to_crlc(encode_json($result));
};

post '' => sub {
    my $result = {};

    my $inn     = body_parameters->get('inn');
    my $barcode = body_parameters->get('barcode');

    # проверки
    if ( ! $inn || ( $inn && ! is_num($inn) ) ) {
        $result->{is_fail} = 1;
        $result->{error_mess} = to_crlc_str("не указан ИНН");
        return to_crlc(encode_json($result));
    }

    if ( ! $barcode || ( $barcode && ! is_num($barcode) ) ) {
        $result->{is_fail} = 1;
        $result->{error_mess} = to_crlc_str("не указан штрихкод");
        return to_crlc(encode_json($result));
    }

    # записываем
    db->do("DELETE FROM barcodes WHERE inn = ? AND type = ? AND barcode = ?;", undef,
        $inn,
        TOBACCO_TYPE,
        $barcode,
    );
    if (db->errstr) { log( 'error', "SQL: Retail::Controller::Api::Barcode::Tobacco::post: database error: '" . db->errstr . "'" ); }

    my $strin = db->prepare("INSERT INTO barcodes (inn, type, barcode) VALUES (?, ?, ?) RETURNING id;");
    $strin->execute(
        $inn,
        TOBACCO_TYPE,
        $barcode,
    );
    if (db->errstr) { log( 'error', "SQL: Retail::Controller::Api::Barcode::Tobacco::post: database error: '" . db->errstr . "'" ); }

    my @val = $strin->fetchrow_array;
    if (! $val[0]) {
        $result->{is_fail} = 1;
        $result->{error_mess} = to_crlc_str("не удалось записать, возможно уже есть");
        return to_crlc(encode_json($result));
    }

    $result->{is_success} = 1;
    $result->{inn} = $inn;
    $result->{barcode} = $barcode;
    return to_crlc(encode_json($result));

};

1;
