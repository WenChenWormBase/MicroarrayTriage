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
	    $PaperID{$paper} = $pmid;
	} 
}
print "$totalPaper WormBase papers found with medline accession number.\n"; 

print "Enter WormBase Paper ID file name:";
my $filename = <stdin>;

open (IN, "$filename") || die "can't open $!";
open (OUT, ">pmid_output.ace") || die "can't open $!"; 

while ($paper = <IN>) {
    next unless $paper ne "";
    chomp($paper);
    if ($PaperID{$paper}) {
	print OUT "\nPaper : \"$paper\"\n";
	print OUT "Database \"MEDLINE\" \"PMID\" \"$PaperID{$paper}\"\n";
    } else {
	print "No matching WormBase paper found for $paper\n";
    }    
}

close (IN);
close (OUT);


print "Thank you for using wbid2pmid.pl. Bye-bye!\n";

