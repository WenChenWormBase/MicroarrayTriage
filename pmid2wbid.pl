#!/usr/bin/perl -w

use strict;
use Ace;

print "connecting to citace ...\n";
my $tace='/usr/local/bin/tace';
my $acedbpath='/home/citace/citace';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;
my $query="query find Paper Database = MEDLINE";
my @paperList=$db->find($query);

my %PaperID;
my $database;
my ($totalPaper, $pmid, $paper);
$totalPaper = @paperList;

foreach $paper (@paperList) {
        $database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $pmid=$paper->get('Database', 3);
	    $PaperID{$pmid} = $paper;
	} 
}
print "$totalPaper WormBase papers found with medline accession number.\n"; 

print "Enter PMID accession number (or type \"quit\" to exit):";
chomp($pmid=<stdin>);
while ($pmid ne "quit") {   
    if ($PaperID{$pmid}) {
	print "WormBase ID for PMID$pmid: $PaperID{$pmid}\n";
    } else {
	print "No matching WormBase paper found for PMID$pmid\n";
    }    
    print "Enter PMID accession number:";
    chomp($pmid=<stdin>);
}

print "Thank you for using pmid2wbid.pl. Bye-bye!\n";

