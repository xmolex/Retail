package Retail;
use Dancer2;
use Modern::Perl;
use utf8;
our $VERSION = '0.1';
use Retail::Controller::Api;
use Retail::Controller::Login;

prefix undef;

hook before => sub {
    if ( !session('user')               # если нет сессии
         && request->path !~ m{^/login} # если не страница авторизации
         && request->path !~ m{^/api} # если не страница API
    ) {
        # редирект на авторизацию
        forward '/login', { redirect_url => request->path };
    }
    elsif ( session('user') ) {
        # сессия есть, проверяем наличие в базе
        my $obj_user = Cpop::Model::User->new();
        if (! $obj_user->get( session('user') ) ) {
            # в базе не нашелся, редирект на авторизацию
            session user => 0;
            forward '/login', { redirect_url => request->path };
        }
        elsif (! $obj_user->is_active ) {
            # в базе есть, но не активен, редирект на авторизацию
            session user => 0;
            forward '/login', { redirect_url => request->path };
        }
        vars->{obj_user} = $obj_user;
    }
};

get '/' => sub {
    template 'index' => {};
};

1;
