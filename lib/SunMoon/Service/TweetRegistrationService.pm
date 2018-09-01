# ツイートのハッシュを受け取ってDBに登録するサービス
package SunMoon::Service::TweetRegistrationService;

use strict;
use warnings;
use utf8;

use JSON::XS;

sub new {
    my ($class, %args) = @_;
    my $self = {
        db => $args{db},
    };
    return bless $self, $class;
}

sub exec {
    my ($self, $_value) = @_;
    my $value;
    if ($_value->{retweet_status}) {
        $value = $_value->{retweet_status};
    } elsif ($_value->{retweeted_status}) {
        $value = $_value->{retweeted_status};
    } else {
        $value = $_value;
    }

    # filter : hashtags if not exists
    my @dance_hashtags = grep { $_->{text} eq 'スーパーカップダンススタジアム' } @{$value->{entities}->{hashtags}};
    return undef unless (@dance_hashtags);
    my @high_school_hashtags = grep { $_->{text} =~ /.*高校$/ } @{$value->{entities}->{hashtags}};
    return undef unless (@high_school_hashtags);

    my $hashtag_text = $high_school_hashtags[0]->{text};
    my $high_school =  $self->{db}->single('high_schools', { name => $hashtag_text });
    unless ($high_school) {
        $high_school = $self->{db}->insert('high_schools', { name => $hashtag_text });
    }

    my $user_json_string = JSON::XS->new->utf8->encode($value->{user});
    my $user = $self->{db}->single('users', { id => $value->{user}->{id_str} });
    if ($user) {
        $user->update({
            screen_name => $value->{user}->{screen_name},
            name        => $value->{user}->{name},
            raw_object  => $user_json_string,
        });
    } else {
        $user = $self->{db}->insert('users', {
            id          => $value->{user}->{id_str},
            screen_name => $value->{user}->{screen_name},
            name        => $value->{user}->{name},
            raw_object  => $user_json_string,
        });
    }


    my $tweet_json_string = JSON::XS->new->utf8->encode($value);
    my $tweet = $self->{db}->single('tweets', { id => $value->{id_str} });
    if ($tweet) {
        $tweet->update({
            retweet_count  => $value->{retweet_count} || 0,
            quote_count    => $value->{quote_count} || 0,
            reply_count    => $value->{reply_count} || 0,
            favorite_count => $value->{favorite_count} || 0,
            raw_object     => $tweet_json_string,
            updated_at     => DateTime->now( time_zone => 'Asia/Tokyo' ),
        });
    } else {
        my $posted_at = $Net::Twitter::Role::API::RESTv1_1::DATETIME_PARSER->parse_datetime($value->{created_at});
        $tweet = $self->{db}->insert('tweets', {
            id             => $value->{id_str},
            user_id        => $user->id,
            text           => $value->{text},
            posted_at      => $posted_at,
            retweet_count  => $value->{retweet_count} || 0,
            quote_count    => $value->{quote_count} || 0,
            reply_count    => $value->{reply_count} || 0,
            favorite_count => $value->{favorite_count} || 0,
            high_school_id => $high_school->id,
            raw_object     => $tweet_json_string,
        });
    }
}

1;

__END__

