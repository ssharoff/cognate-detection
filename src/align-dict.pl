#!/usr/bin/perl -w
#Serge Sharoff, University of Leeds, 
#This script collects 
use strict;
use Getopt::Long;

sub openwe {
    my $wef=shift;
    my $opentool=($wef=~/\.gz$/) ? 'zcat' :
	($wef=~/\.xz?$/) ? 'xzcat' : 'cat';
    open(my $fh,"$opentool $wef|") or die "error in opening $opentool $wef: $!\n";
    binmode($fh,":utf8");
    return $fh;
}

binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");

my $fn1;
my $fn2;
my $dn;

GetOptions (
	    "1=s" => \$fn1,
	    "2=s" => \$fn2,
	    "dict=s" => \$dn,
	    );
die "Usage: $0 
-1 file1
-2 file2
-d --dict Dictionary mapping
\n" unless $dn;

my %d1;
my %d2;
my $dh=openwe($dn);
my $i=0;
while (<$dh>) {
    chomp;
    if (/^(.+)\t(.+)/) {
	$d1{$1}=$2;
	$d2{$2}=$1;
	$i++
    }
}
close($dh);
print STDERR "Collected $i dict entries\n";

my %w1;
my %w2;
my $fh=openwe($fn1);
while (<$fh>) {
    if (my $i=index($_,' ')) {
	my $w = substr($_,0,$i);
	$w1{$w} = $_ if exists $d1{$w};
    }
}
close($fh);
printf STDERR "Collected %d embeddings from %s\n", scalar(keys %w1), $fn1;

$fh=openwe($fn2);
while (<$fh>) {
    if (my $i=index($_,' ')) {
	my $w = substr($_,0,$i);
	$w2{$w} = $_ if exists $d2{$w};
    }
}
close($fh);
printf STDERR "Collected %d embeddings from %s\n", scalar(keys %w2), $fn2;

$fn1=~s/.[gx]z$//;
$fn2=~s/.[gx]z$//;
open(OUT1,">$dn.$fn1");
binmode(OUT1,":utf8");
open(OUT2,">$dn.$fn2");
binmode(OUT2,":utf8");
foreach (sort keys %w1) {
    if (exists $w2{$d1{$_}}) {
	print OUT1 $w1{$_};
	print OUT2 $w2{$d1{$_}};
	delete $w2{$d1{$_}}  # to ensure we have unique translations only
    }
}
