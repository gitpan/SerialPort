package SerialPort;

use Win32;
use CommPort qw( :STAT :PARAM 0.10 );

use Carp;
use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.10';

require Exporter;
## require AutoLoader;

@ISA = qw( Exporter CommPort );
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

@EXPORT= qw();
@EXPORT_OK= @CommPort::EXPORT_OK;
%EXPORT_TAGS = %CommPort::EXPORT_TAGS;

# parameters that must be included in a "save" and "checking subs"

my %validate =	(
		ALIAS		=> "alias",
		BAUD		=> "baudrate",
		BINARY		=> "binary",
		DATA		=> "databits",
		E_MSG		=> "error_msg",
		EOFCHAR		=> "eof_char",
		ERRCHAR		=> "error_char",
		EVTCHAR		=> "event_char",
		HSHAKE		=> "handshake",
		PARITY		=> "parity",
		PARITY_EN	=> "parity_enable",
		RCONST		=> "read_const_time",
		READBUF		=> "set_read_buf",
		RINT		=> "read_interval",
		RTOT		=> "read_char_time",
		STOP		=> "stopbits",
		U_MSG		=> "user_msg",
		WCONST		=> "write_const_time",
		WRITEBUF	=> "set_write_buf",
		WTOT		=> "write_char_time",
		XOFFCHAR	=> "xoff_char",
		XOFFLIM		=> "xoff_limit",
		XONCHAR		=> "xon_char",
		XONLIM		=> "xon_limit",
		);

#### Package variable declarations ####

my @binary_opt = (0, 1);
my @byte_opt = (0, 255);

my $cfg_file_sig="Win32::SerialPort_Configuration_File -- DO NOT EDIT --\n";

my $Verbose = 0;

    # test*.t only - suppresses default messages
sub set_test_mode_active {
    CommPort->set_no_messages;	# object not defined but :: upsets strict
    return (keys %validate);
}

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $device = shift;
    my $self  = $class->SUPER::new($device);

    return unless $self;

    # "private" data
    $self->{"_DEBUG"}    	= 0;
    $self->{U_MSG}     		= 0;
    $self->{E_MSG}     		= 0;

    # initialize (in CommPort) and write_settings need these defined
    $self->{"_N_U_MSG"} 	= 0;
    $self->{"_N_E_MSG"}		= 0;
    $self->{"_N_ALIAS"}		= 0;

    $self->{ALIAS} = $device;	# so "\\.\+++" can be changed
    $self->{DEVICE} = $device;	# clone so NAME stays in CommPort

    ($self->{MAX_RXB}, $self->{MAX_TXB}) = $self->buffer_max;

    bless ($self, $class);
    return $self;
}


# parse values for start/restart
sub get_start_values {
    return unless (@_ == 2);
    my $self = shift;
    my $filename = shift;

    unless ( open CF, "<$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    my ($signature, $name, @values) = <CF>;
    close CF;
    
    unless ( $cfg_file_sig eq $signature ) {
        carp "Invalid signature in $filename: $signature"; 
        return;
    }
    chomp $name;
    unless ( $self->{DEVICE} eq $name ) {
        carp "Invalid Port DEVICE=$self->{DEVICE} in $filename: $name"; 
        return;
    }
    if ($Verbose or not $self) {
        print "signature = $signature";
        print "name = $name\n";
        if ($Verbose) {
            print "values:\n";
            foreach (@values) { print "    $_"; }
        }
    }
    my $item;
    my $key;
    my $value;
    my $gosub;
    my $fault = 0;
    no strict 'refs';		# for $gosub
    foreach $item (@values) {
        chomp $item;
        ($key, $value) = split (/,/, $item);
        if ($value eq "") { $fault++ }
        else {
            $gosub = $validate{$key};
            unless (defined &$gosub ($self, $value)) {
    	        carp "Invalid parameter for $key=$value   "; 
    	        return;
	    }
        }
    }
    use strict 'refs';
    if ($fault) {
        carp "Invalid value in $filename"; 
        undef $self;
        return;
    }
    1;
}


sub restart {
    return unless (@_ == 2);
    my $self = shift;
    my $filename = shift;

    unless ( $self->init_done ) {
        carp "Can't restart before Port has been initialized"; 
        return;
    }
    get_start_values($self, $filename);
    write_settings($self);
}


sub start {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    return unless (@_);
    my $filename = shift;

    unless ( open CF, "<$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    my ($signature, $name, @values) = <CF>;
    close CF;
    
    unless ( $cfg_file_sig eq $signature ) {
        carp "Invalid signature in $filename: $signature"; 
        return;
    }
    chomp $name;
    my $self  = new ($class, $name);
    if ($Verbose or not $self) {
        print "signature = $signature";
        print "class = $class\n";
        print "name = $name\n";
        if ($Verbose) {
            print "values:\n";
            foreach (@values) { print "    $_"; }
        }
    }
    if ($self) {
        if ( get_start_values($self, $filename) ) {
            write_settings ($self);
	}
        else {
            carp "Invalid value in $filename"; 
            undef $self;
            return;
        }
    }
    return $self;
}

sub write_settings {
    my $self = shift;
    my @items = keys %validate;

    # initialize returns number of faults
    if ( $self->initialize(@items) ) {
        nocarp || $self->close;
        return;
    }

    $self->update_DCB;
    if ($Verbose) {
        print "writing settings to $self->{ALIAS}\n";
    }
    1;
}

sub save {
    my $self = shift;
    my $item;
    my $getsub;
    my $value;

    return unless (@_);
    return unless ($self->init_done);

    my $filename = shift;
    unless ( open CF, ">$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    print CF "$cfg_file_sig";
    print CF "$self->{DEVICE}\n";
	# used to "reopen" so must be DEVICE=NAME
    
    no strict 'refs';		# for $gosub
    while (($item, $getsub) = each %validate) {
        chomp $getsub;
	$value = scalar &$getsub($self);
        print CF "$item,$value\n";
    }
    use strict 'refs';
    close CF;
    if ($Verbose) {
        print "wrote file $filename for $self->{ALIAS}\n";
    }
    1;
}

sub alias {
    my $self = shift;
    if (@_) { $self->{ALIAS} = shift; }	# should return true for legal names
    return $self->{ALIAS};
}

sub user_msg {
    my $self = shift;
    if (@_) { $self->{U_MSG} = yes_true ( shift ) }
    return wantarray ? @binary_opt : $self->{U_MSG};
}

sub error_msg {
    my $self = shift;
    if (@_) { $self->{E_MSG} = yes_true ( shift ) }
    return wantarray ? @binary_opt : $self->{E_MSG};
}

sub baudrate {
    my $self = shift;
    if (@_) {
	unless ( $self->is_baudrate(shift) ) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Could not set baudrate on $self->{ALIAS}";
            }
	    return;
        }
    }
    return wantarray ? $self->are_baudrate : $self->is_baudrate;
}

sub status {
    my $self		= shift;
    my $ok		= 0;
    my $fmask		= 0;
    my $v1		= $Verbose | $self->{"_DEBUG"};
    my $v2		= $v1 | $self->{U_MSG};
    my $v3		= $v1 | $self->{E_MSG};

    my @stat = $self->is_status;
    return unless (scalar @stat);
    $fmask=$stat[ST_BLOCK];
    if ($v1) { printf "BlockingFlags= %lx\n", $fmask; }
    if ($v2 && $fmask) {
        printf "Waiting for CTS\n"		if ($fmask & BM_fCtsHold);
        printf "Waiting for DSR\n"		if ($fmask & BM_fDsrHold);
        printf "Waiting for RLSD\n"		if ($fmask & BM_fRlsdHold);
        printf "Waiting for XON\n"		if ($fmask & BM_fXoffHold);
        printf "Waiting, XOFF was sent\n"	if ($fmask & BM_fXoffSent);
        printf "End_of_File received\n"		if ($fmask & BM_fEof);
        printf "Character waiting to TX\n"	if ($fmask & BM_fTxim);
    }
    $fmask=$stat[ST_ERROR];
    if ($v1) { printf "Error_BitMask= %lx\n", $fmask; }
    if ($v3 && $fmask) {
        # only prints if error is new (API resets each call)
        printf "Invalid MODE or bad HANDLE\n"	if ($fmask & CE_MODE);
        printf "Receive Overrun detected\n"	if ($fmask & CE_RXOVER);
        printf "Buffer Overrun detected\n"	if ($fmask & CE_OVERRUN);
        printf "Parity Error detected\n"	if ($fmask & CE_RXPARITY);
        printf "Framing Error detected\n"	if ($fmask & CE_FRAME);
        printf "Break Signal detected\n"	if ($fmask & CE_BREAK);
        printf "Transmit Buffer is full\n"	if ($fmask & CE_TXFULL);
    }
    return @stat;
}

sub handshake {
    my $self = shift;
    if (@_) {
	unless ( $self->is_handshake(shift) ) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Could not set handshake on $self->{ALIAS}";
            }
	    return;
        }
    }
    return wantarray ? $self->are_handshake : $self->is_handshake;
}

sub parity {
    my $self = shift;
    if (@_) {
	unless ( $self->is_parity(shift) ) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Could not set parity on $self->{ALIAS}";
            }
	    return;
        }
    }
    return wantarray ? $self->are_parity : $self->is_parity;
}

sub databits {
    my $self = shift;
    if (@_) {
	unless ( $self->is_databits(shift) ) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Could not set databits on $self->{ALIAS}";
            }
	    return;
        }
    }
    return wantarray ? $self->are_databits : $self->is_databits;
}

sub stopbits {
    my $self = shift;
    if (@_) {
	unless ( $self->is_stopbits(shift) ) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Could not set stopbits on $self->{ALIAS}";
            }
	    return;
        }
    }
    return wantarray ? $self->are_stopbits : $self->is_stopbits;
}

# single value for save/start
sub set_read_buf {
    my $self = shift;
    if (@_) {
        return unless (@_ == 1);
        my $rbuf = int shift;
        return unless (($rbuf > 0) and ($rbuf <= $self->{MAX_RXB}));
        $self->is_read_buf($rbuf);
    }
    return $self->is_read_buf;
}

# single value for save/start
sub set_write_buf {
    my $self = shift;
    if (@_) {
        return unless (@_ == 1);
        my $wbuf = int shift;
        return unless (($wbuf > 0) and ($wbuf <= $self->{MAX_TXB}));
        $self->is_write_buf($wbuf);
    }
    return $self->is_write_buf;
}

sub buffers {
    my $self = shift;

    if (@_ == 2) {
        my $rbuf = shift;
        my $wbuf = shift;
	unless (defined set_read_buf ($self, $rbuf)) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Can't set read buffer on $self->{ALIAS}";
            }
	    return;
        }
	unless (defined set_write_buf ($self, $wbuf)) {
            if ($self->{U_MSG} or $Verbose) {
                carp "Can't set write buffer on $self->{ALIAS}";
            }
	    return;
        }
	$self->is_buffers($rbuf, $wbuf) || return;
    }
    elsif (@_) { return; }
    return wantarray ? $self->are_buffers : 1;
}

sub read {
    return unless (@_ == 2);
    my $self = shift;
    my $wanted = shift;
    my $ok     = 0;
    my $result = "";
    return unless ($wanted > 0);

    my $got = $self->read_bg ($wanted);

    if ($got != $wanted) {
        ($ok, $got, $result) = $self->read_done(1);	# block until done
    }
    else { ($ok, $got, $result) = $self->read_done(0); }
    print "read=$got\n" if ($Verbose);
    return ($got, $result);
}

sub input {
    return unless (@_ == 1);
    my $self = shift;
    my $ok     = 0;
    my $result = "";
    my $got_p = " "x4;
    my ($bbb, $wanted, $ooo, $eee) = status($self);
    return "" if ($eee);
    return "" unless $wanted;

    my $got = $self->read_bg ($wanted);

    if ($got != $wanted) {
        	# block if unexpected happens
        ($ok, $got, $result) = $self->read_done(1);	# block until done
    }
    else { ($ok, $got, $result) = $self->read_done(0); }
###    print "input: got= $got   result=$result\n";
    return $got ? $result : "";
}

sub write {
    return unless (@_ == 2);
    my $self = shift;
    my $wbuf = shift;
    my $ok;

    return 0 if ($wbuf eq "");
    my $lbuf = length ($wbuf);

    my $written = $self->write_bg ($wbuf);

    if ($written != $lbuf) {
        ($ok, $written) = $self->write_done(1);	# block until done
    }
    if ($Verbose) {
	print "wbuf=$wbuf\n";
	print "lbuf=$lbuf\n";
	print "written=$written\n";
    }
    return $written;
}

sub transmit_char {
    my $self = shift;
    return unless (@_ == 1);
    my $v = int shift;
    return if (($v < 0) or ($v > 255));
    return unless $self->xmit_imm_char ($v);
    return wantarray ? @byte_opt : 1;
}

sub xon_char {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
        $self->is_xon_char($v);
    }
    return wantarray ? @byte_opt : $self->is_xon_char;
}

sub xoff_char {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
        $self->is_xoff_char($v);
    }
    return wantarray ? @byte_opt : $self->is_xoff_char;
}

sub eof_char {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
        $self->is_eof_char($v);
    }
    return wantarray ? @byte_opt : $self->is_eof_char;
}

sub event_char {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
        $self->is_event_char($v);
    }
    return wantarray ? @byte_opt : $self->is_event_char;
}

sub error_char {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
        $self->is_error_char($v);
    }
    return wantarray ? @byte_opt : $self->is_error_char;
}

sub xon_limit {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > SHORTsize));
        $self->is_xon_limit($v);
    }
    return wantarray ? (0, SHORTsize) : $self->is_xon_limit;
}

sub xoff_limit {
    my $self = shift;
    if (@_ == 1) {
	my $v = int shift;
	return if (($v < 0) or ($v > SHORTsize));
        $self->is_xoff_limit($v);
    }
    return wantarray ? (0, SHORTsize) : $self->is_xoff_limit;
}

sub read_interval {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_read_interval( shift );
    }
    return wantarray ? (0, LONGsize) : $self->is_read_interval;
}

sub read_char_time {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_read_char_time( shift );
    }
    return wantarray ? (0, LONGsize) : $self->is_read_char_time;
}

sub read_const_time {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_read_const_time( shift );
    }
    return wantarray ? (0, LONGsize) : $self->is_read_const_time;
}

sub write_const_time {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_write_const_time( shift );
    }
    return wantarray ? (0, LONGsize) : $self->is_write_const_time;
}

sub write_char_time {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_write_char_time( shift );
    }
    return wantarray ? (0, LONGsize) : $self->is_write_char_time;
}


  # true/false parameters

sub binary {
    my $self = shift;
    if (@_) {
	return unless defined $self->is_binary( shift );
    }
    return wantarray ? @binary_opt : $self->is_binary;
}

sub parity_enable {
    my $self = shift;
    if (@_) {
        if ( $self->can_parity_enable ) {
            $self->is_parity_enable( shift );
        }
        elsif ($self->{U_MSG}) {
            carp "Can't set parity enable on $self->{ALIAS}";
        }
    }
    return wantarray ? @binary_opt : $self->is_parity_enable;
}

sub modemlines {
    return unless (@_ == 1);
    my $self = shift;
    my $result = $self->is_modemlines;
    if ($Verbose) {
        print "CTS is ON\n"		if ($result & MS_CTS_ON);
        print "DSR is ON\n"		if ($result & MS_DSR_ON);
        print "RING is ON\n"		if ($result & MS_RING_ON);
        print "RLSD is ON\n"		if ($result & MS_RLSD_ON);
    }
    return $result;
}

sub debug {
    my $self = shift;
    if (ref($self))  {
        if (@_) { $self->{"_DEBUG"} = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
	    my $tmp = $self->{"_DEBUG"};
            nocarp || carp "Debug level: $self->{ALIAS} = $tmp";
	    $self->debug_comm($tmp);
            return $self->{"_DEBUG"};
        }
    } else {
        if (@_) { $Verbose = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
            nocarp || carp "Debug Class = $Verbose";
	    $self->debug_comm($Verbose);
            return $Verbose;
        }
    }
}

sub close {
    my $self = shift;

    return unless (defined $self->{ALIAS});

    if ($Verbose or $self->{"_DEBUG"}) {
        carp "Closing $self " . $self->{ALIAS};
    }
    $self->SUPER::close;
    $self->{DEVICE} = undef;
    $self->{ALIAS} = undef;
}

1;  # so the require or use succeeds

# Autoload methods go after =cut, and are processed by the autosplit program.

__END__

=pod

=head1 NAME

Win32::SerialPort - User interface to Win32 Serial API calls

=head1 SYNOPSIS

  use Win32;
  require 5.003;
  use Win32::SerialPort qw( :STAT 0.10 );

=head2 Constructors

  $PortObj = new Win32::SerialPort ($PortName)
       || die "Can't open $PortName: $^E\n";

  $PortObj = start Win32::SerialPort ($Configuration_File_Name)
       || die "Can't start $Configuration_File_Name: $^E\n";

=head2 Configuration Utility Methods

  $PortObj->alias("MODEM1");

     # before using start
  $PortObj->save($Configuration_File_Name)
       || warn "Can't save $Configuration_File_Name: $^E\n";

     # after new, must check for failure
  $PortObj->write_settings || undef $PortObj;
  print "Can't change Device_Control_Block: $^E\n" unless ($PortObj);

     # rereads file to either return open port to a known state
     # or switch to a different configuration on the same port
  $PortObj->restart($Configuration_File_Name)
       || warn "Can't reread $Configuration_File_Name: $^E\n";

=head2 Configuration Parameter Methods

     # most methods can be called three ways:
  $PortObj->handshake("xoff");           # set parameter
  $flowcontrol = $PortObj->handshake;    # current value (scalar)
  @handshake_opts = $PortObj->handshake; # permitted choices (list)

     # similar
  $PortObj->baudrate(9600);
  $PortObj->parity("odd");
  $PortObj->databits(8);
  $PortObj->stopbits(1.5);
  $PortObj->debug(0);

     # range parameters return (minimum, maximum) in list context
  $PortObj->xon_limit(100);      # bytes left in buffer
  $PortObj->xoff_limit(100);     # space left in buffer
  $PortObj->xon_char(0x11);
  $PortObj->xoff_char(0x13);
  $PortObj->eof_char(0x0);
  $PortObj->event_char(0x0);
  $PortObj->error_char(0);       # for parity errors

  $PortObj->buffers(4096, 4096);  # read, write
	# returns current in list context

  $PortObj->read_interval(100);    # max time between read char (milliseconds)
  $PortObj->read_char_time(5);     # avg time between read char
  $PortObj->read_const_time(100);  # total = (avg * bytes) + const 
  $PortObj->write_char_time(5);
  $PortObj->write_const_time(100);

     # true/false parameters (return scalar context only)

  $PortObj->binary(T);		# just say Yes (Win 3.x option)

  $PortObj->parity_enable(F);	# faults during input

     # test suite only
  @necessary_param = SerialPort->set_test_mode_active;

=head2 Operating Methods

  ($BlockingFlags, $InBytes, $OutBytes, $LatchErrorFlags) = $PortObj->status
	|| warn "could not get port status\n";

  if ($BlockingFlags) { warn "Port is blocked"; }
  if ($BlockingFlags & BM_fCtsHold) { warn "Waiting for CTS"; }
  if ($LatchErrorFlags & CE_FRAME) { warn "Framing Error"; }
        # The API resets errors when reading status, $LatchErrorFlags
	# is all $ErrorFlags seen since the last reset_error

Additional useful constants may be exported eventually. If the only fault
action desired is a message, B<status> provides I<Built-In> BitMask processing:

  $PortObj->error_msg(1);  # prints major messages like "Framing Error"
  $PortObj->user_msg(1);   # prints minor messages like "Waiting for CTS"

  ($count_in, $string_in) = $PortObj->read($InBytes);
  warn "read unsuccessful\n" unless ($count_in == $InBytes);

  $count_out = $PortObj->write($output_string);
  warn "write failed\n"		unless ($count_out);
  warn "write incomplete\n"	if ( $count_out != length($output_string) );

  if ($string_in = $PortObj->input) { PortObj->write($string_in); }
     # simple echo with no control character processing

  $PortObj->transmit_char(0x03);	# bypass buffer (and suspend)

  $ModemStatus = $PortObj->modemlines;
  if ($ModemStatus & $PortObj->MS_RLSD_ON) { print "carrier detected"; }

  $PortObj->close;	## passed to CommPort; undef $PortObj preferred

=head2 Capability Methods inherited from Win32API::CommPort

  can_baud            can_databits           can_stopbits
  can_dtrdsr          can_handshake          can_parity_check 
  can_parity_config   can_parity_enable      can_rlsd 
  can_16bitmode       is_rs232               is_modem 
  can_rtscts          can_xonxoff            can_xon_char 
  can_spec_char       can_interval_timeout   can_total_timeout 
  buffer_max          can_rlsd_config

=head2 Operating Methods inherited from Win32API::CommPort

  write_bg            write_done             read_bg
  read_done           reset_error            suspend_tx
  resume_tx           dtr_active             rts_active
  break_active        xoff_active            xon_active
  purge_all           purge_rx               purge_tx

=head2 Methods not yet Implemented

  $PortObj = dosmode Win32::SerialPort ($MS_Dos_Mode_String)
       || die "Can't complete dosmode open: $^E\n";

  ($complete, $count_in, $string_in) = $PortObj->readline($prompt);
  $PortObj->readline_end("\012");
  $PortObj->echo(OFF);	# input from a terminal (readline)
     # a number of others to provide "stty-like" settings

  $PortObj->ignore_null(No);
  $PortObj->ignore_no_dsr(No);
  $PortObj->abort_on_error("no");
  $PortObj->subst_pe_char("no");

  $PortObj->accept_xoff(F);	# hold during output
  $PortObj->accept_dsr(F);
  $PortObj->accept_cts(F);
  $PortObj->send_xoff(N);
  $PortObj->tx_on_xoff(Y);


=head1 DESCRIPTION


This module uses Win32API::CommPort for raw access to the API calls and
related constants.  It provides an object-based user interface to allow
higher-level use of common API call sequences for dealing with serial
ports.

Uses features of the Win32 API to implement non-blocking I/O, serial
parameter setting, event-loop operation, and enhanced error handling.

To pass in C<NULL> as the pointer to an optional buffer, pass in C<$null=0>.
This is expected to change to an empty list reference, C<[]>, when perl
supports that form in this usage.

=head2 Initialization

The primary constructor is B<new> with a F<PortName> (as the Registry
knows it) specified. This will create an object, and get the available
options and capabilities via the Win32 API. The object is a superset
of a B<Win32API::CommPort> object, and supports all of its methods.
The port is not yet ready for read/write access. First, the desired
I<parameter settings> must be established. Since these are tuning
constants for an underlying hardware driver in the Operating System,
they are all checked for validity by the methods that set them. The
B<write_settings> method writes a new I<Device Control Block> to the
driver. The B<write_settings> method will return true if the port is
ready for access or C<undef> on failure. Ports are opened for binary
transfers. A separate C<binmode> is not needed. The USER must release
the object if B<write_settings> does not succeed.

=over 8

Certain parameters I<MUST> be set before executing B<write_settings>.
Others will attempt to deduce defaults from the hardware or from other
parameters. The I<Required> parameters are:

=item baudrate

Any legal value.

=item parity

One of the following: "none", "odd", "even", "mark", "space".
If you select anything except "none", you will need to set B<parity_enable>.

=item databits

An integer from 5 to 8.

=item stopbits

Legal values are 1, 1.5, and 2.

=back

The B<handshake> setting is recommended but no longer required. Select one
of the following: "none", "rts", "xoff", "dtr".

Some individual parameters (eg. baudrate) can be changed after the
initialization is completed. These will be validated and will
update the I<Device Control Block> as required. The B<save>
method will write the current parameters to a file that B<start> and
B<restart> can use to reestablish a functional setup.

  $PortObj = new Win32::SerialPort ($PortName)
       || die "Can't open $PortName: $^E\n";

  $PortObj->user_msg(ON);
  $PortObj->databits(8);
  $PortObj->baudrate(9600);
  $PortObj->parity("none");
  $PortObj->stopbits(1.5);
  $PortObj->handshake("rts");
  $PortObj->buffers(4096, 4096);

  $PortObj->write_settings || undef $PortObj;

  $PortObj->save($Configuration_File_Name);

  $PortObj->baudrate(300);

  undef $PortObj;  # closes port AND frees memory in perl

The F<PortName> maps to both the Registry I<Device Name> and the
I<Properties> associated with that device. A single I<Physical> port
can be accessed using two or more I<Device Names>. But the options
and setup data will differ significantly in the two cases. A typical
example is a Modem on port "COM2". Both of these F<PortNames> open
the same I<Physical> hardware:

  $P1 = new Win32::SerialPort ("COM2");

  $P2 = new Win32::SerialPort ("\\\\.\\Nanohertz Modem model K-9");

$P1 is a "generic" serial port. $P2 includes all of $P1 plus a variety
of modem-specific added options and features. The "raw" API calls return
different size configuration structures in the two cases. Win32 uses the
"\\.\" prefix to identify "named" devices. Since both names use the same
I<Physical> hardware, they can not both be used at the same time. The OS
will complain. Consider this A Good Thing. Use B<alias> to convert the
name used by "built-in" messages.

  $P2->alias("FIDO");

The second constructor, B<start> is intended to simplify scripts which
need a constant setup. It executes all the steps from B<new> to
B<write_settings> based on a previously saved configuration. This
constructor will return C<undef> on a bad configuration file or failure
of a validity check. The returned object is ready for access.

  $PortObj2 = start Win32::SerialPort ($Configuration_File_Name)
       || die;

A possible third constructor, B<dosmode>, is a further simplification.
The parameters are specified as in the C<MS-DOS 6.x "MODE" command>.
Unspecified parameters would be set to plausible "DOS like" defaults.
Once created, all of the I<parameter settings> would be available.

  $PortObj3 = dosmode Win32::SerialPort ($MS_Dos_Mode_String)
       || die "Can't complete dosmode open: $^E\n";


=head2 Configuration and Capability Methods

The Win32 Serial Comm API provides extensive information concerning
the capabilities and options available for a specific port (and
instance). "Modem" ports have different capabilties than "RS-232"
ports - even if they share the same Hardware. Many traditional modem
actions are handled via TAPI. "Fax" ports have another set of options -
and are accessed via MAPI. Yet many of the same low-level API commands
and data structures are "common" to each type ("Modem" is implemented
as an "RS-232" superset). In addition, Win95 supports a variety of
legacy hardware (e.g fixed 134.5 baud) while WinNT has hooks for ISDN,
16-data-bit paths, and 256Kbaud.

=over 8

Binary selections will accept as I<true> any of the following:
C<("YES", "Y", "ON", "TRUE", "T", "1", 1)> (upper/lower/mixed case)
Anything else is I<false>.

There are a large number of possible configuration and option parameters.
To facilitate checking option validity in scripts, most configuration
methods can be used in three different ways:

=item method called with an argument

The parameter is set to the argument, if valid. An invalid argument
returns I<false> (undef) and the parameter is unchanged. The function
will also I<carp> if B<$error_msg> is I<true>. After B<write_settings>,
the port will be updated immediately if allowed. Otherwise, the value
will be applied when B<write_settings> is called.

=item method called with no argument in scalar context

The current value is returned. If the value is not initialized either
directly or by default, return "undef" which will parse to I<false>.
For binary selections (true/false), return the current value. All
current values from "multivalue" selections will parse to I<true>.
Current values may differ from requested values until B<write_settings>.
There is no way to see requests which have not yet been applied.
Setting the same parameter again overwrites the first request. Test
the return value of the setting method to check "success".

=item method called with no argument in list context

Return a list consisting of all acceptable choices for parameters with
discrete choices. Return a list C<(minimum, maximum)> for parameters
which can be set to a range of values. Binary selections have no need
to call this way - but will get C<(0,1)> if they do. The null list
C<(undef)> will be returned for failed calls in list context (e.g. for
an invalid or unexpected argument). 

=back

=head2 Exports

Nothing is exported by default.  Nothing is currently exported. Optional
tags from Win32API::CommPort are passed through.

=over 4

=item :PARAM

Utility subroutines and constants for parameter setting and test:

	LONGsize	SHORTsize	nocarp		Yes_true
	OS_Error

=item :STAT

Serial communications constants from Win32API::CommPort. Included are the
constants for ascertaining why a transmission is blocked:

	BM_fCtsHold	BM_fDsrHold	BM_fRlsdHold	BM_fXoffHold
	BM_fXoffSent	BM_fEof		BM_fTxim	BM_AllBits

Which incoming bits are active:

	MS_CTS_ON	MS_DSR_ON	MS_RING_ON	MS_RLSD_ON

What hardware errors have been detected:

	CE_RXOVER	CE_OVERRUN	CE_RXPARITY	CE_FRAME
	CE_BREAK	CE_TXFULL	CE_MODE

Offsets into the array returned by B<status:>

	ST_BLOCK	ST_INPUT	ST_OUTPUT	ST_ERROR

=back

=head2 Stty Emulation

Nothing wrong with dreaming! At some point in the future, a limited subset
of stty options may be available through a B<stty> method. The purpose
would be support of existing serial devices which have embedded knowledge
of Unix communication line and login practices.

Until that time, the following table shows correspondance between stty and
SerialPort functions:

        The following stty functions have equivalents in SerialPort:
        ------------------------------------------------------------
        stty functions			related SerialPort functions
        --------------------		----------------------------
        parenb -parenb			parity_enable
        
        parodd -parodd			parity
        
        cs5 cs6 cs7 cs8			databits
        
        cstopb -cstopb			stopbits
        
        clocal -clocal ixon -ixon	handshake
        
        ixoff -ixoff			xon_limit, xoff_limit
        
        parmrk -parmrk			error_char
        
        sane				restart
        
        start				xon_char
        
        stop				xoff_char
        
        time				read_const_time
        
        110 300 600 1200 2400		baudrate
        4800 9600 19200 38400		baudrate
        
        75 134.5 150 1800		fixed baud only - not selectable
        
        -g, "stty < /dev/x"		start, save
        
        raw				read, write
        
        -icanon				input
        
        
        The following stty functions will have equivalents in SerialPort
        after readline (canonical processing) is implemented:
        ----------------------------------------------------------------
        stty functions			related SerialPort functions
        --------------------		----------------------------
        intr				intr_char
        
        eof				eof_char
        
        eol				readline_end
        
        cooked icanon			readline
        
        noflsh -noflsh			purge_all, purge_rx, purge_tx
        
        
        Equivalents for the following stty functions are expected but
        have not yet been defined in SerialPort:
        -------------------------------------------------------------
        [-]istrip	[-]inlcr	[-]igncr	[-]icrnl
        [-]isig		[-]echo		[-]echoe	[-]crterase
        [-]echok	[-]echonl	ek		[-]pass8
        dec		erase		kill		min
        
        
        The following stty functions have no equivalent in SerialPort:
        --------------------------------------------------------------
        -a		-v		[-]cread	[-]hupcl
        [-]hup		[-]ignbrk	[-]brkint	[-]ignpar
        [-]inpck	[-]opost	[-]tostop	susp
        quit		0		50		134
        200		exta		extb

The stty function list is taken from the documentation for IO::Stty by
Austin Schutz.

=head1 NOTES

The object returned by B<new> or B<start> is NOT a I<Filehandle>. You
will be disappointed if you try to use it as one.

e.g. the following is WRONG!!____C<print $PortObj "some text";>

An important note about Win32 filenames. The reserved device names such
as C< COM1, AUX, LPT1, CON, PRN > can NOT be used as filenames. Hence
I<"COM2.cfg"> would not be usable for B<$Configuration_File_Name>.

Thanks to Ken White for testing on NT.

=head1 KNOWN LIMITATIONS

Since everything is (sometimes convoluted but still pure) perl, you can
fix flaws and change limits if required. But please file a bug report if
you do. This module has been tested with each of the binary perl versions
for which Win32::API is supported: AS builds 315, 316, and 500 and GS
5.004_02. It has only been tested on Intel hardware.

=over 4

=item Tutorial

With all the options, this module needs a good tutorial. It doesn't
have one yet. The demo programs are a good starting point.

=item Buffers

The size of the Win32 buffers are selectable with B<buffers>. But each read
method currently uses a fixed internal buffer of 4096 bytes. There are other
fixed internal buffers as well. The XS version will support dynamic buffer
sizing.

=item Modems

Lots of modem-specific options are not supported. The same is true of
TAPI, MAPI. Of course, I<API Wizards> are welcome to contribute.

=item API Options

Lots of options are just "passed through from the API". Some probably
shouldn't be used together. The module validates the obvious choices when
possible. For something really fancy, you may need additional API
documentation. Available from I<Micro$oft Pre$$>.

=item Asynchronous (Background) I/O

This version now handles Polling (do if Ready), Synchronous (block until
Ready), and Asynchronous Modes (begin and test if Ready) with the timeout
choices provided by the API. No effort has yet been made to interact with
TK events (or Windows events).

=item Timeouts

The API provides two timing models. The first applies only to read and
essentially determines I<Read Not Ready> by checking the time between
consecutive characters. The B<ReadFile> operation returns if that time
exceeds the value set by B<read_interval>. It does this by timestamping
each character. It appears that at least one character must by received
to initialize the mechanism.

The other model defines the total time allowed to complete the operation.
A fixed overhead time is added to the product of bytes and per_byte_time.
A wide variety of timeout options can be defined by selecting the three
parameters: fixed, each, and size.

Read_total = B<read_const_time> + (B<read_char_time> * bytes_to_read)

Write_total = B<write_const_time> + (B<write_char_time> * bytes_to_write)

=back

=head1 BUGS

On Win32, a port which has been closed cannot be reopened again by the same
process. If a physical port can be accessed using more than one name (see
above), all names are treated as one. Exiting and rerunning the script is ok.
The perl script can also be run multiple times within a singe batch file or
shell script.


On NT, a B<read_done> or B<write_done> returns I<False> if a background
operation is aborted by a purge. Win95 returns I<True>.

EXTENDED_OS_ERROR ($^E) is not supported by the binary ports before 5.005.
It "sort-of-tracks" B<$!> in 5.003 and 5.004, but YMMV.

__Please send comments and bug reports to wcbirthisel@alum.mit.edu.

=head1 AUTHORS

Bill Birthisel, wcbirthisel@alum.mit.edu, http://members.aol.com/Bbirthisel/.

Tye McQueen, tye@metronet.com, http://www.metronet.com/~tye/.

=head1 SEE ALSO

Win32API::Comm - the low-level API calls which support this module

Win32API::File I<when available>

Win32::API - Aldo Calpini's "Magic", http://www.divinf.it/dada/perl/

Perltoot.xxx - Tom (Christiansen)'s Object-Oriented Tutorial

=head1 COPYRIGHT

Copyright (C) 1998, Bill Birthisel. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head2 DISCLAIMER

This is still Beta code and may be subject to functional changes which
are not fully backwards compatible.  This module is B<NOT> ready
for production use. Consider the lack of an I<Install> program to be a
feature and run in a "standalone" directory. 29 Aug 1998.

=cut
