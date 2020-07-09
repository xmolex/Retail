package Retail::Subs;
#########################################################################################################
# общие функции широкого спектра
#########################################################################################################
use Modern::Perl;
use Encode;
use utf8;
use Exporter 'import';

our @EXPORT = qw(
    str_trim
    tr_html
    get_sql_time
    is_num
    to_crlc
    to_crlc_str
    from_crlc
    from_crlc_str
    str_exists_in_array
);

# очищаем от пробелов в начале и конце
sub str_trim {
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
}

# производим замены для принятых значений, которые должны пойти на вывод в html
sub tr_html {
    my $str = shift;
    $str =~ s/&/&amp;/gs;
    $str =~ s/</&lt;/gs;
    $str =~ s/>/&gt;/gs;
    $str =~ s/'/&apos;/gs;
    $str =~ s/"/&quot;/gs;
    return $str;
}

# формируем дату и время для базы данных, либо только дату (флаг вторым параметром)
# время можно передать в unix формате
sub get_sql_time {
    my $time = shift // time();
    my( $sec, $min, $hour, $mday, $mon, $year ) = localtime($time);
    $year = $year + 1900;
    $mon++;
    
    # добавляем ведущие нули
    $mon  = sprintf '%02d', $mon;
    $mday = sprintf '%02d', $mday;
    $hour = sprintf '%02d', $hour;
    $min  = sprintf '%02d', $min;
    $sec  = sprintf '%02d', $sec;
    
    if ($_[0]) {
        # запрос только на дату
        return "$year-$mon-$mday";
    }
    else {
        # запрос на дату и время
        return "$year-$mon-$mday $hour:$min:$sec";
    }
    
}

# возвращаем истину, если это целое число больше, либо равно нулю
sub is_num {
    return unless defined $_[0];
    $_[0] =~ m/^\d+$/ ? return(1) : return;
}

sub to_crlc {
    Encode::_utf8_on($_[0]);
    return $_[0];
}

sub to_crlc_str {
    my $str = $_[0];
    Encode::_utf8_on($str);
    return $str;
}

sub from_crlc {
    Encode::_utf8_off($_[0]);
    return $_[0];
}

sub from_crlc_str {
    my $str = $_[0];
    Encode::_utf8_off($str);
    return $str;
}

# возвращаем истину, если строка есть в массиве
sub str_exists_in_array {
    my ($str, @array) = @_;
    for my $array_current_str (@array) {
        return 1 if $array_current_str eq $str;
    }

    return;
}

1;
