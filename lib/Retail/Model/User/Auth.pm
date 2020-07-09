package Retail::Model::User::Auth;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Retail::DB;
use Retail::Subs;

# авторизация пользователя
sub auth {
    my $self = shift;
	my ( $form_login, $form_pass ) = @_;

    # минимальные проверки
    return if ( !$form_login || length($form_login) < 3 );
    return if ( !$form_pass || length($form_pass) < 3 );

    # ищем в базе по аккаунту
    my $strin = db->prepare("SELECT id, pw, salt FROM users WHERE LOWER(account) = LOWER(?)");
	$strin->execute($form_login);
	if (db->errstr) {log( 'error', "Retail::Model::User::Auth::auth: database error: '" . db->errstr . "'" );}

    my @val = $strin->fetchrow_array;
    # проверка на логин
    return unless $val[0];

    my $user_id   = $val[0];
    my $user_pass = $val[1];
    my $user_salt = $val[2];
    $form_pass = __PACKAGE__->crypt_pass( $form_pass, $user_salt ); # получаем хэшь пароля с солью

    # проверяем на пароль
    return if $user_pass ne $form_pass;

    # комбинация верна, получаем данные и меняем время последней авторизации
    $self->get($user_id);
    $self->set_last_auth(get_sql_time());
    $self->save();

    return $user_id;
}

1;
