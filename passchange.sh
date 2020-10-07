#! /usr/bin/perl -w -T

use Getopt::Long;
use strict;
use Net::OpenSSH;

my $host = 'server-IMAP';
my $user;
my $pw;
my $result;
my $cid;
my $oldpassword;
my $userid;

open(LOG, '>>/var/log/pw.log');

sub log_error {
       my $errorstring=$_[0];
       print LOG "Error: $errorstring\n";
       die "$errorstring";
}

# secure env
$ENV{'PATH'} = "";
$ENV{'ENV'} = "";

$result = GetOptions ("username" => \$user,
                     "cid" => \$cid,
                     "userid" => \$userid,
                     "oldpassword" => \$oldpassword,
                     "newpassword" => \$pw);

$user || &log_error("missing parameter username");
print LOG "changing password for user $user\n";
$pw || &log_error("missing parameter newpassword");


my $usersav = $user;

# add a taint check
if ($user =~ /^([-\@\w.]+)$/) {
 $user = $1;                     # $data now untainted
} else {
 &log_error("Bad data in '$user'");
}

die "Can't fork: $!" unless defined(my $pid = open(KID, "|-"));
if ($pid) {           # parent
 print KID $pw;
 close KID;
} else {

# Alterar senha serviço de e-mail
 my $ssh = Net::OpenSSH->new(host => "$host", user => "$user", password => "$oldpassword");

 my @pass =("$oldpassword\n", "$pw\n", "$pw\n");
           $ssh->system({stdin_data => \@pass}, "/usr/bin/passwd");

}

close(LOG);
