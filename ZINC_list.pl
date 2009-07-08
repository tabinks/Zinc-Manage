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
#
# Example: 
#  awk '{print "perl ZINC_downloadAndFile.pl -id "$2" -zinc_library ../Zinc-Library/"}' Subsets/23_t70.smi
#
##############################################################

use File::Path;
use File::Basename;
use Getopt::Long;
use File::Spec;
use File::Compare;
use POSIX;

$USAGE="perl ZINC_list -library __path__ [-verbose]\n";
GetOptions(
    "library=s" => \$ALT_LIBRARY,
    "verbose!"  => \$VERBOSE,
    "force!"    => \$FORCE,
    "h!"        => \$HELP
    );
die($USAGE) if $HELP;
$ZINC_LIBRARY=($ALT_LIBRARY) ? $ALT_LIBRARY : "/home/abinkows/Zinc/Zinc-Library";

##############################################################
#
##############################################################
my $individualCount=0;
my %seen=();

foreach $dir1 (glob("$ZINC_LIBRARY/*")) {
    print "$dir1\n" if $VERBOSE;
    foreach $dir2 (glob("$dir1/*")) {
	print "$dir2\n" if $VERBOSE;
	foreach $dir3 (glob("$dir2/*")) {
	    print "$dir3\n"  if $VERBOSE;
	    $count=0;
	    foreach $file (glob("$dir3/*mol2")) {
		$fileName=basename($file);
		$count++;
		$seen{$fileName}++;
		print ++$individualCount." ".$seen{$fileName}." $file\n" if $VERBOSE;
	    }
	    $totalCount+=$count;
	}
    }
    printf(">>> $dir3:%6d Running Total: %10d\n",$count,$totalCount) if $VERBOSE;
}
print "Total total: $totalCount\n";

##############################################################
# Rsync Zinc-Library
##############################################################
my $destinationPath="/home/abinkows/Zinc/";
my $localPath="/Volumes/Alpha/Zinc/Zinc-Library";
my $arguments="-avz --delete";
print "rsync $arguments $localPath abinkows\@login6.surveyor.alcf.anl.gov:$destinationPath\n";
print "rsync $arguments $localPath abinkows\@login6.intrepid.alcf.anl.gov:$destinationPath\n";
