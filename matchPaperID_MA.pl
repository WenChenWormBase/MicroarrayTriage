#!/usr/bin/perl -w

use strict;
use Ace;

#This script compare GSE_PMID.txt with citace, to get the corresponding table for Paper and GEO accession number.

my $line;
my @tmp;
my $tmp_length;
my %notCuratible;

#--------- Read ecPaperList_merged.csv -------------------
open (LIST, "/home/wen/LargeDataSets/ExprCluster/ExprClusterTriage/ExprClusterTriage.csv") || die "can't open ecPaperList_merged.csv!";                    
while ($line=<LIST>) {
    next unless ($line =~ /^WBPaper/);
    
    chomp ($line);
    @tmp = split /\t/, $line;
    $tmp_length = @tmp;
   
    if ($tmp[1] =~ /Positive but not curatible/){
     $notCuratible{$tmp[0]} = $tmp[1];
    }    
    next unless ($tmp_length == 5);
    if ($tmp[4] ne "") {
	$notCuratible{$tmp[0]} = $tmp[4];
    }
}
close (LIST);
#---------------------------------------------------

print "connecting to citace ...\n";
my $tace='/usr/local/bin/tace';
my $acedbpath='/home/citace/citace';
#my $acedbpath='/home/citace/cminus225';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;
my $query="query find Paper Database = MEDLINE";
my @paperList=$db->find($query);

my %PaperID;
my %PMID;
my %MAcurated;
my $database;
my @word;
my ($platform, $t, $gseNumber, $pmid, $paper);

foreach $paper (@paperList) {

        $database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $pmid=$paper->get('Database', 3);
	    $PaperID{$pmid} = $paper;
	    $PMID{$paper} = $pmid;
	} 
}
@paperList = ();

$query="query find Paper Microarray_experiment = *";
@paperList=$db->find($query);
foreach $paper (@paperList) {
	    $MAcurated{$paper} = 1;
}

open (IN1, "GSE_PMID.txt") || die "can't open $!";
#open (IN1, "test.txt") || die "can't open $!";
open (OUT, ">MAPaperGSETable.txt") || die "can't open $!"; 
open (NEW, ">NewMicroarrayPaperGEO.txt") || die "can't open $!"; 


while (<IN1>) {
    next unless (($_ =~ /PMID/)||($_ =~ /WBID/));
    @word  = split ('\s+', $_);
    $t = @word;
    if ($t != 5) {
	print "Error in line $_\n";
    } else {
	$gseNumber = $word[1];
	$platform = $word[4];
	if ($word[2] eq "PMID:") {
	    $pmid = $word[3];
	    if ($PaperID{$pmid}) {
		$paper = $PaperID{$pmid};
	    } else {
		$paper = "N.A."
	    }
	} else {
	    $paper = $word[3];
	    if ($PMID{$paper}) {
		$pmid = $PMID{$paper};
	    } else {
		$pmid = "N.A.";
	    }
	}
	if ($MAcurated{$paper}) {
	    print OUT "Curated\t$paper\t$pmid\t$platform\t$gseNumber\n"; 
	} elsif ($notCuratible{$paper}) {
	    print OUT "Not-Curatible\t$paper\t$pmid\t$platform\t$gseNumber\n";

	} else {	    
		print OUT "New\t$paper\t$pmid\t$platform\t$gseNumber\n";
		print NEW "$paper\n";
		print NEW "\/\/Yes.\n";
		print NEW "\/\/pmid$pmid\n";
		print NEW "\/\/$gseNumber\n";
		print NEW "\/\/$platform\n\n";
	} 
    }
}
close (IN1);
close (OUT);
close (NEW);



