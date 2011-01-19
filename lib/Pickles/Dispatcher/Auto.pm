package Pickles::Dispatcher::Auto;
use strict;
use warnings;
use parent qw/Pickles::Dispatcher/;
use String::CamelCase qw/camelize/;

our $VERSION = '0.01';

sub match {
    my $self = shift;
    my ($req) = @_;

    my $match = $self->SUPER::match(@_);

    if (exists $match->{controller} && exists $match->{action}) {
        return $match;
    }

    my $path_info = $req->path_info;
    $path_info =~ s{^/}{};

    my $is_index = $path_info =~ m{/$};

    my @parts = split "/", $path_info;
    my $action = $is_index ? "index" : pop @parts || "index";

    my ($controller, %args);
    if (@parts) {
        if ($is_index) {
            $controller = camelize shift @parts;
            $args{splat} = $parts[0] if @parts;
        }
        else {
            my @camelized_parts = map { camelize $_ } @parts;
            $controller = join "/", @camelized_parts;
        }
    }
    else {
        $controller = "Root";
    }

    $match = +{
        controller => $controller,
        action => $action,
    };
    for my $key( keys %{$match} ) {
        next if $key =~ m/^(controller|action)$/;
        $args{$key} = delete $match->{$key};
    }
    $match->{args} = \%args;

    return $match;
}

1;
__END__

=head1 NAME

Pickles::Dispatcher::Auto -

=head1 SYNOPSIS

  use Pickles::Dispatcher::Auto;

=head1 DESCRIPTION

Pickles::Dispatcher::Auto is

=head1 AUTHOR

hirafoo E<lt>hirafoo atmk cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
