#!/usr/bin/perl
###################################################
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
###################################################
use File::Path;
use Getopt::Long;
use File::Spec;
use POSIX;

#############################################################
# Set local variables
#############################################################
my $GIT_DESCRIBE = qx{ git describe };
my ( $RELEASE, $PATCH, $COMMIT ) = ( $GIT_DESCRIBE =~ /v([^-]+)-(\d+)-g(\w+)/ );
$RELEASE .= ".$PATCH" if $PATCH;
print $RELEASE;
die;
my $VERSION="0.1";
my $USER=$ENV{'USER'};
my $DATE=`date +%c`;chomp($DATE);
my $PWD=`pwd`;chomp($PWD);
my $CMD="$0 "; foreach(@ARGV){$CMD.="$_ "};
my $TEMPLATES_DIR = '/home/abinkows/bin/PetaDock/templates';
my $BIN_DIR = '/home/abinkows/bin/PetaDock/bin/';
 
#############################################################
# Command line arguments
#############################################################
GetOptions(
    "zinc_path=s" => \$ZINC_PATH,
    "grid=s"     => \$GRID_PREFIX,     
    "o!"         => \$OVERWRITE,
    "prefix=s"   => \$PREFIX,
    "nodes=s"    => \$NODES,
    "h!"         => \$HELP
    );

my $USAGE="falkonDock.pl -receptor rec_charged.mol2 -box rec_box.pdb -spheres selected_spheres.sph -grid grid -protien __protein__ -library __library__ -prefix __prefix__ -nodes __nodes__ [-mmgbsa] [-s]\n";
die("\n$USAGE\n") if $HELP;
die("\n$LIBRARY does not exist\n") if !-e $LIBRARY;
my $LIBRARY_PRETTY=basename($LIBRARY);
 
 
#############################################################
# Set a description string
#############################################################
my $USER  = `whoami`;chomp($USER);
my $DATE  = `date +%Y%m%d-%H:%m`;chomp($DATE);
my $SYSTEM = $ENV{'PS1'};$SYSTEM=~s/\\[a-z]|[:@\.>]//g;
my $DESCRIPTION = $PREFIX."_".$PROTEIN."_".basename($LIBRARY);
my $DESCRIPTION_LONG = "\"$USER $DATE | $SYSTEM $NODES | $PREFIX $PROTEIN ".basename($LIBRARY)."\"";
$DESCRIPTION_LONG=~s/ /__/g;
 
status("Begin falkonDock.pl");

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
    
