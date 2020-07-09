#!/usr/bin/perl
# parse.pl
use strict;
use utf8;
use LWP 5.64;
use LWP::UserAgent;
use XML::Simple;
use Encode;

use constant SERVER_URL => 'http://78.24.223.200/api/barcode/tobacco';
use constant WORK_DIR   => 'd:/git/retail/Retail/var/bin/';

# browser init
my $browser = LWP::UserAgent->new;
$browser->timeout(30);

work();
sub work {
    # получаем список файлов и обрабатываем каждый файл
    for my $file (get_file_list()) {
        print "== file: $file ==\n";

        my ( $inn, @barcodes ) = parse_xml_file( WORK_DIR . '/' . $file);
        print 'INN: ' . $inn . "\n";
        print "Found barcodes: " . ( scalar @barcodes ) . "\n";

        # отправляем на сервер
        for my $barcode (@barcodes) {
            print "  $barcode ";
            send_to_server(
                inn => $inn,
                barcode => $barcode,
            );
            print "\n";
        }

        print "\n";
    }
}

# отправляем данные на сервер
sub send_to_server {
    my %param = @_;
    my $response = $browser->post(
        SERVER_URL,
        \%param,
        'Content-Type'=> 'multipart/form-data'
    );

    if ($response->is_success) {
        my $answer = $response->content;
        Encode::from_to($answer,'utf8','cp866');
        print $answer;
    }
    else {
        print $response->status_line;
    }
}

# получаем список файлов для анализа
sub get_file_list {
    opendir my $dh, WORK_DIR or die "Could not open 'WORK_DIR' for reading: $!\n";
    my @files = grep { /\.xml$/i } readdir($dh);
    closedir $dh;
    return @files;
}

# разбираем файл и пытаемся получить требуемые данные
sub parse_xml_file {
    my $file = shift || return;
    my $inn;
    my @barcodes;

    my $data = XML::Simple->new()->XMLin( $file, KeepRoot => 1 );

    # находим ИНН
    if ( ref $data eq 'HASH' &&
         ref $data->{'Файл'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'СвСчФакт'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'СвСчФакт'}->{'СвПокуп'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'СвСчФакт'}->{'СвПокуп'}->{'ИдСв'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'СвСчФакт'}->{'СвПокуп'}->{'ИдСв'}->{'СвИП'} eq 'HASH'
    ) {
        $inn = $data->{'Файл'}->{'Документ'}->{'СвСчФакт'}->{'СвПокуп'}->{'ИдСв'}->{'СвИП'}->{'ИННФЛ'};
    }

    # собираем штрихкоды
    if ( ref $data eq 'HASH' &&
         ref $data->{'Файл'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'ТаблСчФакт'} eq 'HASH' &&
         ref $data->{'Файл'}->{'Документ'}->{'ТаблСчФакт'}->{'СведТов'} eq 'ARRAY'
    ) {
        my @products = @{ $data->{'Файл'}->{'Документ'}->{'ТаблСчФакт'}->{'СведТов'} };
        for my $product (@products) {
            if ( ref $product->{'ДопСведТов'} eq 'HASH' &&
                 ref $product->{'ДопСведТов'}->{'НомСредИдентТов'} eq 'HASH' &&
                 exists $product->{'ДопСведТов'}->{'НомСредИдентТов'}->{'НомУпак'}
            ) {
                # получаем штрихкод
                if ( ref $product->{'ИнфПолФХЖ2'} eq 'HASH' ) {

                }
                elsif ( ref $product->{'ИнфПолФХЖ2'} eq 'ARRAY' ) {
                    for my $el ( @{ $product->{'ИнфПолФХЖ2'} } ) {
                        if ( exists $el->{'Идентиф'} && exists $el->{'Значен'} && $el->{'Идентиф'} eq 'штрихкод' ) {
                            push @barcodes, $el->{'Значен'};
                        }
                    }
                }
            }
        }
    }

    return ( $inn, @barcodes );
}
