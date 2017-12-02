#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Novel::Robot::Packer;
use Encode;
use Encode::Locale;
use Data::Dumper;

our $CHARSET  = 'cp936';
our $BASE_URL = "http://m.jjwxc.net";

my ( $cookie, $novel_id ) = @ARGV;

get_jjwxc_vip( $cookie, $novel_id );

sub get_jjwxc_vip {
  my ( $cookie, $novel_id ) = @_;

  my $GET_LJJ_SUB = gen_get_url_sub( $cookie, 'jjwxc.net' );
  my $index_u     = "$BASE_URL/book2/$novel_id?more=0&whole=1";
  my $c           = $GET_LJJ_SUB->( $index_u );
  $c = decode( $CHARSET, $c );
  my ( $cc )          = $c =~ m#章节列表：<br/>.+?(<a.+?)<\/div>#s;
  my @f               = $cc =~ m#<a.+?href="(.+?/$novel_id/\d+).+?>(.+?)</a>#sg;
  my $max_chapter_num = ( $#f + 1 ) / 2;

  my ( $book, $writer ) = $c =~ m#<title>《(.+?)》(.+?)_#s;
  print encode( locale => "$writer, $book\n" );

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
    print encode( locale => "get chapter $i : $t " );

    my $c = $GET_LJJ_SUB->( $u );
    $c = decode( $CHARSET, $c );
    my ( $cc ) = $c =~ m#<h2[^>]+>.+?<li>(.+?)</li>#s;

    push @floor, { id => $i, title => $t, content => $cc };
  } ## end for my $i ( 1 .. $max_chapter_num)

  my $d = { writer => $writer, book => $book, floor_list => \@floor, floor_num => $max_chapter_num };
  my $packer = Novel::Robot::Packer->new( type => 'txt' );
  my $output = encode( locale => "$writer-$book.txt" );
  print $output, "\n";
  my $ret = $packer->main( $d, with_toc => 0, output => $output );
} ## end sub get_jjwxc_vip

#-------------

sub gen_get_url_sub {
  my ( $cookie, $dom ) = @_;

  my $head = init_head( $cookie, $dom );

  return sub {
    my ( $url, $fname ) = @_;

    print "URL: $url\n";
    my $cmd = qq[curl -L -s $head "$url"];
    $cmd .= qq[ -o "$fname"] if ( $fname );

    #print $cmd, "\n";
    my $c = `$cmd`;
    return $c;
    }
}

sub init_head {
  my ( $cookie, $dom ) = @_;

  $cookie = init_cookie( $cookie, $dom );

  my %head = (
    'User-Agent'      => 'Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0',
    'Accept'          => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language' => 'zh-CN,zh;q=0.8,zh-TW;q=0.6,en-US;q=0.4,en;q=0.2',
    'Connection'      => 'keep-alive',
    'Cookie'          => $cookie,
  );
  my $final_head = join( " ", map { qq[-H "$_: $head{$_}"] } keys( %head ) );
  return $final_head;
}

sub init_cookie {
  my ( $cookie, $dom ) = @_;

  if ( -f $cookie ) {                  #firefox sqlite3
    my $sqlite3_cookie = `sqlite3 "$cookie" "select * from moz_cookies where baseDomain='$dom'"`;
    my @segment = map { my @c = split /\|/; "$c[3]=$c[4]" } ( split /\n/, $sqlite3_cookie );
    $cookie = join( "; ", @segment );
  }

  return $cookie;
}
