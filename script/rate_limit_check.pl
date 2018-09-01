use strict;
use warnings;
use utf8;

use Net::Twitter; 
use Data::Dumper;

my $nt = Net::Twitter->new(
    traits          => [ qw/AppAuth API::RESTv1_1/ ],
    consumer_key    => $ENV{TWITTER_CONSUMER_KEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_SECRET},
);
$nt->request_access_token;

my $results = $nt->rate_limit_status();

print Dumper $results;
