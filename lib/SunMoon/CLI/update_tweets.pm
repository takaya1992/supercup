package SunMoon::CLI::update_tweets;

use strict;
use warnings;
use utf8;

use Mojo::Base qw/Mojolicious::Command/;
use Net::Twitter;

use SunMoon::Service::TweetRegistrationService;
use SunMoon::Service::TweetRemoveService;

# コマンド一覧に表示される解説
has description => "DBのツイート情報を更新します。\n";

# ヘルプメッセージ
has usage => <<EOF;
usage: $0 
EOF

sub run {
    my ($self, @args) = @_;

    my $log = $self->app->log;
    $log->info('start commonad "update_tweets"');

    my $registration_service = SunMoon::Service::TweetRegistrationService->new(db => $self->app->db);
    my $remove_service = SunMoon::Service::TweetRemoveService->new(db => $self->app->db);

    my @tweets = $self->app->db->search('tweets', +{}, +{ order_by => 'updated_at', limit => 50} );
    if (@tweets) {
        $log->info(join("\t", ('firtst_tweet_id: ' . $tweets[0]->id, 'firtst_tweet_updated_at: ' . $tweets[0]->updated_at->strftime('%F %T'))));
        $log->info(join("\t", ('last_tweet_id: ' . $tweets[$#tweets]->id, 'last_tweet_updated_at: ' . $tweets[$#tweets]->updated_at->strftime('%F %T'))));
    }

    for (@tweets) {
        my $tweet;
        eval {
            $tweet = $self->app->twitter->show_status($_->id);
        };
        if ($@) {
            if ($@ =~ /^No status found with that ID/) {
                # ユーザもしくはツイートが消えていた場合
                $remove_service->exec($_->id);
            } elsif ($@ =~ /^Sorry, you are not authorized to see this status/) {
                # 鍵垢の場合
                $remove_service->exec($_->id);
            } else {
                die $@;
            }
        } else {
            $registration_service->exec($tweet);
        }

    }

    $log->info('finish commonad "update_tweets"');
}


1;

