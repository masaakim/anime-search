#!/usr/bin/perl
use strict;
use warnings;

use LWP::UserAgent;
use File::Path;

my $ua = LWP::UserAgent->new();

print "アニメ名検索： ";
chomp(my $name = <STDIN>);
print "何話？(入力なしで全話)： ";
chomp(my $num = <STDIN>);

(my $sec, my $min, my $hour, my $day, my $mon, my $year) = (localtime(time))[0..5];
$year += 1900;
$mon += 1;
my $now = "$year-$mon-$day-$hour-$min-$sec";
print "$now\n";

$name =~ s/ /+/g;
$name =~ s/　/+/g;

my $search_url = "http://www.anime44.com/anime/search?key=$name";
my $res = $ua->get("$search_url");
die "Response is error!" if $res->is_error;

my $anime_url;
while ($res->content =~ m!<h3><a href="(.*?)">!i) {
  $anime_url = $1;
  last; 
}

$anime_url =~ s/category\///;


if (!$num) {
  my $num = 1;
  my @anime;
  while (1) {
	$anime[$num] = $anime_url . "-episode-$num";

	my $res2 = $ua->get("$anime[$num]");
	if ($res2->is_error) {
	  last;
	}
	print "$anime[$num]\n";

	my $player_url;
	while ($res2->content =~ m!<div class="vmargin"><div><iframe src="(.*?)"!i) {
	  $player_url = $1;
	  print "$player_url\n";
	  last;
	}

	my $html = "<html><head><title>$anime[$num]</title><link href='/css/bootstrap.css' rel='stylesheet'></head><body><div class='container'><div class='player'><iframe src='$player_url' scrolling='no' width='718' height='438' marginheight='0' marginwidth='0' frameborder='0'></iframe></div></div></body></html>";

	
	my @dir_name = ("$name");
	my $dir = "$name";
	mkpath(@dir_name);

	open(OUT, ">./$name/$name-$num.html");
	print OUT $html;

	$num++;
  }

} else {
  $anime_url = $anime_url . "-episode-$num";
  print "$anime_url\n";

  my $res2 = $ua->get("$anime_url");
  my $player_url;
  while ($res2->content =~ m!<div class="vmargin"><div><iframe src="(.*?)"!i) {
	$player_url = $1;
	print "$player_url\n";
	last;
  }

	my $html = "<html><head><title>$anime_url</title><style type='text/css'>.container {margin-right: auto;margin-left: auto;*zoom: 1;}
</style><link href='/css/bootstrap.css' rel='stylesheet'></head><body><div class='container'><div class='player'><iframe src='$player_url' scrolling='no' width='718' height='438' marginheight='0' marginwidth='0' frameborder='0'></iframe></div></div></body></html>";
	
	

	open(OUT, ">$name-$num.html");
	print OUT $html;
}
