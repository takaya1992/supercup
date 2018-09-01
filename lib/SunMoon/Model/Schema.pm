package SunMoon::Model::Schema;

use strict;
use warnings;
use utf8;

use DateTime::Format::MySQL;
use Teng::Schema::Declare;

table {
    name 'users';
    pk 'id';
    columns qw/
        id
        screen_name
        name
        raw_object
        created_at
        updated_at
    /;
    inflate created_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate created_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
    inflate updated_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate updated_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
};

table {
    name 'high_schools';
    pk 'id';
    columns qw/
        id
        name
        created_at
        updated_at
    /;
    inflate created_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate created_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
    inflate updated_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate updated_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
};

table {
    name 'tweets';
    pk 'id';
    columns qw/
        id
        user_id
        text
        posted_at
        retweet_count
        quote_count
        reply_count
        favorite_count
        high_school_id
        raw_object
        created_at
        updated_at
    /;
    inflate posted_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate posted_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
    inflate created_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate created_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
    inflate updated_at => sub { DateTime::Format::MySQL->parse_datetime(shift)->set_time_zone('UTC')->set_time_zone('Asia/Tokyo') };
    deflate updated_at => sub { DateTime::Format::MySQL->format_datetime(shift->set_time_zone('UTC')); };
};

1;

