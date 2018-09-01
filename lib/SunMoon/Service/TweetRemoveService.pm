# ツイートのIDを受け取ってそれを消すサービス
package SunMoon::Service::TweetRemoveService;

use strict;
use warnings;
use utf8;

sub new {
    my ($class, %args) = @_;
    my $self = {
        db => $args{db},
    };
    return bless $self, $class;
}

sub exec {
    my ($self, $tweet_id) = @_;

    my $tweet = $self->{db}->single('tweets', { id => $tweet_id });
    return unless ($tweet);

    my $user = $self->{db}->single('users', { id => $tweet->user_id });
    $tweet->delete();
    return unless ($user);

    my $tweets = $self->{db}->search('tweets', { user_id => $user->id });
    my $tweets_count = scalar(@{$tweets->all});
    # 紐づくツイートがなくなったらuserも削除する
    if ($tweets_count == 0) {
        $user->delete();
    }
}

1;

__END__


