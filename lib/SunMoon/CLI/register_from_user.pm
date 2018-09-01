package SunMoon::CLI::register_from_user;

use strict;
use warnings;
use utf8;

use Mojo::Base qw/Mojolicious::Command/;
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Math::BigInt;

use Data::Dumper;

use SunMoon::Service::TweetRegistrationService;
use SunMoon::Service::TweetRemoveService;

# コマンド一覧に表示される解説
has description => "指定されたユーザのツイートから該当のツイートを登録します。\n";

# ヘルプメッセージ
has usage => <<EOF;
usage: $0 

These options are available:
  -u --user ユーザのscreen_nameを指定します。
EOF

sub run {
    my ($self, @args) = @_;
    my $log = $self->app->log;
    $log->info('start commonad "register_from_user"');


    GetOptionsFromArray(\@args, 'u|user=s' => \(my $screen_name))
        or die $self->usage;
    die $self->usage unless ($screen_name);

    $log->info('user_screen_name: ' . $screen_name);

    $log->info('started get all tweets');
    my @tweets = $self->_get_all($screen_name);
    $log->info('finished get all tweets');
    my @filtered_tweets = grep {
        grep { $_->{text} eq 'スーパーカップダンススタジアム' } @{$_->{entities}->{hashtags}};
    } @tweets;
    $log->info('filtered tweets: ' . scalar(@filtered_tweets));

    my $registration_service = SunMoon::Service::TweetRegistrationService->new(db => $self->app->db);
    for (@filtered_tweets) {
        $registration_service->exec($_);
    }
    $log->info('finish commonad "register_from_user"');
}

sub _get_all {
    my ($self, $screen_name) = @_;

    my $min_id_str;
    my @tweets;

    for (my $i = 0; $i < 16; $i++) {
        my $results = $self->app->twitter->user_timeline({
            screen_name     => $screen_name,
            count           => 200,
            trim_user       => 0,
            exclude_replies => 0,
            include_rts     => 1,
            $min_id_str ? (max_id => Math::BigInt->new($min_id_str)->bsub(1)->bstr()) : (),
        });
        my @statuses = @$results;
        last if (scalar(@statuses) == 0);
        $min_id_str = $statuses[$#statuses]->{id_str};
        push(@tweets, @statuses);
    }


    return @tweets;
}


1;

__END__


