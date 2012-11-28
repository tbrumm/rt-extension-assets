use strict;
use warnings;

package RT::Assets;
use base 'RT::SearchBuilder';

=head1 NAME

RT::Assets - a collection of L<RT::Asset> objects

=head1 METHODS

Only additional methods or overridden behaviour beyond the L<RT::SearchBuilder>
(itself a L<DBIx::SearchBuilder>) class are documented below.

=head2 Limit

Defaults CASESENSITIVE to 0

=cut

sub Limit {
    my $self = shift;
    my %args = (
        CASESENSITIVE => 0,
        @_
    );
    $self->SUPER::Limit(%args);
}

=head2 LimitRoleMember

Takes a paramhash of C<Type> and C<PrincipalId> and limits the collection to
assets where the specified principal is a member of the specified role group.

=cut

sub LimitRoleMember {
    my $self = shift;
    my %args = (
        Type        => undef,
        PrincipalId => undef,
        @_,
    );

    for (qw(Type PrincipalId)) {
        return (0, "$_ is required")
            unless $args{$_};
    }

    my $groups = $self->Join(
        ALIAS1 => 'main',
        FIELD1 => 'id',
        TABLE2 => 'Groups',
        FIELD2 => 'Instance',
    );
    $self->Limit(
        ALIAS   => $groups,
        FIELD   => "Domain",
        VALUE   => "RT::Asset-Role",
    );
    $self->Limit(
        ALIAS   => $groups,
        FIELD   => "Type",
        VALUE   => $args{Type},
    );

    my $members = $self->Join(
        ALIAS1 => $groups,
        FIELD1 => 'id',
        TABLE2 => 'CachedGroupMembers',
        FIELD2 => 'GroupId',
    );
    $self->Limit(
        ALIAS   => $members,
        FIELD   => "Disabled",
        VALUE   => 0,
    );
    $self->Limit(
        ALIAS   => $members,
        FIELD   => "MemberId",
        VALUE   => $args{PrincipalId},
    );
    return;
}

=head1 INTERNAL METHODS

Public methods which encapsulate implementation details.  You shouldn't need to
call these in normal code.

=head2 AddRecord

Checks the L<RT::Asset> is readable before adding it to the results

=cut

sub AddRecord {
    my $self  = shift;
    my $asset = shift;
    return unless $asset->CurrentUserCanSee;
    $self->SUPER::AddRecord($asset, @_);
}

=cut

=head2 NewItem

Returns a new empty RT::Asset item

=cut

sub NewItem {
    my $self = shift;
    return RT::Asset->new( $self->CurrentUser );
}

=head1 PRIVATE METHODS

=head2 _Init

Sets default ordering by Name ascending.

=cut

sub _Init {
    my $self = shift;

    $self->{'with_disabled_column'} = 1;

    $self->OrderBy( FIELD => 'Name', ORDER => 'ASC' );
    return $self->SUPER::_Init( @_ );
}

sub Table { "RTxAssets" }

RT::Base->_ImportOverlays();

1;
