package SunMoon::Model::HighSchoolRanking;

use strict;
use warnings;
use utf8;

use Data::Dumper;

sub new {
    my ($class, %args) = @_;
    my $self = {
        db => $args{db},
    };
    return bless $self, $class;
}

sub get {
    my ($self) = @_;
    my @results = $self->{db}->search_by_sql(q{
        SELECT 
            high_school_name,
            tweet_count,
            sum_retweet_count,
            tweet_count + sum_retweet_count AS total
        FROM (
            SELECT
                high_schools.name AS high_school_name,
                COUNT(1) AS tweet_count,
                SUM(tweets.retweet_count) AS sum_retweet_count
            FROM high_schools
            JOIN tweets ON high_schools.id = tweets.high_school_id
            GROUP BY high_schools.id
        ) t
        ORDER BY total DESC, high_school_name
    });

    my ($latest_total, $latest_rank) = (0, 0);
    my $length = scalar(@results);
    my @ranking;
    for (my $i = 0; $i < $length; $i++) {
        if ($latest_total != $results[$i]->total) {
            $latest_rank = $i + 1;
        }
        push(@ranking, {
                high_school_name  => $results[$i]->high_school_name,
                tweet_count       => $results[$i]->tweet_count,
                sum_retweet_count => $results[$i]->sum_retweet_count,
                total             => $results[$i]->total,
                rank              => $latest_rank,
            });
        $latest_total = $results[$i]->total;
    }
    return @ranking;
}

1;
