#! perl -w

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo6.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.08;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Carp;
use strict;

#
# user settable options (the "stty" collection)
#
my $RL_intr	= "\cC";	# char to abort readline subroutine
my $RL_quit	= "\c\\";	# char to abort perl

my $RL_eof	= "\cZ";	# end_of_file char (eol + $rbuf_last="")
my $RL_eol	= "\cJ";	# end_of_line char

				# $RL_erase and $RL_kill MUST be single char
my $RL_erase	= "\cH";	# delete one character from buffer (backspace)
my $RL_kill	= "\cU";	# clear line buffer

my $RL_bsdel	= "\cH \cH";	# written after $RL_erase
my $RL_clear	= "\r                                                                            \r";
    # written after $RL_kill

my $RL_echo	= 1;		# echo every character
my $RL_echoe	= 1;		# echo $RL_erase with $RL_bsdel
my $RL_echok	= 0;		# echo \n after $RL_kill
my $RL_echonl	= 1;		# echo \n 
my $RL_echoc	= 1;		# echo $RL_clear, $Prompt after $RL_kill
my $RL_istrip	= 0;		# strip input to 7-bits
my $RL_icrnl	= 1;		# map \r to \n on input
my $RL_ocrnl	= 0;		# map \r to \n on output
my $RL_igncr	= 0;		# ignore \r on input
my $RL_inlcr	= 0;		# map \n to \r on input
my $RL_onlcr	= 1;		# map \n to \r\n on output

my $RL_isig	= 1;		# enable $RL_quit and $RL_intr
my $RL_icanon	= 1;		# enable $RL_erase and $RL_kill
my $RL_min	= 0;		# min characters for ok return on timeout
				# 0 disables "min" function
#

my $usage	= <<USAGE_END;

Usage: \$data = sp_readline ([Delay, [Prompt] ]);
       die "timed out" unless (defined \$data);
       # optional Delay is in seconds.
       # optional Prompt requires Delay (or undef).

USAGE_END
#
my $tock	= <<TOCK_END;

\rTerminal CONTROL Keys Supported:\r
    C = abort sp_readline subroutine\r
    M = end of line\r
    Z = end of file (input)\r
    H = backspace\r
    U = clear buffer\r
\r
TOCK_END
#
#

my $ob;
my $pass;

my $out	= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
my $tick= "Simple Serial Terminal with readline and echo to STDOUT\r\n\r\n";
my $e="\r\n....Bye\r\n";

my $rbuf_last = "";

sub sp_readline {
    croak "$usage" if (@_ > 2);
    my $delay = undef;
    my $prompt = "";
    $delay = shift if (@_);
    $prompt = shift if (@_);
    my $loc = "";
    my @loc_char;
    my $n_char;
    my $pos;
    my $found = 0;
    my $timeout=Win32::GetTickCount() + (1000 * $delay);
	# this count wraps every month or so

    my $rbuf = $rbuf_last;
    $rbuf_last = "";
    $ob->write($prompt);

        # check first for "typeahead"
    if ($pos = index ($rbuf, $RL_eof) > -1) {
        $n_char = substr($rbuf, 0, ($pos + length($RL_eol)));
	$found++;
    }
    if ($pos = index ($rbuf, $RL_eol) > -1) {
	$rbuf_last = substr($rbuf, ($pos + length($RL_eol)));
        $n_char = substr($rbuf, 0, ($pos + length($RL_eol)));
	$found++;
    }
    if ($found) {
	if ($RL_icrnl) { $n_char =~ s/\r/\n/ogs; }
	## print $n_char;
	if ($RL_onlcr) { $n_char =~ s/\n/\r\n/ogs; }
	$ob->write($n_char) if ($RL_echo);
	return $n_char;
    }

    for (;;) {
        if (($loc = $ob->input) ne "") {
	    @loc_char = split (//, $loc);
	    while (defined ($n_char = shift @loc_char)) {
	        if ($RL_icrnl) { $n_char =~ s/\r/\n/o; }
		if ($n_char eq $RL_erase) {
		    $pos = chop $rbuf;
####		    print "\nbackspace deleted: $pos\n";
	            $ob->write($RL_bsdel) if ($RL_echo && $RL_echoe);
		}
		elsif ($n_char eq $RL_kill) {
		    $rbuf = "";
	            $ob->write("\r") if ($RL_echo && $RL_echok && $RL_onlcr);
	            $ob->write("\n") if ($RL_echo && $RL_echok);
	            $ob->write($RL_clear) if ($RL_echo && $RL_echoc);
	            $ob->write($prompt) if ($RL_echo && $RL_echoc);
		}
		else {
		    if ($RL_istrip) {
			$pos = ord $n_char;
			if ($pos > 127) { $n_char = chr($pos - 128); }
		    }
                    $rbuf .= $n_char;
	            print $n_char;
	            if ($RL_onlcr) { $n_char =~ s/\n/\r\n/os; }
	            $ob->write($n_char) if ($RL_echo);
                    return $rbuf if ($rbuf =~ /$RL_eof$/);
                    if ($rbuf =~ /$RL_eol$/s) {
			if (scalar @loc_char) {
		            $rbuf_last = join(//, @loc_char);
                        }
			return $rbuf;
		    }
		}
	    }
	    return if ($RL_isig && ($rbuf =~ /$RL_intr/));
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

$ob = Win32::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

# 3: Prints Prompts to Port and Main Screen

print $out, $tick;
$pass=$ob->write($out);
$pass=$ob->write($tick);
$pass=$ob->write($tock);


$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

$out = sp_readline (60, "YES:");
print "\r\nAborted or Timed Out\r\n" unless (defined $out);

$pass = length ($out);
print "length = $pass; out = $out __\n";

print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
