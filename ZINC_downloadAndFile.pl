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

$|=1;

#############################################################
# Command line arguments
#############################################################
my $DATE=`date +%Y%m%d`;chomp($DATE);
my $USAGE="\n\t".basename($0)." -zinc_library /Volumes/Alpha/Zinc/Zinc-Library/ -id ZINC#######\n";

GetOptions(
    "zinc_library=s" => \$ZINC_LIBRARY,
    "id=s"           => \$ID,
    "list=s"         => \$LIST,
    "force!"         => \$FORCE,
    "h!"             => \$HELP
    );
die("\n$USAGE\n") if $HELP;
die("$ZINC_LIBRARY doesn't exist") if !-e $ZINC_LIBRARY;

print "ZINC MOLECULE: $ID\n";

#############################################################
# Set a description string
#############################################################
my $count=0;

#############################################################
# The eof is used to make sure the last molecule and last
# line of the last molecule print
#
#############################################################

#############################################################
# Set the path
#############################################################
$subdir=substr($ID,4,2);
$subsubdir=substr($ID,6,2);
$subsubsubdir=substr($ID,8,2);
$fullPath = "$ZINC_LIBRARY/$subdir/$subsubdir/$subsubsubdir/";
print "Path: $fullPath\n";

#############################################################
# Quick Test and Force
#############################################################
my @molecules = glob("$fullPath/$id*mol2");
if(scalar @molecules>0) {
    print "These molecules are already in library:\n";
    foreach (@molecules) {print "\t".$_."\n";}
    if($FORCE) {
	print "FORCE: removing all $id*mol2 files and replacing thme\n";
	`rm $fullPath/$id*mol2`;
    } else {
	exit 0;
    }
}

#############################################################
# Download both the level 0 (reference) and level 1 (usual)
# from the zinc servers
#############################################################
for $level (0..1) {
    print "Looking for level:$level\n";

    # Reset the counter variables
    @mol2_array=();
    $lineCount=0;
    $flag=0;
    %idHash={};

    # Download from ZINC
    $mol2_string = `curl --silent "http://zinc8.docking.org/fget2.pl?f=m&l=$level&z=$ID"`;
    @mol2_array = split(/\n/,$mol2_string);

    # Test if Zinc returned anything
    if (scalar @mol2_array==0) {
	print "Didn't find any level: $level.\n";
    } else {
	mkpath($fullPath);

	####
	# Create a unique file for each ZINC molecule
	####
	foreach(@mol2_array) {
	    $line="$_\n";
	    print "$lineCount - $line";
	    $finishLastMolecule = ($lineCount==$#mol2_array) ? 1 : 0;

	    # Find the first line
	    if($line=~/(ZINC\d+)/) {
		$id=$1;
		$returnString.="@<TRIPOS>MOLECULE\n";
		$flag=1;
	    }
	    if (($line=~/@<TRIPOS>MOLECULE/ || $finishLastMolecule) && $flag==1) {	
		++$idHash{$id};
		$currentFile = "$fullPath/$id.$level-".$idHash{$id}.".mol2";
		print "Writing: $currentFile\n";
		open(OUT,">$currentFile") or die("Couldn't open $currentFile");
		print OUT $returnString;
		print OUT $line if $finishLastMolecule;
		close OUT;
		$flag=0;
		$returnString="";
	    }
	    
	    if($flag==1) {
		$returnString.=$line;
	    }
	    $lineCount++;
	}
    }
}
