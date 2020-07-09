package Retail::Model::User;
use Modern::Perl;
use utf8;
use Dancer2 appname => 'Retail';
use Retail::DB;
use Retail::Subs;
use parent 'Retail::Model::User::Auth';
use parent 'Retail::Model::User::Crypt';

sub new {
    my $class = shift;
	bless {}, $class;
}

# получаем экземпляр объекта
sub get {
    my ( $self, $id ) = @_;
	return unless is_num $id;

	my $strin = db->prepare("SELECT id, is_active, account, pw, salt, last_auth FROM users WHERE id = ?");
	$strin->execute($id);
	if (db->errstr) {log( 'error', "Retail::Model::User::get: database error: '" . db->errstr . "'" );}

	my @val = $strin->fetchrow_array;
	return if ( !$val[0] || !is_num($val[0]) );

	$self->{id}         = $val[0];
	$self->{is_active}  = $val[1];
	$self->{account}    = $val[2];
	$self->{pw}         = $val[5];
	$self->{salt}       = $val[6];
	$self->{last_auth}  = $val[7];

	return 1;
}

# создаем нового пользователя
sub create {
    my $self = shift;
    my %param = @_;

    return unless $param{account};
    return unless $param{password};

    # проверяем доступность логина
    return( undef, "логин занят" ) if is_account_exists( $param{account} ); # аккаунт занят

    # регистрируем
    my $salt         = gen_salt(); # генерируем соль
    $param{password} = crypt_pass( $param{password}, $salt ); # получаем хэшь пароля с солью

    # добавляем в базу
    my $strin = db->prepare("INSERT INTO users (account, pw, salt) VALUES (?, ?, ?) RETURNING id;");
	$strin->execute(
        $param{account},
        $param{password},
        $salt,
	);
	if (db->errstr) {log( 'error', "Retail::Model::User::create: database error: '" . db->errstr . "'" );}

	my @val = $strin->fetchrow_array;
	if ($val[0]) {
	    if ( $self->get($val[0]) ) {
	        return $val[0];
	    }
	}

    return;
}

# сохраняем состояние в базу
sub save {
    my $self = shift;
	return unless $self->{id};

	db->do("UPDATE users SET is_active = ?, account = ?, pw = ?, salt = ?, last_auth = ? WHERE id = ?", undef,
	    $self->is_active,
	    $self->account,
	    $self->pw,
	    $self->salt,
	    $self->last_auth,
	    $self->{id}
	);

	if (db->errstr) {
	    log( 'error', "Retail::Model::User::save: database error: '" . db->errstr . "'" );
        return;
	}

    return 1;

}

# проверяем доступность логина и возвращаем идентификатор, либо ложь
sub is_account_exists {
    my ($self, $account) = @_;
    my $strin = db->prepare("SELECT id FROM users WHERE LOWER(account) = LOWER(?);");
    $strin->execute($account);
    my @val = $strin->fetchrow_array;
    return $val[0];
}

# аксессоры
sub id        {return $_[0]->{id}}
sub is_active {return $_[0]->{is_active}}
sub account   {return $_[0]->{account}}
sub pw        {return $_[0]->{pw}}
sub salt      {return $_[0]->{salt}}
sub last_auth {return $_[0]->{last_auth}}

sub set_is_active { $_[0]->{is_active} = $_[1]; }
sub set_account   { $_[0]->{account}   = $_[1]; }
sub set_pw        { $_[0]->{pw}        = $_[1]; }
sub set_salt      { $_[0]->{salt}      = $_[1]; }
sub set_last_auth { $_[0]->{last_auth} = $_[1]; }

1;
