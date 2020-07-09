package Retail::Controller::Login;
use Dancer2 appname => 'Retail';
use Modern::Perl;
use utf8;
our $VERSION = '0.1';
use Retail::Subs;
use Retail::Model::User;

prefix '/login';

get '' => sub {
    my $redir_url = query_parameters->get('redirect_url');
	template 'login.tx', { redirect_url => $redir_url }, { layout => 'login.tx' };
};
 
post '' => sub {
	my $error = '';

    my $login     = body_parameters->get('login');
    my $pass      = body_parameters->get('pass');
    my $redir_url = body_parameters->get('redirect_url') || '/login';

    # авторизуемся
    my $obj_user = Retail::Model::User->new();
	my $user_id = $obj_user->auth( $login, $pass );

	# если авторизация успешна
    if ($user_id) {
        session user => $user_id;
        if ($redir_url eq '/login') {$redir_url = '/';}
        redirect $redir_url;
    }
	else {
        # неверные данные
        $error = 'Неверные данные';
        log( 'error', "Retail::Controller::Login: error auth: '" . $login . "', auth fail" );
        template 'login.tx', {
            error        => $error,
            redirect_url => $redir_url,
            login        => tr_html($login),
        }, { layout => 'login.tx' };
	}

};

1;
