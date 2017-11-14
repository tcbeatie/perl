#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

##
## Load libraries
##

use LWP::UserAgent;
use JSON;
use MIME::Base64;
use Mozilla::CA;

##
## Set globals
##

my $ACCESS_TOKEN = 'sandbox-sq0atb-swt_bEtcOXitim9Md_Ad2g';

##
## Initialize
##

my $JSON = JSON->new->allow_nonref();

my $userAgent = LWP::UserAgent->new();
$userAgent->default_header('Authorization' => "Bearer $ACCESS_TOKEN");
$userAgent->default_header('Accept'=> 'application/json');
$userAgent->default_header('Content-Type'=> 'application/json');
$userAgent->timeout(10);

my %dataOfInterest = (
    'locations' => ['name', 'status'],
    'customers' => ['email_address', 'note'],
    'catalog/list/objects' => ['type', 'id']
    );

##
## Main 
##

&main();

###
##### Main - for each type of data of interest, send GET request to appropriate URL, parse JSON response
###

sub main {
    foreach my $dType (keys %dataOfInterest) {

	my $endpoint = $dType =~ /(.*)\// ? $1 : $dType;
	my $response = $userAgent->get('https://connect.squareup.com/v2/'.$endpoint);

	if ($response->is_error) {
	    print "Skipping ".$dType." due to error: ".$response->status_line, "\n\n";

	} else {
	    my $rspScalar = $JSON->decode($response->content);
#	    print $JSON->pretty->encode($rspScalar);

	    print "Grabbing ".$dataOfInterest{$dType}." data from ".$dType."\n";
	    my $dataItems = &parseJSON($dType, $rspScalar, $dataOfInterest{$dType});
	    print "Found ".$dataItems." items of interest.\n\n";
	}
    }

    print "Done.\n";
}

###
##### parseJSON - takes data type, JSON scalar, and array of top level keys to return values for
###

sub parseJSON {
    my ($d_type, $rsp_scalar, $fields_ref) = @_;

    my $local_type = $d_type =~ /.*\/(.*)/ ? $1 : $d_type;
    my $index;
    for ($index=0; $index < @{@{$rsp_scalar}{$local_type}}; $index++) {

	foreach my $field (@{$fields_ref}) {

	    my $value = ${${$rsp_scalar}{$local_type}[$index]}{$field} || "(no value)";
	    print $field."\t(".$value.")\n";
	}

	print "\n";
    }

    return ($index);
}
