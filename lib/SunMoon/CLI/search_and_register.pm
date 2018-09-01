package SunMoon::CLI::search_and_register;

use strict;
use warnings;
use utf8;

use Mojo::Base qw/Mojolicious::Command/;
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Math::BigInt;
use Data::Dumper;

use SunMoon::Service::TweetRegistrationService;
use SunMoon::Service::TweetRemoveService;

use constant {
    SEARCH_QUERY => '#スーパーカップダンススタジアム lang:ja',
};

# コマンド一覧に表示される解説
has description => "ツイートを検索し、DBに登録します。\n";

# ヘルプメッセージ
has usage => <<EOF;
usage: $0 

These options are available:
  -f --force DB上の最大ツイートIDを無視して取れるだけ取ってきます。
  --dry-run DBへの登録は行いません。
  -v --verbose Dumpします。
EOF

sub run {
    my ($self, @args) = @_;

    GetOptionsFromArray(\@args, 'f|force' => \(my $force), 'dry-run' =>  \(my $dry_run), 'v|verbose' => \(my $verbose))
        or die $self->usage;

    my $registration_service = SunMoon::Service::TweetRegistrationService->new(db => $self->app->db);

    my @tweets;
    if ($force) {
        @tweets = $self->_search_all();
    } else {
        @tweets = $self->_search();
    }

    print "count: " . scalar(@tweets) . "\n";
    for (@tweets) {
        print $_->{id_str} . "\n";
        unless ($dry_run) {
            $registration_service->exec($_);
        }
    }
}

sub _search_all {
    my ($self, $nt) = @_;

    my $min_id_str;
    my @tweets;

    for (my $i = 0; $i < 100; $i++) {
        my $results = $self->app->twitter->search({
            q => SEARCH_QUERY,
            count => 100,
            $min_id_str ? (max_id => Math::BigInt->new($min_id_str)->bsub(1)->bstr()) : (),
        });
        my @statuses = @{$results->{statuses}};
        last if (scalar(@statuses) == 0);
        $min_id_str = $statuses[$#statuses]->{id_str};
        push(@tweets, @statuses);
    }

    return @tweets;
}

sub _search {
    my ($self, $nt) = @_;

    my $latest_tweet = $self->app->db->single_by_sql(q{SELECT MAX(id) AS id FROM tweets});
    print "MAX ID: " . $latest_tweet->id . "\n";

    my $results = $self->app->twitter->search({
        q => SEARCH_QUERY,
        count => 100,
        $latest_tweet ? (since_id => $latest_tweet->id) : (),
    });
    return @{$results->{statuses}};
}


1;

__END__

