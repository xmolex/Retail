package Retail::Model::User::Crypt;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Crypt::Random;
use Crypt::Eksblowfish::Bcrypt;

# расчитываем хэш пароля
sub crypt_pass {
    my ( $self, $pass, $salt ) = @_;
    $pass = Crypt::Eksblowfish::Bcrypt::bcrypt_hash( {
            key_nul => 1,
            cost => 8,
            salt => substr $salt . get_perm_salt(), 0, 16,
        }, $pass);
    return Crypt::Eksblowfish::Bcrypt::en_base64($pass);
}

# генерируем сессию
sub gen_sess {
   my @sess = ("A".."Z","a".."z",0..9);
   return join( "", @sess[map { rand @sess } (1..50) ] );
}

# возвращаем статическую соль из конфига проекта
sub get_perm_salt {
    return setting('secrets');
}

# генерируем соль
sub gen_salt {
    my $salt = Crypt::Eksblowfish::Bcrypt::en_base64(Crypt::Random::makerandom_octet(Length=>16));
    $salt = substr $salt, 0, 10;
    return $salt;
}

1;