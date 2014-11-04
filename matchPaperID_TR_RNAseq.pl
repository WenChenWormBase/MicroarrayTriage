#!/usr/bin/perl -w

use strict;
use Ace;

#This script compare GSE_PMID.txt with citace, to get the corresponding table for Paper and GEO accession number.

print "connecting to ws ...\n";
my $tace='/usr/local/bin/tace';
my $acedbpath='/home/citace/WS/acedb';
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

	if ($paper->Describes_analysis) {
	    #$MAcurated{$pmid} = 1;
	    $MAcurated{$paper} = 1;
	    print "$paper $pmid\n";
	} else {
	    #$MAcurated{$pmid} = 0;
	    $MAcurated{$paper} = 0;
	}

}

open (IN1, "GSE_PMID_TilingArray_RNAseq.txt") || die "can't open $!";
#open (IN1, "test.txt") || die "can't open $!";
open (OUT, ">MAPaperGSETable_RNAseq.txt") || die "can't open $!"; 
open (NEW, ">NewRNAseqPaperGEO.txt") || die "can't open $!"; 


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



