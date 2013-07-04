use strict;
use warnings;

package Net::TribalWarsMap::API::TribeLookup::Result;

# ABSTRACT: A single tribe search result

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Net::TribalWarsMap::API::TribeLookup::Result",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=cut

use Moo;

=attr C<id>

=cut

has 'id'           => ( is => ro =>, required => 1 );

=attr C<members>

=cut

has 'members'      => ( is => ro =>, required => 1 );

=attr C<name>

=cut

has 'name'         => ( is => ro =>, required => 1 );

=attr C<oda>

=cut

has 'oda'          => ( is => ro =>, required => 1 );

=attr C<oda_rank>

=cut

has 'oda_rank'     => ( is => ro =>, required => 1 );

=attr C<odd>

=cut

has 'odd'          => ( is => ro =>, required => 1 );

=attr C<odd_rank>

=cut

has 'odd_rank'     => ( is => ro =>, required => 1 );

=attr C<points>

=cut

has 'points'       => ( is => ro =>, required => 1 );

=attr C<rank>

=cut

has 'rank'         => ( is => ro =>, required => 1 );

=attr C<tag>

=cut

has 'tag'          => ( is => ro =>, required => 1 );

=attr C<total_points>

=cut

has 'total_points' => ( is => ro =>, required => 1 );

=p_method C<_field_names>

=cut

sub field_names {
  return qw( id  total_points members tag points rank oda odd oda_rank odd_rank name );
}

=method C<from_data_line>

Inflates a C<::Result> from a decoded list.

    my $instance = $class->from_data_line( $id , $total_points, ... );

B<Note:> Upstream have their data in the following form:

    {
        "$id": [ $total_points , ... ],
        "$id": [ $total_points , ... ],
    }

While this function takes:

          "$id", $total_points , ... 

=cut

sub from_data_line {
  my ( $self, @fields ) = @_;
  my (@names) = $self->field_names;
  my $hash = {};
  for my $idx ( 0 .. $#names ) {
    my $key   = $names[$idx];
    my $value = $fields[$idx];
    next if $key =~ /^\?/;
    $hash->{$key} = $value;
  }
  return $self->new($hash);
}

=method C<od_ratio>

=cut

sub od_ratio {
    my ( $self ) = @_; 
    return sprintf '%0.3f' , $self->oda / $self->odd
}

=method C<od_point_ratio>

=cut

sub od_point_ratio {
    my ( $self ) = @_; 
    return sprintf '%0.3f' , ( $self->oda + $self->odd ) / $self->points;
}

=method C<avg_od>

=cut

sub avg_od {
    my ( $self ) = @_ ; 
    return sprintf '%0.3f', ( $self->oda + $self->odd ) / $self->members;
}

=method C<avg_oda>

=cut

sub avg_oda {
    my ( $self, ) = @_;
    return sprintf '%0.3f',  $self->oda   / $self->members;

}

=method C<avg_odd>

=cut


sub avg_odd {
    my ( $self, ) = @_;
    return sprintf '%0.3f',  $self->odd   / $self->members;
}

=method C<avg_points>

=cut

sub avg_points {
    my ( $self ) = @_ ; 
    return sprintf '%0.3f', $self->points  / $self->members;
}

1;

