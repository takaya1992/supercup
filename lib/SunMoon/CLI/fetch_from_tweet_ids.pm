package SunMoon::CLI::fetch_from_tweet_ids;

use strict;
use warnings;
use utf8;

use Mojo::Base qw/Mojolicious::Command/;
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Net::Twitter;

use SunMoon::Service::TweetRegistrationService;
use SunMoon::Service::TweetRemoveService;

# コマンド一覧に表示される解説
has description => "ツイートのIDのリストからデータを取得します。\n";

# ヘルプメッセージ
has usage => <<EOF;
usage: $0 

These options are available:
  -f --file ツイートのIDリスト(改行区切り)
EOF

sub run {
    my ($self, @args) = @_;

    GetOptionsFromArray(\@args, 'f|file=s' => \(my $filename))
        or die $self->usage;

    my $registration_service = SunMoon::Service::TweetRegistrationService->new(db => $self->app->db);
    my $remove_service = SunMoon::Service::TweetRemoveService->new(db => $self->app->db);

    open(FILE, '<', $filename) or die "$!";
    while (my $tweet_id = <FILE>) {
        chomp($tweet_id);
        print $tweet_id . "\n";
        my $tweet;
        eval {
            $tweet = $self->app->twitter->show_status($tweet_id);
        };
        if ($@) {
            if ($@ =~ /^No status found with that ID/) {
                $remove_service->exec($tweet_id);
            } elsif ($@ =~ /^Sorry, you are not authorized to see this status/) {
                # 鍵垢の場合はスルーする
            } else {
                close(FILE);
                die $@;
            }
        } else {
            $registration_service->exec($tweet);
        }
    }
    close(FILE);
}


1;
