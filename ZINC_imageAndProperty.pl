#######################################################
# ZINC_webPrep.pl 2notebook.pl
#
# Author: T.A. Binkowski
# Date:   June 9, 2006
#
# perl ZINC_2notebook.pl smiles_list.smi out_directory
#  format is "smiles_string zincid"
#
#
# If you make a dir zinc8 locally you can rsync it to the 
# the bg/p and it will copy them correctly.
#
# rsync -av zinc8/ abinkows@surveyor.alcf.anl.gov:~/Data/zinc8/
#######################################################
#!/usr/bin/perl

use Getopt::Std;
use lib '/net/Xtbinkowski/lib/';
use Discovery::OpenEye;
use HTTP::Date;
use Discovery::Configure;
use Discovery::Zinc;
use File::Path;

my $SMILES_LIST=$ARGV[0];
my $OUTDIR=$ARGV[1];

die unless $OUTDIR && $SMILES_LIST;

################################################################
# Load in lookup table of zinc -> smiles
#
################################################################

open(SMILES,"<$SMILES_LIST");
while(<SMILES>) {
    chomp;
    ($smiles,$id) = split;
    $prettyZincId=$id;
    print STDERR "> $id - $smiles\n";
    
    # Create folder heirachy
    $subdir=substr($id,4,2);
    $subsubdir=substr($id,6,2);
    $subsubsubdir=substr($id,8,2);
    $IMAGEDIR="$OUTDIR/$subdir/$subsubdir/$subsubsubdir/";
    mkpath("$IMAGEDIR");

    ## Create images
    if(!-e "$IMAGEDIR/$id.gif") {
	Discovery::OpenEye::OpenEyeSmilesToImg($smiles,$prettyZincId,$IMAGEDIR);
      }

    # Create molecular properties xml
    if(!-e "$IMAGEDIR/$id.xml") {
	open(OUT,"> $IMAGEDIR/$id.xml");
	print OUT Discovery::OpenEye::OpenEyeSmilesToMolecularProperties($smiles,$prettyZincId,'ELEMENTAL');
	close OUT;
    }
}

## Clean up
`rm *.tmp`;
`rm filter.*`;


