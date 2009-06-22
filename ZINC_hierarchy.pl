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
use Getopt::Long;

my $USAGE="$0 output_dir mol2_file_name";
my $DATE=`date +%Y%m%d`;chomp($DATE);
my $OUTDIR=$ARGV[0];
my $MOL2_FILE=$ARGV[1];

die("$OUTDIR doesn't exist") if !-e $OUTDIR;
die("$USAGE") if $#ARGV<1;

###################################################
# Creates a subdir of the same name
###################################################
my $count=0;
#$|=1;

###################################################
#
###################################################
open(MOL2_FILE,"<$MOL2_FILE");
while(<MOL2_FILE>){
    if($_=~/(ZINC\d+)/) {
	$id=$1;
	$returnString.="@<TRIPOS>MOLECULE\n";
	$flag=1;
    }
    if ($_=~/@<TRIPOS>MOLECULE/ && $flag==1) {
	$subdir=substr($id,4,2);
	$subsubdir=substr($id,6,2);
	$subsubsubdir=substr($id,8,2);
	mkpath("$OUTDIR/$subdir/$subsubdir/$subsubsubdir/");
	open(OUT,">$OUTDIR/$subdir/$subsubdir/$subsubsubdir/$id.mol2") 
	    or die("Couldn't open $OUTDIR/$subdir/$subsubdir/$subsubsubdir/$id.mol2");
	print OUT $returnString;
	close OUT;
	$flag=0;
	$returnString="";
	if (++$count%1000) {
	    print "$count ";
	}
    }
    if($flag==1) {
	$returnString.=$_;
    }
}
    
