use strict;
use warnings;
use utf8;

use Math::BigInt;
use Net::Twitter; 
use JSON::XS;
use Data::Dumper;
use Encode qw/encode_utf8/;
use DateTime::Format::Strptime;

use constant {
    SEARCH_QUERY => '#スーパーカップダンススタジアム lang:ja exclude:retweets',
};

sub p { print encode_utf8(shift); }
sub pp { p(shift . "\n"); }

my $nt = Net::Twitter->new(
    traits          => [ qw/AppAuth API::RESTv1_1/ ],
    consumer_key    => $ENV{TWITTER_CONSUMER_KEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_SECRET},
);
$nt->request_access_token;

my $datetime_parser = DateTime::Format::Strptime->new(pattern => '%a %b %d %T %z %Y');
my $min_id_str;
my @tweets;
my $i = 0;

while ($i <= 100) {
    $i++;
    my $query = {
        q => SEARCH_QUERY,
        count => 100,
        $min_id_str ? (max_id => Math::BigInt->new($min_id_str)->bsub(1)->bstr()) : (),
    };
    print "count: " . $i . "\n";
    print "query: \n";
    print Dumper $query;
    my $results = $nt->search({
        q => SEARCH_QUERY,
        count => 100,
        $min_id_str ? (max_id => Math::BigInt->new($min_id_str)->bsub(1)->bstr()) : (),
    });
    my @statuses = @{$results->{statuses}};
    print "statuses: " . scalar(@statuses) . "\n";
    last if (scalar(@statuses) == 0);
    $min_id_str = $statuses[$#statuses]->{id_str};
    push(@tweets, @statuses);
}


for (@tweets) {
    pp $_->{id_str};
    # pp $_->{user}->{name} . "(@" .$_->{user}->{screen_name}  . ")";
    # pp $_->{text};
    # pp $_->{created_at};
    # pp "";
}
print scalar(@tweets);

