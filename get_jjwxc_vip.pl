#!/usr/bin/perl
use strict;
use warnings;
use utf8;
$| = 1;

use Data::Dumper;
use Novel::Robot;

my ( $cookie, $novel_id ) = @ARGV;

get_jjwxc_vip( $cookie, $novel_id );

sub get_jjwxc_vip {
  my ( $cookie, $novel_id ) = @_;
  my $xs = Novel::Robot->new( site => 'jjwxc', type => 'txt' );

  my $ck = $xs->{browser}->read_moz_cookie( $cookie, 'jjwxc.net' );

  #print $ck, "\n";

  $xs->get_item( "http://www.jjwxc.net/onebook.php?novelid=$novel_id", verbose => 1, with_toc => 0 );
}
