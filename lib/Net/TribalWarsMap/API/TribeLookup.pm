
use strict;
use warnings;

package Net::TribalWarsMap::API::TribeLookup;

# ABSTRACT: Query general information about tribes.

=head1 SYNOPSIS

    # Tag based lookup
    my $result = Net::TribalWarsMap::API::TribeLookup->get_tag('en69', 'kill');

    # Generic search
    my @results = Net::TribalWarsMap::API::TribeLookup->search_tribes('en69', 'Alex');

    # generic search with name filter
    my @results = Net::TribalWarsMap::API::TribeLookup->search_tribes('en69', 'lex',qr/^Alex/ );

    # Advanced
    my $instance = Net::TribalWarsMap::API::TribeLookup->new(
        world => 'en69',
        search => 'alex',
    );
    my $raw_results = $instance->_results;

=cut

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Net::TribalWarsMap::API::TribeLookup",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=cut

use Carp qw(croak);
use Moo;

=attr ua

=cut

has 'ua' => (
  is      => 'ro',
  lazy    => 1,
  builder => sub {
    require Net::TribalWarsMap::API::HTTP;
    return Net::TribalWarsMap::API::HTTP->new( cache_name => 'tribe_lookup_scraper' );
  }
);

=attr decoder

=cut

has 'decoder' => (
  is      => 'ro',
  lazy    => 1,
  builder => sub {
    require JSON;
    return JSON->new();
  },
);

=attr world

=cut

has 'world' => (
  is       => ro =>,
  required => 1,
);

=attr search

=cut

has search => (
  is       => ro =>,
  required => 1,
  isa      => sub {
    length( $_[0] ) >= 2 or croak "Tribe Lookups must have >2 characters";
  },
);

=p_attr _ts

=cut

has _ts => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    require DateTime;
    my $ds = DateTime->now();
    return $ds->month_0 . '-' . $ds->day . '-' . $ds->hour;
  },
);

=attr uri

=cut

has 'uri' => (
  is      => ro => lazy => 1,
  builder => sub {
    sprintf q[http://%s.tribalwarsmap.com/data.php?type=tribesearch&q=%s&ms=%s] => ( $_[0]->world, $_[0]->search, $_[0]->_ts );
  },
);

=p_attr _results

=cut

has _results => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    my $result = $_[0]->ua->get( $_[0]->uri );
    croak "failed to get data" if not $result->{success};
    return $_[0]->decoder->decode( $result->{content} )->{'tribedata'};
  },
);

=p_attr _decoded_results

=cut


has _decoded_results => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    my $dr = $_[0]->_results;
    require Net::TribalWarsMap::API::TribeLookup::Result;
    my $out = {};
    for my $tribe ( keys %{$dr} ) {
      $out->{$tribe} = Net::TribalWarsMap::API::TribeLookup::Result->from_data_line( $tribe, @{ $dr->{$tribe} } );
    }
    return $out;
  }
);

=method get_tag

    my $result = $class->get_tag( $world, $tag );

For example:

    my $result = $class->get_tag('en69', 'kill');

If C<$tag> is not found, C<undef> is returned.

=cut

sub get_tag {
  my ( $class, $world, $tag ) = @_;
  my $search = substr $tag, 0, 2;
  for my $tribe ( $class->search_tribes( $world, $search ) ) {
    return $tribe if $tribe->tag eq $tag;
  }
  return;
}

=method search_tribes

    my @results = $class->search_tribes( $world, $search_string );

or

    my @results = $class->search_tribes( $world, $search_string , $name_filter_regexp );


For instance:

      my @results = $class->search_tribes( 'en69', 'kill' );

will return all tribes in C<world en69> with the substring C<kill> in their tag or name.

      my @results = $class->search_tribes( 'en69', 'kill' , qr/bar/);

will return all tribes in C<world en69> with the substring C<kill> in their tag or name, where their name also matches

      $tribe->name =~ qr/bar/

=cut

sub search_tribes {
  my ( $class, $world, $search , $filter ) = @_;
  my $dr = $class->new( world => $world, search => $search );
  if ( not $filter ) {
      return values %{ $dr->_decoded_results };
  }
  return grep { $_->name =~ $filter } values %{ $dr->_decoded_results };
}



1;
