#!/usr/bin/perl -w
#Serge Sharoff, University of Leeds, 
#This script compares the results of dictionary prediction to a gold standard.


binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");
my %wl;

my $kf=shift;
open(LIST,"<:utf8",$kf) or die "Cannot open the keys file $kf: $!";
while (<LIST>) {
    chomp;
    if (/(.+)\t(.+)/) {
	$wl{$1}=$2;
    }
}

my $count=1;
my $tp=0;
while (<STDIN>) {
    s/"//g; # in case the strings are surrounded by '"'
    my @s=split(/\s+/,$_);
    my $tw=$wl{$s[0]}; #target translation
    next unless $tw;
    my $out="\t$s[0]\t$tw\t";
    my $i=$#s;
    while (($i>0) and ($tw ne $s[$i])) { #from the end of @s
	$i--;
    }
    if ($i>0) { # found a translation
	print STDOUT $#s-$i+1,$out,"\t$s[$i]\n";
    } else {
	print STDOUT 0,$out,"$s[-1]\n";
    };
    $count++;
    $tp++ if $i==$#s;
}
printf STDERR "%.3f\n",$tp/$count;
