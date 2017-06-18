#!/usr/bin/perl -w
# -*- coding: utf-8 -*- 

$wln1=shift;
$wln2=shift;
#$outn=shift;

($wl1)=split(' ',`wc -l $wln1`);
($wl2)=split(' ',`wc -l $wln2`);
$top=min($wl1,$wl2);
$cmd=sprintf('paste %s %s | head -%d ',$wln1, $wln2, $top);
print `$cmd`;
if ($wl1>$wl2) {
    open(F,$wln2);
    $w2=<F>;
    close(F);
    open(F,sprintf("tail -n +%d %s |",$top+1,$wln1));
    while (<F>) {
        chomp;
        print "$_\t$w2";
    }
}
sub min{
    ($_[0]<$_[1]) ? $_[0] : $_[1]
}

