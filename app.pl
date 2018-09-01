use Mojolicious::Lite;
use Text::Xslate;
use Net::Twitter;

use Data::Dumper;

use SunMoon::Model;
use SunMoon::Model::HighSchoolRanking;

plugin 'xslate_renderer' => {
    template_options => {
        cache_dir => $Text::Xslate::DEFAULT_CACHE_DIR,
        function => {
            number_separator => sub {
                my $number = shift;
                1 while $number =~ s/(.*\d)(\d\d\d)/$1,$2/;
                return $number;
            },
        },
    },
};

app->helper(
    db => sub {
        my $c = shift;
        $c->{__db} ||= do {
            my $dsn = 'dbi:mysql:' . $ENV{DB_NAME} . ':' . $ENV{DB_HOST};
            SunMoon::Model->new(
                connect_info => [
                    $dsn,
                    $ENV{DB_USER},
                    $ENV{DB_PASSWORD},
                    { mysql_enable_utf8 => 1 },
                ],
                # { mysql_enable_utf8 => 1 } を有効にすると utf8 固定になってしまうので、 `SET NAMES utf8mb4` を設定する必要がある。
                # c.f. http://www.songmu.jp/riji/archives/2013/05/dbdmysqlmysql_e.html
                on_connect_do => [ 'SET NAMES utf8mb4' ],
            );
        };
        return $c->{__db};
    }
);

app->helper(
    twitter => sub {
        my $c = shift;
        $c->{__twitter} ||= do {
            my $nt = Net::Twitter->new(
                traits          => [ qw/AppAuth API::RESTv1_1/ ],
                consumer_key    => $ENV{TWITTER_CONSUMER_KEY},
                consumer_secret => $ENV{TWITTER_CONSUMER_SECRET},
            );
            $nt->request_access_token;
            $nt;
        };
        return $c->{__twitter};
    }
);

get '/' => sub {
    my $self = shift;
    my $model = SunMoon::Model::HighSchoolRanking->new(db => $self->db);
    my @results = $model->get();
    $self->render(results => \@results);
} => 'index';

my $commands = app->commands;
push @{ $commands->namespaces }, 'SunMoon::CLI';

app->start;
