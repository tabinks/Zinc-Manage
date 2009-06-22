#!/usr/bin/perl
###################################################
#
# Description: Creates a heirachy of folders for
#              ZINC compound files; 1 per file
#
# Usage: perl organizeZinc.pl mol2_file_name
#        
###################################################
use File::Path;

my $DATE=`date +%Y%m%d`;chomp($DATE);
my $file=$ARGV[0];
my $count=1;
$|=1;

###################################################
# Creates a subdir of the same name
###################################################
my $dir=substr($file,0,length($file)-5);
$dir.=".$DATE";
die("$dir exists") if -e $dir;
mkpath("$dir");

###################################################
#
###################################################
open(FILE,"<$file");
while(<FILE>){
    if($_=~/(ZINC\d+)/) {
	$id=$1;
	$returnString.="@<TRIPOS>MOLECULE\n";
	$flag=1;
    }
    if ($_=~/@<TRIPOS>MOLECULE/ && $flag==1) {
	$subdir=substr($id,4,2);
	$subsubdir=substr($id,6,2);
	$subsubsubdir=substr($id,8,2);
	mkpath("$dir/$subdir/$subsubdir/$subsubsubdir/");
	open(OUT,">$dir/$subdir/$subsubdir/$subsubsubdir/$id.mol2") 
	    or die("Couldn't open $dir/$subdir/$subsubdir/$subsubsubdir/$id.mol2");
	print OUT $returnString;
	close OUT;
	$flag=0;
	$returnString="";
	print $count++." " if $count%100;
    }
    if($flag==1) {
	$returnString.=$_;
    }
}
    
