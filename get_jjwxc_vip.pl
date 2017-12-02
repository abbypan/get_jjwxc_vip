#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Novel::Robot::Packer;
use Encode;
use Encode::Locale;
use Data::Dumper;
use Novel::Robot::Browser;

$| = 1;
our $CHARSET  = 'cp936';
our $BASE_URL = "http://m.jjwxc.net";

my ( $cookie, $novel_id ) = @ARGV;

get_jjwxc_vip( $cookie, $novel_id );

sub get_jjwxc_vip {
  my ( $cookie, $novel_id ) = @_;

  my $br = Novel::Robot::Browser->new();
  my $ck = $br->read_moz_cookie( $cookie, 'jjwxc.net' );
  print $ck, "\n";

  my $index_u         = "$BASE_URL/book2/$novel_id?more=0&whole=1";
  my $c               = $br->request_url( $index_u );
  my ( $cc )          = $c =~ m#章节列表：<br/>.+?(<a.+?)<\/div>#s;
  my @f               = $cc =~ m#<a.+?href="(.+?/$novel_id/\d+.*?)".+?>(.+?)</a>#sg;
  my $max_chapter_num = ( $#f + 1 ) / 2;

  my ( $book, $writer ) = $c =~ m#<title>《(.+?)》(.+?)_#s;
  print encode( locale => "$writer, $book, $max_chapter_num\n" );

  my @floor;
  for my $i ( 1 .. $max_chapter_num ) {
    my $j = 2 * $i - 1;
    my $t = $f[$j];
    $t =~ s/^\d+\.(&nbsp;)*//;
    $t =~ s/&nbsp/ /g;
    $t =~ s/^.+>//;
    $t =~ s/\s+/ /g;

    my $ui = 2 * $i - 2;
    my $u  = "$BASE_URL$f[$ui]";
    print encode( locale => "get chapter $i : $t, $u\n" );

    my $c = $br->request_url( $u );
    my ( $cc ) = $c =~ m#<h2[^>]+>.+?<li>(.+?)</li>#s;

    push @floor, { id => $i, title => $t, content => $cc };
  }

  my $d = { writer => $writer, book => $book, floor_list => \@floor, floor_num => $max_chapter_num };
  my $packer = Novel::Robot::Packer->new( type => 'txt' );
  my $output = encode( locale => "$writer-$book.txt" );
  print $output, "\n";
  my $ret = $packer->main( $d, with_toc => 0, output => $output );
} ## end sub get_jjwxc_vip
