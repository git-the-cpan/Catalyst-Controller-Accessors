package Catalyst::Controller::Accessors;
{
  $Catalyst::Controller::Accessors::VERSION = '0.002000';
}

use strict;
use warnings;

# ABSTRACT: Accessors for a namespaced stash

use Carp 'croak';

Moose::Exporter->setup_import_methods(
  with_meta => [ 'cat_has' ],
);

sub cat_has {
  my ( $meta, $name, %options ) = @_;

  my $is        = $options{is} || '';
  my $namespace = $options{namespace} || $meta->name;
  my $slot      = $options{slot} || $name;

  my $sub;
  if ($is eq 'ro') {
    $sub = sub { $_[1]->stash->{$namespace}{$slot} };
  } elsif ($is eq 'rw') {
    $sub = sub {
      if (exists $_[2]) {
        $_[1]->stash->{$namespace}{$slot} = $_[2]
      } else {
        return $_[1]->stash->{$namespace}{$slot}
      }
    }
  } else {
    croak 'cat_has requires "is" to be "ro" or "rw"'
  }

  $meta->add_method( $name, $sub );
}

1;


__END__
=pod

=head1 NAME

Catalyst::Controller::Accessors - Accessors for a namespaced stash

=head1 VERSION

version 0.002000

=head1 SYNOPSIS

 package MyApp::Controller::Users::Roles;

 use Moose;
 use Catalyst::Controller::Accessors;

 use namespace::autoclean;

 BEGIN { extends 'Catalyst::Controller' };

 cat_has user => (
   is => 'ro',
   namespace => 'MyApp::Controller::Users',
 );

 cat_has $_ => ( is => 'rw' ) for qw(resultset thing);

 # slot lets us use a different underlying field
 cat_has other_user => (
   is => 'ro',
   namespace => 'MyApp::Controller::Users',
   slot => 'user',
 );

 sub load_rs {
   my ($self, $c) = @_;

   $self->resultset($c,
      $self->user($c)->roles
   );
 }

 sub load_thing {
   my ($self, $c, $id) = @_;

   $self->thing($c,
      $self->resultset($c)->find($id)
   );
 }

 sub get_user {
   my ($self, $c) = @_;

   $c->response->body($self->thing($c)->name);
 }

=head1 DESCRIPTION

The overall idea for this module is to allow more sensible access to the stash.
It merely namespaces the stash based on the name of the controller adding the
accessor or the specified namespace.  It's prime purpose is for chaining.

=head1 IMPORTED SUBROUTINES

=head2 cat_has

Options:

=over 1

=item * C<is> - B<required>, must be either C<ro> or C<rw>

=item * C<namespace> - defaults to current controller

=item * C<slot> - defaults to accessor name

=back

=head1 AUTHOR

Arthur Axel "fREW" Schmidt <frioux+cpan@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Arthur Axel "fREW" Schmidt.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

