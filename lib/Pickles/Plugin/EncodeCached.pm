package Pickles::Plugin::EncodeCached;
use strict;
use warnings;
use Encode qw/find_encoding/;

my $utf8 = find_encoding('utf-8');
my %encoding_map = (
    utf8 => $utf8,
);

sub install {
    my ($class, $pkg) = @_;
    $pkg->add_trigger(init => sub {
        my $c = shift;
        my $config = $c->config->{'Plugin::Encode'};
        my $ie = $config->{input_encoding} || $utf8;
        unless ($encoding_map{$ie}) {
            my $_ie = find_encoding($ie) or die "unknown encoding: $ie";
            $encoding_map{$ie} = $_ie;
            $ie = $_ie;
        }
        # params is-a Hash::MultiValue-
        for my $key (keys %{$c->req->parameters}) {
            my @values;
            for my $val ($c->req->parameters->get_all($key)) {
                push @values, $ie->decode($val);
            }
            $c->req->parameters->remove($key);
            $c->req->parameters->add($key => @values);
        }
    });
    $pkg->add_trigger(pre_finalize => sub {
        my ($c) = @_;
        if ($c->res->content_type =~ m{^text/}) {
            my $body = $c->res->body;
            my $config = $c->config->{'Plugin::Encode'};
            my $oe = $config->{output_encoding} || $utf8;
            unless ($encoding_map{$oe}) {
                my $_oe = find_encoding($oe) or die "unknown encoding: $oe";
                $encoding_map{$oe} = $_oe;
                $oe = $_oe;
            }
            $c->res->content_type($c->res->content_type. '; charset='. $oe->mime_name);
            $c->res->body($oe->encode($body));
        }
    });
}

1;
