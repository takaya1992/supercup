package SunMoon::Model::Row::User;

use strict;
use warnings;
use utf8;

use parent 'Teng::Row';

# has_many
sub tweets {
    my $self = shift;
    $self->{teng}->search('tweets', { user_id => $self->id });
}

1;
