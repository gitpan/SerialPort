#! perl -w

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo5.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use SerialPort 0.08;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Carp;
use strict;

#
# user settable options
#
my $echo	= 1;	# echo characters back to serial port
my $cr_crlf	= 1;	# convert incoming \cM to \r\n (before echo)
my $cntrl_z	= 1;	# abort waitfor subroutine on \cZ

my $usage	= <<USAGE_END;

Usage: \$data = waitfor (Delay, Match1 [, Match2 ...]);
       die "timed out" unless (defined \$data);
       # Delay is in seconds.

USAGE_END
#
#
#
my $ob;
my $pass;

my $out= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
my $tick= "Simple Serial Terminal with waitfor and echo to STDOUT\r\n\r\n";
my $tock= "type CONTROL-Z on serial terminal to quit\r\n";
my $e="\r\n....Bye\r\n";

sub waitfor {
    croak "$usage" unless (@_ > 1);
    my $delay = shift;
    my @wanted = @_;
    my $rbuf = "";
    my $loc = "";
    my @loc_char;
    my $n_char;
    my $timeout=Win32::GetTickCount() + (1000 * $delay);
	# this count wraps every month or so

    for (;;) {
        if (($loc = $ob->input) ne "") {
	    @loc_char = split (//, $loc);
	    foreach $n_char (@loc_char) {
                $rbuf .= $n_char;
	        if ($cr_crlf) { $n_char =~ s/\cM/\r\n/; }
	        $ob->write($n_char) if ($echo);
	        print $n_char;
                return $rbuf if (scalar grep {$rbuf =~ /$_$/} @wanted);
	    }
	    return if ($cntrl_z && ($loc =~ /\cZ/));
        }
        return if ($ob->reset_error);
	return if (Win32::GetTickCount() > $timeout);
    }
}

# starts configuration created by test1.pl

my $file = "COM1";
my $cfgfile = $file."_test.cfg";

# =============== execution begins here =======================

# 2: Constructor

$ob = SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

# 3: Prints Prompts to Port and Main Screen

print $out, $tick, $tock;
$pass=$ob->write($out) if ($echo);
$pass=$ob->write($tick) if ($echo);
$pass=$ob->write($tock)  if ($echo && $cntrl_z);

$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

my $match1 = "YES";
my $match2 = "NO";
my $prompt = "Type $match1 or $match2 or <ENTER> exactly to continue\r\n";

$pass=$ob->write($prompt) if ($echo);

$out = waitfor (30, $match1, $match2, "\r");
print "\r\nAborted or Timed Out\r\n" unless (defined $out);

print $e;
$pass=$ob->write($e) if ($echo);
$pass=$ob->write("perl exiting\r\n") if ($echo);

sleep 1;

undef $ob;
