package Pickles::Plugin::FillInFormLite;
use strict;
use warnings;
use HTML::FillInForm::Lite;

my $fif = HTML::FillInForm::Lite->new;

sub install {
    my ($class, $pkg) = @_;

    $pkg->add_trigger(post_render => sub {
        my ($c) = @_;
        if ($c->req->method eq 'POST' || $c->stash->{fdat}) {
            if ($c->res->content_type =~ m{^text/x?html}) {
                my $body = $c->res->body;
                my $q = $c->stash->{fdat} || $c->req;
                my $result = $fif->fill(\$body, $q);
                $c->res->body($result);
            }
        }
    });
}

1;
