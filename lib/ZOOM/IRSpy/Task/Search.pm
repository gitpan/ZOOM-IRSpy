# $Id: Search.pm,v 1.15 2007/05/01 16:30:42 mike Exp $

package ZOOM::IRSpy::Task::Search;

use 5.008;
use strict;
use warnings;

use ZOOM::IRSpy::Task;
our @ISA = qw(ZOOM::IRSpy::Task);

=head1 NAME

ZOOM::IRSpy::Task::Search - a searching task for IRSpy

=head1 SYNOPSIS

 ## to follow

=head1 DESCRIPTION

 ## to follow

=cut

sub new {
    my $class = shift();
    my $qtype = shift();
    my $qstr = shift();
    die "$class: unrecognised query type '$qtype'"
	if !grep { $qtype eq $_ } qw(pqf cql);

    my $this = $class->SUPER::new(@_);
    $this->{qtype} = $qtype;
    $this->{qstr} = $qstr;
    $this->{rs} = undef;
    return $this;
}

sub run {
    my $this = shift();

    $this->set_options();

    my $conn = $this->conn();
    $conn->connect($conn->option("host"));

    my $qtype = $this->{qtype};
    my $qstr = $this->{qstr};
    $this->irspy()->log("irspy_task", $conn->option("host"),
			" searching for '$qtype:$qstr'");
    die "task $this has resultset?!" if defined $this->{rs};

    my $query;
    if ($qtype eq "pqf") {
	$query = new ZOOM::Query::PQF($qstr);
    } elsif ($qtype eq "cql") {
	$query = new ZOOM::Query::CQL($qstr);
    } else {
	die "Huh?!";
    }

    ### Note well that when this task runs, it creates a result-set
    #	object which MUST BE DESTROYED in order to prevent large-scale
    #	memory leakage.  So when creating a Task::Search, it is the
    #	APPLICATION'S RESPONSIBILITY to ensure that the callback
    #	invoked on success OR FAILURE makes arrangements for the set
    #	to be destroyed.
    $this->{rs} = $conn->search($query);
    warn "no ZOOM-C level events queued by $this"
	if $conn->is_idle();

    $this->set_options();
}

# Unique to Task::Search, used only for logging
sub render_query {
    my $this = shift();
    return $this->{qtype} . ":" . $this->{qstr}    
}

sub render {
    my $this = shift();
    return ref($this) . "(" . $this->render_query() . ")";
}

use overload '""' => \&render;


=head1 SEE ALSO

ZOOM::IRSpy

=head1 AUTHOR

Mike Taylor, E<lt>mike@indexdata.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Index Data ApS.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;