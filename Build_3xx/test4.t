#! perl -w

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test?.t'
# `perl test?.t time' pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..205\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.10;		# check inheritance & export
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# tests start using file created by test1.pl

use strict;
use Win32;

my $file = "COM1";
my $cfgfile = "../".$file."_test.cfg";

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[1-5]$/) {
	die "Usage: perl test?.t [ page_delay (1..5) ]";
    }
}

my $fault = 0;
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $blk;
my $err;
my $e;
my $tick;
my $tock;
my @necessary_param = SerialPort->set_test_mode_active;

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

sub is_zero {
    my $result = shift;
    if (defined $result) {
        return is_ok ($result == 0);
    }
    else {
        printf ("not ok %d\n",$tc++);
    }
}

sub is_bad {
    my $result = shift;
    printf (($result ? "not " : "")."ok %d\n",$tc++);
    return (not $result);
}

# 2: Constructor

unless (is_ok ($ob = SerialPort->start ($cfgfile))) {
    printf "could not open port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 3 - 24: Check Port Capabilities Match Save

is_ok ($ob->is_xon_char == 0x11);		# 3

is_ok ($ob->is_xoff_char == 0x13);		# 4

is_ok ($ob->is_eof_char == 0);			# 5

is_ok ($ob->is_event_char == 0);		# 6

is_ok ($ob->is_error_char == 0);		# 7

is_ok ($ob->is_baudrate == 9600);		# 8

is_ok ($ob->is_parity eq "none");		# 9

is_ok ($ob->is_databits == 8);			# 10

is_ok ($ob->is_stopbits == 1);			# 11

is_ok ($ob->is_handshake eq "none");		# 12

is_ok ($ob->is_read_interval == 0xffffffff);	# 13

is_ok ($ob->is_read_const_time == 0);		# 14

is_ok ($ob->is_read_char_time == 0);		# 15

is_ok ($ob->is_write_const_time == 200);	# 16

is_ok ($ob->is_write_char_time == 10);		# 17

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 18
is_ok (4096 == $out);				# 19

is_ok ($ob->alias eq "AltPort");		# 20

is_ok ($ob->is_binary == 1);			# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero (scalar $ob->is_parity_enable);		# 22

is_ok ($ob->is_xoff_limit == 200);		# 23

is_ok ($ob->is_xon_limit == 100);		# 24

is_ok ($ob->user_msg == 1);			# 25

is_ok ($ob->error_msg == 1);			# 26


print "Change all the parameters\n";

#### 27 - 49: Modify All Port Capabilities

is_ok ($ob->is_xon_char(1) == 0x01);		# 27

is_ok ($ob->is_xoff_char(2) == 0x02);		# 28

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char(4) == 0x04);	# 29

    is_ok ($ob->is_event_char(3) == 0x03);	# 30

    is_ok ($ob->is_error_char(5) == 5);		# 31
}
else {
    is_ok ($ob->is_eof_char(4) == 0);		# 29

    is_ok ($ob->is_event_char(3) == 0);		# 30

    is_ok ($ob->is_error_char(5) == 0);		# 31
}

is_ok ($ob->is_baudrate(1200) == 1200);		# 32

is_ok ($ob->is_parity("odd") eq "odd");		# 33

is_ok ($ob->is_databits(7) == 7);		# 34

is_ok ($ob->is_stopbits(2) == 2);		# 35

is_ok ($ob->is_handshake("xoff") eq "xoff");	# 36

is_ok ($ob->is_read_interval(0) == 0x0);	# 37

is_ok ($ob->is_read_const_time(1000) == 1000);	# 38

is_ok ($ob->is_read_char_time(50) == 50);	# 39

is_ok ($ob->is_write_const_time(2000) == 2000);	# 40

is_ok ($ob->is_write_char_time(75) == 75);	# 41

($in, $out)= $ob->buffers(8092, 1024);
is_ok (8092 == $ob->is_read_buf);		# 42
is_ok (1024 == $ob->is_write_buf);		# 43

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->alias("oddPort") eq "oddPort");	# 44

is_ok (scalar $ob->is_parity_enable(1));	# 45

is_ok ($ob->is_xoff_limit(45) == 45);		# 46

is_ok ($ob->is_xon_limit(90) == 90);		# 47

is_zero ($ob->user_msg(0));			# 48

is_zero ($ob->error_msg(0));			# 49


#### 50 - 72: Check Port Capabilities Match Changes

is_ok ($ob->is_xon_char == 0x01);		# 50

is_ok ($ob->is_xoff_char == 0x02);		# 51

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char == 0x04);		# 52

    is_ok ($ob->is_event_char == 0x03);		# 53

    is_ok ($ob->is_error_char == 5);		# 54
}
else {
    is_ok ($ob->is_eof_char == 0);		# 52

    is_ok ($ob->is_event_char == 0);		# 53

    is_ok ($ob->is_error_char == 0);		# 54
}

is_ok ($ob->is_baudrate == 1200);		# 55

is_ok ($ob->is_parity eq "odd");		# 56

is_ok ($ob->is_databits == 7);			# 57

is_ok ($ob->is_stopbits == 2);			# 58

is_ok ($ob->is_handshake eq "xoff");		# 59

is_ok ($ob->is_read_interval == 0x0);		# 60

is_ok ($ob->is_read_const_time == 1000);	# 61

is_ok ($ob->is_read_char_time == 50);		# 62

is_ok ($ob->is_write_const_time == 2000);	# 63

is_ok ($ob->is_write_char_time == 75);		# 64

($in, $out)= $ob->are_buffers;
is_ok (8092 == $in);				# 65
is_ok (1024 == $out);				# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->alias eq "oddPort");		# 67

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable);	# 68
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 68
}

is_ok ($ob->is_xoff_limit == 45);		# 69

is_ok ($ob->is_xon_limit == 90);		# 70

is_zero ($ob->user_msg);			# 71

is_zero ($ob->error_msg);			# 72

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 73

#### 74 - 97: Check Port Capabilities Match Original

is_ok ($ob->is_xon_char == 0x11);		# 74

is_ok ($ob->is_xoff_char == 0x13);		# 75

is_ok ($ob->is_eof_char == 0);			# 76

is_ok ($ob->is_event_char == 0);		# 77

is_ok ($ob->is_error_char == 0);		# 78

is_ok ($ob->is_baudrate == 9600);		# 79

is_ok ($ob->is_parity eq "none");		# 80

is_ok ($ob->is_databits == 8);			# 81

is_ok ($ob->is_stopbits == 1);			# 82

is_ok ($ob->is_handshake eq "none");		# 83

is_ok ($ob->is_read_interval == 0xffffffff);	# 84

is_ok ($ob->is_read_const_time == 0);		# 85

is_ok ($ob->is_read_char_time == 0);		# 86

is_ok ($ob->is_write_const_time == 200);	# 87

is_ok ($ob->is_write_char_time == 10);		# 88

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 89
is_ok (4096 == $out);				# 90

is_ok ($ob->alias eq "AltPort");		# 91

is_ok ($ob->is_binary == 1);			# 92

is_zero (scalar $ob->is_parity_enable);		# 93

is_ok ($ob->is_xoff_limit == 200);		# 94

is_ok ($ob->is_xon_limit == 100);		# 95

is_ok ($ob->user_msg == 1);			# 96

is_ok ($ob->error_msg == 1);			# 97


## 98 - 108: Status

is_ok (4 == scalar (@opts = $ob->is_status));	# 98

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 99
is_zero ($in);					# 100
is_zero ($out);					# 101
is_zero ($blk);					# 102
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 103

($blk, $in, $out, $err)=$ob->is_status(0x150);	# test only
is_ok ($err == 0x150);				# 104
### printf "error: err=%lx\n", $err;

($blk, $in, $out, $err)=$ob->is_status(0x0f);	# test only
is_ok ($err == 0x15f);				# 105

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "    Force all Status Errors\n";

($blk, $in, $out, $err)=$ob->status;
is_ok ($err == 0x15f);				# 106

is_ok ($ob->reset_error == 0x15f);		# 107

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($err);					# 108

# 109 - 111: "Instant" return for read_interval=0xffffffff

$tick=Win32::GetTickCount();
($in, $in2) = $ob->read(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 109
is_bad ($in2);					# 110
$out=$tock - $tick;
is_ok ($out < 100);				# 111
print "<0> elapsed time=$out\n";

# 112 - 120: 2 Second Constant Timeout

is_ok (2000 == $ob->is_read_const_time(2000));	# 112
is_zero ($ob->is_read_interval(0));		# 113


is_ok (100 == $ob->is_read_char_time(100));	# 114


is_zero ($ob->is_read_const_time(0));		# 115


is_zero ($ob->is_read_char_time(0));		# 116

is_ok (0xffffffff == $ob->is_read_interval(0xffffffff));	#117

is_ok (2000 == $ob->is_write_const_time(2000));	# 118

is_zero ($ob->is_write_char_time(0));		# 119

is_ok ("rts" eq $ob->is_handshake("rts"));		# 120 ; so it blocks

# 121 - 122

$e="12345678901234567890";

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 121
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 122
print "<2000> elapsed time=$out\n";

# 123 - 125: 3.5 Second Timeout Constant+Character

is_ok (75 ==$ob->is_write_char_time(75));		# 123

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 124
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3900));	# 125
print "<3500> elapsed time=$out\n";


# 126, 134: 2.5 Second Read Constant Timeout

is_ok (2500 == $ob->is_read_const_time(2500));	# 126
is_zero ($ob->is_read_interval(0));		# 127
is_ok (scalar $ob->purge_all);			# 128

$tick=Win32::GetTickCount();
$in = $ob->read_bg(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 129
$out=$tock - $tick;
is_ok ($out < 100);				# 130
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=Win32::GetTickCount();

is_zero ($pass);				# 131
is_zero ($in);					# 132
is_ok ($in2 eq "");				# 133
$out=$tock - $tick;
is_ok ($out < 100);				# 134


print "A Series of 1 Second Groups with Background I/O\n";

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 135
is_zero ($in);					# 136
is_ok ($in2 eq "");				# 137
is_zero ($ob->write_bg($e));			# 138
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 139
is_zero ($out);					# 140

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 141
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 142

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($in);					# 143
is_ok ($out == 20);				# 144
is_ok ($blk == 1);				# 145
is_zero ($err);					# 146

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 147
is_zero ($in);					# 148
is_ok ($in2 eq "");				# 149
$tock=Win32::GetTickCount();			# expect about 3 seconds
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 150
print "<3000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 151

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 152
is_zero ($in);					# 153
is_ok ($in2 eq "");				# 154
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 155

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 156
is_zero ($out);					# 157
$tock=Win32::GetTickCount();			# expect about 5 seconds
$out=$tock - $tick;
is_bad (($out < 4800) or ($out > 5400));	# 158
print "<5000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 159
($pass, $in, $in2) = $ob->read_done(0);

is_zero ($pass);				# 160 
is_zero ($in);					# 161
is_ok ($in2 eq "");				# 162

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 163
## print "testing fail message:\n";
$in = $ob->read_bg(10);
is_bad (defined $in);				# 164 - already reading

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 165
($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 166
is_zero ($in);					# 167 
is_ok ($in2 eq "");				# 168
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 169
print "<2500> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 170
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 171
is_zero ($in);					# 172
is_ok ($in2 eq "");				# 173

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 174 
is_ok (scalar $ob->purge_rx);			# 175 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 176 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 177 
}
else {
    is_ok ($pass);				# 177 
}
is_zero ($in);					# 178 
is_ok ($in2 eq "");				# 179
$tock=Win32::GetTickCount();			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 180
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 181
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 182

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 183
is_ok (scalar $ob->purge_tx);			# 184 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 185 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 186 
}
else {
    is_ok ($pass);				# 186 
}
$tock=Win32::GetTickCount();			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 187
print "<2000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 188
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 189
is_zero ($ob->write_bg($e));			# 190
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 191

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 192

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 193 
is_zero ($in);					# 194 
is_ok ($in2 eq "");				# 195
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 196
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 197
print "<2500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 198
$tock=Win32::GetTickCount();			# expect 3.5 seconds
$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3800));	# 199
print "<3500> elapsed time=$out\n";

is_ok(1 == $ob->user_msg);			# 200
is_zero(scalar $ob->user_msg(0));		# 201
is_ok(1 == $ob->user_msg(1));			# 202
is_ok(1 == $ob->error_msg);			# 203
is_zero(scalar $ob->error_msg(0));		# 204
is_ok(1 == $ob->error_msg(1));			# 205

undef $ob;
