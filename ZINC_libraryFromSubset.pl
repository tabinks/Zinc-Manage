#!/usr/bin/perl
#################################################################
# ZINC_libraryFromSubset.pl
# 
# Description: File should be in format: smiles id\n
#################################################################
use File::Path;
use File::Basename;
use File::Spec;

use Getopt::Long;

my %options=();

GetOptions("subset=s"  => \$SUBSET,
	   "prefix=s"   => \$PREFIX,
	   "h!"         => \$HELP,
	   "library=s" =>\$ALT_LIBRARY,
	   "verbose!"  =>\$VERBOSE,
	   "usual_only!" => \$USUAL_ONLY);

my $USAGE = $0." -subset Subsets/23_t60.20090707.smi -prefix 23_t60 -library /Volumes/Alpha/Zinc/Zinc-Library/\n";

my $SYSTEM = $ENV{'PS1'};
$SYSTEM=~s/\\[a-z]|[:@\.>]//g;
$SYSTEM=~s/\s+//g;
my $USER  = `whoami`;chomp($USER);
my $DATE  = `date +%Y%m%d`;chomp($DATE);
#my $DESCRIPTION = $PREFIX."_".$PROTEIN."_".basename($LIBRARY);

$ZINC_LIBRARY = ($ALT_LIBRARY) ? $ALT_LIBRARY : "/home/abinkows/Zinc/Zinc-Library/";
die("ZINC_LIBRARY not found") if !-e $ZINC_LIBRARY;

################################################################
#if($SYSTEM eq "surveyor") {

my $DB_PATH = $PREFIX.".$DATE.db";
my $MISSING_PATH = $PREFIX.".$DATE.missing";
$ZINC_LIBRARY = File::Spec->rel2abs($ZINC_LIBRARY);

open(OUT,">$DB_PATH") or die("Couldn't open $DB_PATH");
#open(MISSING,">$MISSING_PATH") or die("Couldn't open $MISSING_PATH");

open(SUBSET,"<$SUBSET") or die("Couldn't open $SUBSET");
while(<SUBSET>) {
    chomp();
    ($smiles,$id)=split;
    $subdir=substr($id,4,2);
    $subsubdir=substr($id,6,2);
    $subsubsubdir=substr($id,8,2);
    print "$id $smiles\n" if $VERBOSE;
    
    foreach(glob("$ZINC_LIBRARY/$subdir/$subsubdir/$subsubsubdir/$id.*-*.mol2")) {
	$_=~/$id.(\d)\-(\d).mol2/;
	$level=$1;
	$count=$2;
	next if $USUAL_ONLY && $level==0;
	#print "$level $count - $_\n";;
	#if (-e $_) {
	print OUT "$_ $smiles\n";
	#} else {
	#    print MISSING "$_ $smiles\n";
	#}
    }
    print "." if ($count++%100==0);
}

close SUBSET;
#close MISSING;
close OUT;
