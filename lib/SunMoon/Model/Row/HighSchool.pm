package SunMoon::Model::Row::HighSchool;

use strict;
use warnings;
use utf8;

use parent 'Teng::Row';

# has_many
sub tweets {
    my $self = shift;
    $self->{teng}->search('tweets', { high_school_id => $self->id });
}

1;

