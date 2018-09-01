package SunMoon::Model::Row::Tweet;

use strict;
use warnings;
use utf8;

use parent 'Teng::Row';

# has_one
sub user {
    my $self = shift;
    $self->{teng}->single('users', { id => $self->user_id });
}

# has_one
sub high_school {
    my $self = shift;
    $self->{teng}->single('high_schools', { id => $self->high_school_id });
}

1;

