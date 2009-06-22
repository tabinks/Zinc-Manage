#!/usr/bin/perl
##############################################################
# ZINC_hierachy.pl
# 
# Author:      T.A. Binkowski
# Date:        See `git log`
#
# Description: Creates a heirachy of folders for
#              ZINC compound files; 1 per file
#
# Usage: perl organizeZinc.pl mol2_file_name
#        
# Notes: This is designed to be run once using the largest 
#        possible library (e.g. all-purchasable) because it
#        with overwrite duplicate files.  As long as they are
#        run once they will be incremented accrodingly.
##############################################################
use File::Path;
use File::Basename;
use Getopt::Long;
use File::Spec;
use File::Compare;
use POSIX;

$|=1;

#############################################################
# Command line arguments
#############################################################
my $DATE=`date +%Y%m%d`;chomp($DATE);
my $USAGE="\n\t".basename($0)." -zinc_library -mol2_file\n";
GetOptions(
    "zinc_library=s" => \$ZINC_LIBRARY,
    "mol2_file=s"    => \$MOL2_FILE,
    "h!"             => \$HELP
    );
die("\n$USAGE\n") if $HELP;
die("$ZINC_LIBRARY doesn't exist") if !-e $ZINC_LIBRARY;
die("$MOL2_FILE doesn't exist") if !-e $MOL2_FILE;

#############################################################
# Set a description string
#############################################################
my $count=0;

#############################################################
# The eof is used to make sure the last molecule and last
# line of the last molecule print
#
#############################################################
open(MOL2_FILE,"<$MOL2_FILE");
while(<MOL2_FILE>){
    if($_=~/(ZINC\d+)/) {
	$id=$1;
	$returnString.="@<TRIPOS>MOLECULE\n";
	$flag=1;
    }
    if (($_=~/@<TRIPOS>MOLECULE/ || eof) && $flag==1) {
	$subdir=substr($id,4,2);
	$subsubdir=substr($id,6,2);
	$subsubsubdir=substr($id,8,2);
	mkpath("$ZINC_LIBRARY/$subdir/$subsubdir/$subsubsubdir/");
	
	++$idHash{$id};
	
	$currentFile = "$ZINC_LIBRARY/$subdir/$subsubdir/$subsubsubdir/$id.".
	    $idHash{$id}.".mol2";
	open(OUT,">$currentFile") or die("Couldn't open $currentFile");
	print OUT $returnString;
	print OUT $_ if eof;
	close OUT;
	$flag=0;
	$returnString="";
	print $count." " if (++$count%1000==0);
    }
    
    if($flag==1) {
	$returnString.=$_;
    }
}
    
