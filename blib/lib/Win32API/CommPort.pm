# This part includes the low-level API calls
package Win32API::CommPort;

use Win32;
use Win32::API 0.01;

use Carp;
use strict;

		#### API declarations ####
no strict 'subs';	# these may be imported someday

use vars qw(
	$_CloseHandle		$_CreateFile		$_GetCommState
	$_ReadFile		$_SetCommState		$_SetupComm
	$_PurgeComm		$_CreateEvent		$_GetCommTimeouts
	$_SetCommTimeouts	$_GetCommProperties	$_ClearCommBreak
	$_ClearCommError	$_EscapeCommFunction	$_GetCommConfig
	$_GetCommMask		$_GetCommModemStatus	$_SetCommBreak
	$_SetCommConfig		$_SetCommMask		$_TransmitCommChar
	$_WaitCommEvent		$_WriteFile		$_ResetEvent
	$_GetOverlappedResult
);

$_CreateFile = new Win32::API("kernel32", "CreateFile",
	 [P, N, N, N, N, N, N], N);
$_CloseHandle = new Win32::API("kernel32", "CloseHandle", [P], N);
$_GetCommState = new Win32::API("kernel32", "GetCommState", [N, P], I);
$_SetCommState = new Win32::API("kernel32", "SetCommState", [N, P], I);
$_SetupComm = new Win32::API("kernel32", "SetupComm", [N, N, N], I);
$_PurgeComm = new Win32::API("kernel32", "PurgeComm", [N, N], I);
$_CreateEvent = new Win32::API("kernel32", "CreateEvent", [P, I, I, P], N);
$_GetCommTimeouts = new Win32::API("kernel32", "GetCommTimeouts",
	 [N, P], I);
$_SetCommTimeouts = new Win32::API("kernel32", "SetCommTimeouts",
	 [N, P], I);
$_GetCommProperties = new Win32::API("kernel32", "GetCommProperties",
	 [N, P], I);
$_ReadFile = new Win32::API("kernel32", "ReadFile", [N, P, N, P, P], I);
$_WriteFile = new Win32::API("kernel32", "WriteFile", [N, P, N, P, P], I);
$_TransmitCommChar = new Win32::API("kernel32", "TransmitCommChar", [N, I], I);
$_ClearCommBreak = new Win32::API("kernel32", "ClearCommBreak", [N], I);
$_SetCommBreak = new Win32::API("kernel32", "SetCommBreak", [N], I);
$_ClearCommError = new Win32::API("kernel32", "ClearCommError", [N, P, P], I);
$_EscapeCommFunction = new Win32::API("kernel32", "EscapeCommFunction",
	 [N, N], I);
$_GetCommModemStatus = new Win32::API("kernel32", "GetCommModemStatus",
	 [N, P], I);
$_GetOverlappedResult = new Win32::API("kernel32", "GetOverlappedResult",
	 [N, P, P, I], I);

#### these are not used yet

$_GetCommConfig = new Win32::API("kernel32", "GetCommConfig", [N, P, P], I);
$_GetCommMask = new Win32::API("kernel32", "GetCommMask", [N, P], I);
$_SetCommConfig = new Win32::API("kernel32", "SetCommConfig", [N, P, N], I);
$_SetCommMask = new Win32::API("kernel32", "SetCommMask", [N, N], I);
$_WaitCommEvent = new Win32::API("kernel32", "WaitCommEvent", [N, P, P], I);
$_ResetEvent = new Win32::API("kernel32", "ResetEvent", [N], I);

use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.12';

require Exporter;
## require AutoLoader;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

@EXPORT= qw();
@EXPORT_OK= qw();
%EXPORT_TAGS = (STAT	=> [qw( BM_fCtsHold	BM_fDsrHold
				BM_fRlsdHold	BM_fXoffHold
				BM_fXoffSent	BM_fEof
				BM_fTxim	BM_AllBits
				MS_CTS_ON	MS_DSR_ON
				MS_RING_ON	MS_RLSD_ON
				CE_RXOVER	CE_OVERRUN
				CE_RXPARITY	CE_FRAME
				CE_BREAK	CE_TXFULL
				CE_MODE		ST_BLOCK
				ST_INPUT	ST_OUTPUT
				ST_ERROR )],

		RAW	=> [qw( CloseHandle		CreateFile
				GetCommState		ReadFile
				SetCommState		SetupComm
				PurgeComm		CreateEvent
				GetCommTimeouts		SetCommTimeouts
				GetCommProperties	ClearCommBreak
				ClearCommError		EscapeCommFunction
				GetCommConfig		GetCommMask
				GetCommModemStatus	SetCommBreak
				SetCommConfig		SetCommMask
				TransmitCommChar	WaitCommEvent
				WriteFile		ResetEvent
				GetOverlappedResult
				PURGE_TXABORT		PURGE_RXABORT
				PURGE_TXCLEAR		PURGE_RXCLEAR
				SETXOFF			SETXON
				SETRTS			CLRRTS
				SETDTR			CLRDTR
				SETBREAK		CLRBREAK
				EV_RXCHAR		EV_RXFLAG
				EV_TXEMPTY		EV_CTS
				EV_DSR			EV_RLSD
				EV_BREAK		EV_ERR
				EV_RING			EV_PERR
				EV_RX80FULL		EV_EVENT1
				EV_EVENT2		ERROR_IO_INCOMPLETE
				ERROR_IO_PENDING )],

	      COMMPROP	=> [qw( BAUD_USER	BAUD_075	BAUD_110
				BAUD_134_5	BAUD_150	BAUD_300
				BAUD_600	BAUD_1200	BAUD_1800
				BAUD_2400	BAUD_4800	BAUD_7200
				BAUD_9600	BAUD_14400	BAUD_19200
				BAUD_38400	BAUD_56K	BAUD_57600
				BAUD_115200	BAUD_128K

				PST_FAX		PST_LAT		PST_MODEM
				PST_RS232	PST_RS422	PST_RS423
				PST_RS449	PST_SCANNER	PST_X25
				PST_NETWORK_BRIDGE	PST_PARALLELPORT
				PST_TCPIP_TELNET	PST_UNSPECIFIED

				PCF_INTTIMEOUTS		PCF_PARITY_CHECK
				PCF_16BITMODE		PCF_DTRDSR
				PCF_SPECIALCHARS	PCF_RLSD
				PCF_RTSCTS		PCF_SETXCHAR
				PCF_TOTALTIMEOUTS	PCF_XONXOFF

				SP_BAUD		SP_DATABITS	SP_HANDSHAKING
				SP_PARITY	SP_PARITY_CHECK	SP_RLSD
				SP_STOPBITS	SP_SERIALCOMM

				DATABITS_5	DATABITS_6	DATABITS_7
				DATABITS_8	DATABITS_16	DATABITS_16X

				STOPBITS_10	STOPBITS_15	STOPBITS_20
				PARITY_SPACE	PARITY_NONE	PARITY_ODD
				PARITY_EVEN	PARITY_MARK
				COMMPROP_INITIALIZED )],

		DCB	=> [qw( CBR_110		CBR_300		CBR_600
				CBR_1200	CBR_2400	CBR_4800
				CBR_9600	CBR_14400	CBR_19200
				CBR_38400	CBR_56000	CBR_57600
				CBR_115200	CBR_128000	CBR_256000

				DTR_CONTROL_DISABLE	DTR_CONTROL_ENABLE
				DTR_CONTROL_HANDSHAKE	RTS_CONTROL_DISABLE
				RTS_CONTROL_ENABLE	RTS_CONTROL_HANDSHAKE
				RTS_CONTROL_TOGGLE

				EVENPARITY	MARKPARITY	NOPARITY
				ODDPARITY	SPACEPARITY

				ONESTOPBIT	ONE5STOPBITS	TWOSTOPBITS

				FM_fBinary		FM_fParity
				FM_fOutxCtsFlow		FM_fOutxDsrFlow
				FM_fDtrControl		FM_fDsrSensitivity
				FM_fTXContinueOnXoff	FM_fOutX
				FM_fInX			FM_fErrorChar
				FM_fNull		FM_fRtsControl
				FM_fAbortOnError	FM_fDummy2 )],

		PARAM	=> [qw( LONGsize	SHORTsize	OS_Error
				nocarp		yes_true )]);


Exporter::export_ok_tags('STAT', 'RAW', 'COMMPROP', 'DCB', 'PARAM');

$EXPORT_TAGS{ALL} = \@EXPORT_OK;

#### subroutine wrappers for API calls

sub CloseHandle {
    return unless ( 1 == @_ );
    return $_CloseHandle->Call( shift );
    # boolean not usually checked
}

sub CreateFile {
    return $_CreateFile->Call( @_ );
    # returns handle
}

sub GetCommState {
    return $_GetCommState->Call( @_ );
}

sub SetCommState {
    return $_SetCommState->Call( @_ );
}

sub SetupComm {
    return $_SetupComm->Call( @_ );
}

sub PurgeComm {
    return $_PurgeComm->Call( @_ );
}

sub CreateEvent {
    return $_CreateEvent->Call( @_ );
}

sub GetCommTimeouts {
    return $_GetCommTimeouts->Call( @_ );
}

sub SetCommTimeouts {
    return $_SetCommTimeouts->Call( @_ );
}

sub GetCommProperties {
    return $_GetCommProperties->Call( @_ );
}

sub ReadFile {
    return $_ReadFile->Call( @_ );
}

sub WriteFile {
    return $_WriteFile->Call( @_ );
}

sub TransmitCommChar {
    return $_TransmitCommChar->Call( @_ );
}

sub ClearCommBreak {
    return unless ( 1 == @_ );
    return $_ClearCommBreak->Call( shift );
}

sub SetCommBreak {
    return unless ( 1 == @_ );
    return $_SetCommBreak->Call( shift );
}

sub ClearCommError {
    return $_ClearCommError->Call( @_ );
}

sub EscapeCommFunction {
    return $_EscapeCommFunction->Call( @_ );
}

sub GetCommModemStatus {
    return $_GetCommModemStatus->Call( @_ );
}

sub GetOverlappedResult {
    return $_GetOverlappedResult->Call( @_ );
}

sub GetCommConfig {
    return $_GetCommConfig->Call( @_ );
}

sub GetCommMask {
    return $_GetCommMask->Call( @_ );
}

sub SetCommConfig {
    return $_SetCommConfig->Call( @_ );
}

sub SetCommMask {
    return $_SetCommMask->Call( @_ );
}

sub WaitCommEvent {
    return $_WaitCommEvent->Call( @_ );
}

sub ResetEvent {
    return unless ( 1 == @_ );
    return $_ResetEvent->Call( shift );
}

#### "constant" declarations from Win32 header files ####
#### compatible with ActiveState ####

## COMMPROP structure
sub SP_SERIALCOMM	{ 0x1 }
sub BAUD_075		{ 0x1 }
sub BAUD_110		{ 0x2 }
sub BAUD_134_5		{ 0x4 }
sub BAUD_150		{ 0x8 }
sub BAUD_300		{ 0x10 }
sub BAUD_600		{ 0x20 }
sub BAUD_1200		{ 0x40 }
sub BAUD_1800		{ 0x80 }
sub BAUD_2400		{ 0x100 }
sub BAUD_4800		{ 0x200 }
sub BAUD_7200		{ 0x400 }
sub BAUD_9600		{ 0x800 }
sub BAUD_14400		{ 0x1000 }
sub BAUD_19200		{ 0x2000 }
sub BAUD_38400		{ 0x4000 }
sub BAUD_56K		{ 0x8000 }
sub BAUD_57600		{ 0x40000 }
sub BAUD_115200		{ 0x20000 }
sub BAUD_128K		{ 0x10000 }
sub BAUD_USER		{ 0x10000000 }
sub PST_FAX		{ 0x21 }
sub PST_LAT		{ 0x101 }
sub PST_MODEM		{ 0x6 }
sub PST_NETWORK_BRIDGE	{ 0x100 }
sub PST_PARALLELPORT	{ 0x2 }
sub PST_RS232		{ 0x1 }
sub PST_RS422		{ 0x3 }
sub PST_RS423		{ 0x4 }
sub PST_RS449		{ 0x5 }
sub PST_SCANNER		{ 0x22 }
sub PST_TCPIP_TELNET	{ 0x102 }
sub PST_UNSPECIFIED	{ 0 }
sub PST_X25		{ 0x103 }
sub PCF_16BITMODE	{ 0x200 }
sub PCF_DTRDSR		{ 0x1 }
sub PCF_INTTIMEOUTS	{ 0x80 }
sub PCF_PARITY_CHECK	{ 0x8 }
sub PCF_RLSD		{ 0x4 }
sub PCF_RTSCTS		{ 0x2 }
sub PCF_SETXCHAR	{ 0x20 }
sub PCF_SPECIALCHARS	{ 0x100 }
sub PCF_TOTALTIMEOUTS	{ 0x40 }
sub PCF_XONXOFF		{ 0x10 }
sub SP_BAUD		{ 0x2 }
sub SP_DATABITS		{ 0x4 }
sub SP_HANDSHAKING	{ 0x10 }
sub SP_PARITY		{ 0x1 }
sub SP_PARITY_CHECK	{ 0x20 }
sub SP_RLSD		{ 0x40 }
sub SP_STOPBITS		{ 0x8 }
sub DATABITS_5		{ 1 }
sub DATABITS_6		{ 2 }
sub DATABITS_7		{ 4 }
sub DATABITS_8		{ 8 }
sub DATABITS_16		{ 16 }
sub DATABITS_16X	{ 32 }
sub STOPBITS_10		{ 1 }
sub STOPBITS_15		{ 2 }
sub STOPBITS_20		{ 4 }
sub PARITY_NONE		{ 256 }
sub PARITY_ODD		{ 512 }
sub PARITY_EVEN		{ 1024 }
sub PARITY_MARK		{ 2048 }
sub PARITY_SPACE	{ 4096 }
sub COMMPROP_INITIALIZED	{ 0xe73cf52e }

## DCB structure
sub CBR_110			{ 110 }
sub CBR_300			{ 300 }
sub CBR_600			{ 600 }
sub CBR_1200			{ 1200 }
sub CBR_2400			{ 2400 }
sub CBR_4800			{ 4800 }
sub CBR_9600			{ 9600 }
sub CBR_14400			{ 14400 }
sub CBR_19200			{ 19200 }
sub CBR_38400			{ 38400 }
sub CBR_56000			{ 56000 }
sub CBR_57600			{ 57600 }
sub CBR_115200			{ 115200 }
sub CBR_128000			{ 128000 }
sub CBR_256000			{ 256000 }
sub DTR_CONTROL_DISABLE		{ 0 }
sub DTR_CONTROL_ENABLE		{ 1 }
sub DTR_CONTROL_HANDSHAKE	{ 2 }
sub RTS_CONTROL_DISABLE		{ 0 }
sub RTS_CONTROL_ENABLE		{ 1 }
sub RTS_CONTROL_HANDSHAKE	{ 2 }
sub RTS_CONTROL_TOGGLE		{ 3 }
sub EVENPARITY			{ 2 }
sub MARKPARITY			{ 3 }
sub NOPARITY			{ 0 }
sub ODDPARITY			{ 1 }
sub SPACEPARITY			{ 4 }
sub ONESTOPBIT			{ 0 }
sub ONE5STOPBITS		{ 1 }
sub TWOSTOPBITS			{ 2 }

## Flowcontrol bit mask in DCB
sub FM_fBinary			{ 0x1 }
sub FM_fParity			{ 0x2 }
sub FM_fOutxCtsFlow		{ 0x4 }
sub FM_fOutxDsrFlow		{ 0x8 }
sub FM_fDtrControl		{ 0x30 }
sub FM_fDsrSensitivity		{ 0x40 }
sub FM_fTXContinueOnXoff	{ 0x80 }
sub FM_fOutX			{ 0x100 }
sub FM_fInX			{ 0x200 }
sub FM_fErrorChar		{ 0x400 }
sub FM_fNull			{ 0x800 }
sub FM_fRtsControl		{ 0x3000 }
sub FM_fAbortOnError		{ 0x4000 }
sub FM_fDummy2			{ 0xffff8000 }

## COMSTAT bit mask
sub BM_fCtsHold		{ 0x1 }   
sub BM_fDsrHold		{ 0x2 }   
sub BM_fRlsdHold	{ 0x4 }  
sub BM_fXoffHold	{ 0x8 }  
sub BM_fXoffSent	{ 0x10 }  
sub BM_fEof		{ 0x20 }       
sub BM_fTxim		{ 0x40 }      
sub BM_AllBits		{ 0x7f }      

## PurgeComm bit mask
sub PURGE_TXABORT	{ 0x1 }   
sub PURGE_RXABORT	{ 0x2 }   
sub PURGE_TXCLEAR	{ 0x4 }  
sub PURGE_RXCLEAR	{ 0x8 }  

## GetCommModemStatus bit mask
sub MS_CTS_ON		{ 0x10 }   
sub MS_DSR_ON		{ 0x20 }   
sub MS_RING_ON		{ 0x40 }  
sub MS_RLSD_ON		{ 0x80 }  

## EscapeCommFunction operations
sub SETXOFF		{ 0x1 }
sub SETXON		{ 0x2 }
sub SETRTS		{ 0x3 }
sub CLRRTS		{ 0x4 }
sub SETDTR		{ 0x5 }
sub CLRDTR		{ 0x6 }
sub SETBREAK		{ 0x8 }
sub CLRBREAK		{ 0x9 }

## ClearCommError bit mask
sub CE_RXOVER		{ 0x1 }
sub CE_OVERRUN		{ 0x2 }
sub CE_RXPARITY		{ 0x4 }
sub CE_FRAME		{ 0x8 }
sub CE_BREAK		{ 0x10 }
sub CE_TXFULL		{ 0x100 }
#### LPT only
# sub CE_PTO		{ 0x200 }
# sub CE_IOE		{ 0x400 }
# sub CE_DNS		{ 0x800 }
# sub CE_OOP		{ 0x1000 }
#### LPT only
sub CE_MODE		{ 0x8000 }

## GetCommMask bits
sub EV_RXCHAR		{ 0x1 }
sub EV_RXFLAG		{ 0x2 }
sub EV_TXEMPTY		{ 0x4 }
sub EV_CTS		{ 0x8 }
sub EV_DSR		{ 0x10 }
sub EV_RLSD		{ 0x20 }
sub EV_BREAK		{ 0x40 }
sub EV_ERR		{ 0x80 }
sub EV_RING		{ 0x100 }
sub EV_PERR		{ 0x200 }
sub EV_RX80FULL		{ 0x400 }
sub EV_EVENT1		{ 0x800 }
sub EV_EVENT2		{ 0x1000 }

## Allowed OVERLAP errors
sub ERROR_IO_INCOMPLETE	{ 996 }
sub ERROR_IO_PENDING	{ 997 }

#### "constant" declarations compatible with ActiveState ####

my $DCBformat="LLLSSSCCCCCCCCS";
my $CP_format1="SSLLLLLLLLLSSLLLLSA*";			 # rs232
my $CP_format6="SSLLLLLLLLLSSLLLLLLLLLLLLLLLLLLLLLLLA*"; # modem
my $CP_format0="SA50LA244";				 # pre-read

my $OVERLAPPEDformat="LLLLL";
my $TIMEOUTformat="LLLLL";
my $COMSTATformat="LLL";
my $cfg_file_sig="Win32API::SerialPort_Configuration_File -- DO NOT EDIT --\n";

sub SHORTsize { 0xffff; }
sub LONGsize { 0xffffffff; }

sub ST_BLOCK	{0}	# status offsets for caller
sub ST_INPUT	{1}
sub ST_OUTPUT	{2}
sub ST_ERROR	{3}	# latched


#### Package variable declarations ####

my @Yes_resp = (
	       "YES","Y",
	       "ON",
	       "TRUE","T",
	       "1"
	       );

my @binary_opt = (0, 1);
my @byte_opt = (0, 255);

my $Babble = 0;
my $testactive = 0;	# test mode active

## my $null=[];
my $null=0;
my $zero=0;

# Preloaded methods go here.

sub OS_Error { print Win32::FormatMessage ( Win32::GetLastError() ); }

    # test*.t only - suppresses default messages
sub set_no_messages { $testactive = 1; }

sub nocarp { return $testactive }

sub yes_true {
    my $choice = uc shift;
    my $ans = 0;
    foreach (@Yes_resp) { $ans = 1 if ( $choice eq $_ ) }
    return $ans;
}

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    my $ok    = 0;		# API return value
    my $hr    = 0;		# temporary hashref
    my $fmask = 0;		# temporary for bit banging
    my $fix_baud = 0;
    my $key;
    my $value;
    my $CommPropBlank = " ";

        # COMMPROP only used during new
    my $CommProperties		= " "x300; # extra buffer for modems
    my $CP_Length		= 0;
    my $CP_Version		= 0;
    my $CP_ServiceMask		= 0;
    my $CP_Reserved1		= 0;
    my $CP_MaxBaud		= 0;
    my $CP_ProvCapabilities	= 0;
    my $CP_SettableParams	= 0;
    my $CP_SettableBaud		= 0;
    my $CP_SettableData		= 0;
    my $CP_SettableStopParity	= 0;
    my $CP_ProvSpec1		= 0;
    my $CP_ProvSpec2		= 0;
    my $CP_ProvChar_start	= 0;
    my $CP_Filler		= 0;

        # MODEMDEVCAPS
    my $MC_ReqSize		= 0;
    my $MC_SpecOffset		= 0;
    my $MC_SpecSize		= 0;
    my $MC_ProvVersion		= 0;
    my $MC_ManfOffset		= 0;
    my $MC_ManfSize		= 0;
    my $MC_ModOffset		= 0;
    my $MC_ModSize		= 0;
    my $MC_VerOffset		= 0;
    my $MC_VerSize		= 0;
    my $MC_DialOpt		= 0;
    my $MC_CallFailTime		= 0;
    my $MC_IdleTime		= 0;
    my $MC_SpkrVol		= 0;
    my $MC_SpkrMode		= 0;
    my $MC_ModOpt		= 0;
    my $MC_MaxDTE		= 0;
    my $MC_MaxDCE		= 0;
    my $MC_Filler		= 0;

    $self->{NAME}     = shift;

    $self->{"_HANDLE"}=CreateFile("$self->{NAME}",
				  0xc0000000,
				  0,	
				  $null,
				  3,
				  0x40000000,
				  $null);
	# device name
	# GENERIC_READ | GENERIC_WRITE
	# no FILE_SHARE_xx
	# no SECURITY_xx
	# OPEN_EXISTING
	# FILE_FLAG_OVERLAPPED
	# template file

    unless ($self->{"_HANDLE"} >= 1) {
        OS_Error;
        carp "can't open device: $self->{NAME}\n"; 
        $self->{"_HANDLE"} = 0;
        return;
    }

    # let Win32 know we allowed room for modem properties
    $CP_Length = 300;
    $CP_ProvSpec1 = COMMPROP_INITIALIZED;
    $CommProperties = pack($CP_format0,
		           $CP_Length,
		           $CommPropBlank,
		           $CP_ProvSpec1,
		           $CommPropBlank);

    $ok=GetCommProperties($self->{"_HANDLE"}, $CommProperties);

    unless ( $ok ) {
        OS_Error;
        carp "can't get COMMPROP block";
        undef $self;
        return;
    }

    ($CP_Length,
     $CP_Version,
     $CP_ServiceMask,
     $CP_Reserved1,
     $self->{"_MaxTxQueue"},
     $self->{"_MaxRxQueue"},
     $CP_MaxBaud,
     $self->{"_TYPE"},
     $CP_ProvCapabilities,
     $CP_SettableParams,
     $CP_SettableBaud,
     $CP_SettableData,
     $CP_SettableStopParity,
     $self->{WRITEBUF},
     $self->{READBUF},
     $CP_ProvSpec1,
     $CP_ProvSpec2,
     $CP_ProvChar_start,
     $CP_Filler)= unpack($CP_format1, $CommProperties);

    if (($CP_Length > 64) and ($self->{"_TYPE"} == PST_RS232)) {
        carp "invalid COMMPROP block length= $CP_Length";
        undef $self;
        return;
    }
    if ($CP_ServiceMask != SP_SERIALCOMM) {
        carp "doesn't claim to be a serial port\n";
        undef $self;
        return;
    }
    if ($self->{"_TYPE"} == PST_MODEM) {
        ($CP_Length,
         $CP_Version,
         $CP_ServiceMask,
         $CP_Reserved1,
         $self->{"_MaxTxQueue"},
         $self->{"_MaxRxQueue"},
         $CP_MaxBaud,
         $self->{"_TYPE"},
         $CP_ProvCapabilities,
         $CP_SettableParams,
         $CP_SettableBaud,
         $CP_SettableData,
         $CP_SettableStopParity,
         $self->{WRITEBUF},
         $self->{READBUF},
         $CP_ProvSpec1,
         $CP_ProvSpec2,
         $CP_ProvChar_start,
         $MC_ReqSize,
         $MC_SpecOffset,
         $MC_SpecSize,
         $MC_ProvVersion,
         $MC_ManfOffset,
         $MC_ManfSize,
         $MC_ModOffset,
         $MC_ModSize,
         $MC_VerOffset,
         $MC_VerSize,
         $MC_DialOpt,
         $MC_CallFailTime,
         $MC_IdleTime,
         $MC_SpkrVol,
         $MC_SpkrMode,
         $MC_ModOpt,
         $MC_MaxDTE,
         $MC_MaxDCE,
         $MC_Filler)= unpack($CP_format6, $CommProperties);
    
        if ($Babble) {
            printf "\$CP_Length= %d\n", $CP_Length;
            printf "\$CP_Version= %d\n", $CP_Version;
            printf "\$CP_ServiceMask= %lx\n", $CP_ServiceMask;
            printf "\$CP_Reserved1= %lx\n", $CP_Reserved1;
            printf "\$CP_MaxTxQueue= %lx\n", $self->{"_MaxTxQueue"};
            printf "\$CP_MaxRxQueue= %lx\n", $self->{"_MaxRxQueue"};
            printf "\$CP_MaxBaud= %lx\n", $CP_MaxBaud;
            printf "\$CP_ProvSubType= %lx\n", $self->{"_TYPE"};
            printf "\$CP_ProvCapabilities= %lx\n", $CP_ProvCapabilities;
            printf "\$CP_SettableParams= %lx\n", $CP_SettableParams;
            printf "\$CP_SettableBaud= %lx\n", $CP_SettableBaud;
            printf "\$CP_SettableData= %x\n", $CP_SettableData;
            printf "\$CP_SettableStopParity= %x\n", $CP_SettableStopParity;
            printf "\$CP_CurrentTxQueue= %lx\n", $self->{WRITEBUF};
            printf "\$CP_CurrentRxQueue= %lx\n", $self->{READBUF};
            printf "\$CP_ProvSpec1= %lx\n", $CP_ProvSpec1;
            printf "\$CP_ProvSpec2= %lx\n", $CP_ProvSpec2;
    	    printf "\nMODEMDEVCAPS:\n";
            printf "\$MC_ActualSize= %d\n", $CP_ProvChar_start;
            printf "\$MC_ReqSize= %d\n", $MC_ReqSize;
            printf "\$MC_SpecOffset= %d\n", $MC_SpecOffset;
            printf "\$MC_SpecSize= %d\n", $MC_SpecSize;
    	    if ($MC_SpecOffset) {
                printf "    DeviceSpecificData= %s\n", substr ($CommProperties,
    					 60+$MC_SpecOffset, $MC_SpecSize);
    	    }
            printf "\$MC_ProvVersion= %d\n", $MC_ProvVersion;
            printf "\$MC_ManfOffset= %d\n", $MC_ManfOffset;
            printf "\$MC_ManfSize= %d\n", $MC_ManfSize;
    	    if ($MC_ManfOffset) {
                printf "    Manufacturer= %s\n", substr ($CommProperties,
    					 60+$MC_ManfOffset, $MC_ManfSize);
    	    }
            printf "\$MC_ModOffset= %d\n", $MC_ModOffset;
            printf "\$MC_ModSize= %d\n", $MC_ModSize;
    	    if ($MC_ModOffset) {
                printf "    Model= %s\n", substr ($CommProperties,
    					 60+$MC_ModOffset, $MC_ModSize);
    	    }
            printf "\$MC_VerOffset= %d\n", $MC_VerOffset;
            printf "\$MC_VerSize= %d\n", $MC_VerSize;
    	    if ($MC_VerOffset) {
                printf "    Version= %s\n", substr ($CommProperties,
    					 60+$MC_VerOffset, $MC_VerSize);
    	    }
            printf "\$MC_DialOpt= %lx\n", $MC_DialOpt;
            printf "\$MC_CallFailTime= %d\n", $MC_CallFailTime;
            printf "\$MC_IdleTime= %d\n", $MC_IdleTime;
            printf "\$MC_SpkrVol= %d\n", $MC_SpkrVol;
            printf "\$MC_SpkrMode= %d\n", $MC_SpkrMode;
            printf "\$MC_ModOpt= %lx\n", $MC_ModOpt;
            printf "\$MC_MaxDTE= %d\n", $MC_MaxDTE;
            printf "\$MC_MaxDCE= %d\n", $MC_MaxDCE;
    	    $MC_Filler= $MC_Filler;			# for -w
    	    }
##        $MC_ReqSize = 250;
        if ($CP_ProvChar_start != $MC_ReqSize) {
            printf "\nARGH, a Bug! The \$CommProperties buffer must be ";
            printf "at least %d bytes.\n", $MC_ReqSize+60;
        }
    }

    # "private" data
    $self->{"_INIT"}     	= undef;
    $self->{"_DEBUG_C"}    	= 0;
    $self->{"_LATCH"} 		= 0;
    $self->{"_W_BUSY"}		= 0;
    $self->{"_R_BUSY"}		= 0;

    $self->{"_TBUFMAX"}		= $self->{"_MaxTxQueue"} ?
					$self->{"_MaxTxQueue"} : LONGsize;
    $self->{"_RBUFMAX"}		= $self->{"_MaxRxQueue"} ?
					$self->{"_MaxRxQueue"} : LONGsize;

    # buffers
    $self->{"_R_OVERLAP"}	= " "x24;
    $self->{"_W_OVERLAP"}	= " "x24;
    $self->{"_TIMEOUT"}		= " "x24;
    $self->{"_RBUF"}		= " "x4096;

    # allowed setting hashes
    $self->{"_L_BAUD"}		= {};
    $self->{"_L_STOP"}		= {};
    $self->{"_L_PARITY"}	= {};
    $self->{"_L_DATA"}		= {};
    $self->{"_L_HSHAKE"}	= {};

    # capability flags

    $fmask			= $CP_SettableParams;
    $self->{"_C_BAUD"}     	= $fmask & SP_BAUD;
    $self->{"_C_DATA"}		= $fmask & SP_DATABITS;
    $self->{"_C_STOP"}		= $fmask & SP_STOPBITS;
    $self->{"_C_HSHAKE"}	= $fmask & SP_HANDSHAKING;
    $self->{"_C_PARITY_CFG"}	= $fmask & SP_PARITY;
    $self->{"_C_PARITY_EN"}	= $fmask & SP_PARITY_CHECK;
    $self->{"_C_RLSD_CFG"}	= $fmask & SP_RLSD;

    $fmask			= $CP_ProvCapabilities;
    $self->{"_C_RLSD"}		= $fmask & PCF_RLSD;
    $self->{"_C_PARITY_CK"}	= $fmask & PCF_PARITY_CHECK;
    $self->{"_C_DTRDSR"}	= $fmask & PCF_DTRDSR;
    $self->{"_C_16BITMODE"}	= $fmask & PCF_16BITMODE;
    $self->{"_C_RTSCTS"}	= $fmask & PCF_RTSCTS;
    $self->{"_C_XONXOFF"}	= $fmask & PCF_XONXOFF;
    $self->{"_C_XON_CHAR"}	= $fmask & PCF_SETXCHAR;
    $self->{"_C_SPECHAR"}	= $fmask & PCF_SPECIALCHARS;
    $self->{"_C_INT_TIME"}	= $fmask & PCF_INTTIMEOUTS;
    $self->{"_C_TOT_TIME"}	= $fmask & PCF_TOTALTIMEOUTS;

    if ($self->{"_C_INT_TIME"}) {
        $self->{"_N_RINT"}	= LONGsize;	# min interval default
    }
    else {
        $self->{"_N_RINT"}	= 0;
    }
    $self->{"_N_RTOT"}	= 0;
    $self->{"_N_RCONST"}	= 0;

    if ($self->{"_C_TOT_TIME"}) {
        $self->{"_N_WCONST"}	= 201;	# startup overhead + 1
        $self->{"_N_WTOT"}	= 11;	# per char out + 1
    }
    else {
        $self->{"_N_WTOT"}	= 0;
        $self->{"_N_WCONST"}	= 0;
    }

    $hr = \%{$self->{"_L_HSHAKE"}};

    if ($self->{"_C_HSHAKE"}) {
        ${$hr}{"xoff"}	= "xoff"	if ($fmask & PCF_XONXOFF);
        ${$hr}{"rts"}	= "rts"		if ($fmask & PCF_RTSCTS);
        ${$hr}{"dtr"}	= "dtr"		if ($fmask & PCF_DTRDSR);
        ${$hr}{"none"}	= "none";
    }
    else { $self->{"_N_HSHAKE"} = undef; }

#### really just using the keys here, so value = Win32_definition
#### in case we ever need it for something else

# first check for programmable baud

    $hr = \%{$self->{"_L_BAUD"}};

    if ($CP_MaxBaud & BAUD_USER) {
        $fmask		= $CP_SettableBaud;
        ${$hr}{110}	= CBR_110	if ($fmask & BAUD_110);
        ${$hr}{300}	= CBR_300	if ($fmask & BAUD_300);
        ${$hr}{600}	= CBR_600	if ($fmask & BAUD_600);
        ${$hr}{1200}	= CBR_1200	if ($fmask & BAUD_1200);
        ${$hr}{2400}	= CBR_2400	if ($fmask & BAUD_2400);
        ${$hr}{4800}	= CBR_4800	if ($fmask & BAUD_4800);
        ${$hr}{9600}	= CBR_9600	if ($fmask & BAUD_9600);
        ${$hr}{14400}	= CBR_14400	if ($fmask & BAUD_14400);
        ${$hr}{19200}	= CBR_19200	if ($fmask & BAUD_19200);
        ${$hr}{38400}	= CBR_38400	if ($fmask & BAUD_38400);
        ${$hr}{56000}	= CBR_56000	if ($fmask & BAUD_56K);
        ${$hr}{57600}	= CBR_57600	if ($fmask & BAUD_57600);
        ${$hr}{115200}	= CBR_115200	if ($fmask & BAUD_115200);
        ${$hr}{128000}	= CBR_128000	if ($fmask & BAUD_128K);
        ${$hr}{256000}	= CBR_256000	if (0); # reserved ??
    }
    else {
            # get fixed baud from CP_MaxBaud
        $fmask		= $CP_MaxBaud;
        $fix_baud	= 75   		if ($fmask & BAUD_075);
        $fix_baud	= 110  		if ($fmask & BAUD_110);
        $fix_baud	= 134.5		if ($fmask & BAUD_134_5);
        $fix_baud	= 150  		if ($fmask & BAUD_150);
        $fix_baud	= 300  		if ($fmask & BAUD_300);
        $fix_baud	= 600  		if ($fmask & BAUD_600);
        $fix_baud	= 1200 		if ($fmask & BAUD_1200);
        $fix_baud	= 1800 		if ($fmask & BAUD_1800);
        $fix_baud	= 2400 		if ($fmask & BAUD_2400);
        $fix_baud	= 4800 		if ($fmask & BAUD_4800);
        $fix_baud	= 7200 		if ($fmask & BAUD_7200);
        $fix_baud	= 9600 		if ($fmask & BAUD_9600);
        $fix_baud	= 14400		if ($fmask & BAUD_14400);
        $fix_baud	= 19200		if ($fmask & BAUD_19200);
        $fix_baud	= 34800		if ($fmask & BAUD_38400);
        $fix_baud	= 56000		if ($fmask & BAUD_56K);
        $fix_baud	= 57600		if ($fmask & BAUD_57600);
        $fix_baud	= 115200	if ($fmask & BAUD_115200);
        $fix_baud	= 128000	if ($fmask & BAUD_128K);
        ${$hr}{$fix_baud}	= $fix_baud;
        $self->{"_N_BAUD"} = undef;
    }

#### data bits

    $fmask	= $CP_SettableData;

    if ($self->{"_C_DATA"}) {

        $hr = \%{$self->{"_L_DATA"}};

        ${$hr}{5}	= 5	if ($fmask & DATABITS_5);
        ${$hr}{6}	= 6	if ($fmask & DATABITS_6);
        ${$hr}{7}	= 7	if ($fmask & DATABITS_7);
        ${$hr}{8}	= 8	if ($fmask & DATABITS_8);
        ${$hr}{16}	= 16	if ($fmask & DATABITS_16);
##      ${$hr}{16X}	= 16	if ($fmask & DATABITS_16X);
    }
    else { $self->{"_N_DATA"} = undef; }

#### value = (DCB Win32_definition + 1) so 0 means unchanged

    $fmask	= $CP_SettableStopParity;

    if ($self->{"_C_STOP"}) {

        $hr = \%{$self->{"_L_STOP"}};

        ${$hr}{1}	= 1 + ONESTOPBIT	if ($fmask & STOPBITS_10);
        ${$hr}{1.5}	= 1 + ONE5STOPBITS	if ($fmask & STOPBITS_15);
        ${$hr}{2}	= 1 + TWOSTOPBITS	if ($fmask & STOPBITS_20);
    }
    else { $self->{"_N_STOP"} = undef; }

    if ($self->{"_C_PARITY_CFG"}) {

        $hr = \%{$self->{"_L_PARITY"}};

        ${$hr}{"none"}	= 1 + NOPARITY		if ($fmask & PARITY_NONE);
        ${$hr}{"even"}	= 1 + EVENPARITY	if ($fmask & PARITY_EVEN);
        ${$hr}{"odd"}	= 1 + ODDPARITY		if ($fmask & PARITY_ODD);
        ${$hr}{"mark"}	= 1 + MARKPARITY	if ($fmask & PARITY_MARK);
        ${$hr}{"space"}	= 1 + SPACEPARITY	if ($fmask & PARITY_SPACE);
    }
    else { $self->{"_N_PARITY"} = undef; }

    $hr = 0;	# no loops

    # changable dcb parameters
    # 0 = no change requested
    # integer: requested value or (value+1 if 0 is a legal value)
    # binary: 1=false requested, 2=true requested

    $self->{"_N_FM_ON"}		= 0;
    $self->{"_N_FM_OFF"}	= 0;

    ### "VALUE" is initialized from DCB by default (but also in %validate)

    $self->{"_N_XONLIM"}     	= 0;
    $self->{"_N_XOFFLIM"}     	= 0;
    $self->{"_N_XOFFCHAR"}     	= 0;
    $self->{"_N_XONCHAR"}     	= 0;
    $self->{"_N_ERRCHAR"}     	= 0;
    $self->{"_N_EOFCHAR"}     	= 0;
    $self->{"_N_EVTCHAR"}     	= 0;
    $self->{"_N_BINARY"}     	= 0;
    $self->{"_N_PARITY_EN"}    	= 0;

    ### "_N_items" for save/start

    $self->{"_N_READBUF"}	= 0;
    $self->{"_N_WRITEBUF"}	= 0;
    $self->{"_N_HSHAKE"}	= 0;

    ### The "required" DCB values are deliberately NOT defined. That way,
    ### write_settings can verify they "exist" to assure they got set.
    ###		$self->{"_N_BAUD"}
    ###		$self->{"_N_DATA"}
    ###		$self->{"_N_STOP"}
    ###		$self->{"_N_PARITY"}


    $self->{"_R_EVENT"} = CreateEvent($null,	# no security
  	                              1,	# explicit reset req
  	                              0,	# initial event reset
  	                              $null);	# no name
    unless ($self->{"_R_EVENT"}) {
        OS_Error;
        carp "could not create required read event";
        undef $self;
        return;
    }

    $self->{"_W_EVENT"} = CreateEvent($null,	# no security
  	                              1,	# explicit reset req
  	       	                      0,	# initial event reset
  	       	                      $null);	# no name
    unless ($self->{"_W_EVENT"}) {
        OS_Error;
        carp "could not create required write event";
        undef $self;
        return;
    }
    $self->{"_R_OVERLAP"} = pack($OVERLAPPEDformat,
          			 $zero,		# osRead_Internal,
          			 $zero,		# osRead_InternalHigh,
          			 $zero,		# osRead_Offset,
          			 $zero,		# osRead_OffsetHigh,
				 $self->{"_R_EVENT"});
  
    $self->{"_W_OVERLAP"} = pack($OVERLAPPEDformat,
          			 $zero,		# osWrite_Internal,
          			 $zero,		# osWrite_InternalHigh,
          			 $zero,		# osWrite_Offset,
          			 $zero,		# osWrite_OffsetHigh,
				 $self->{"_W_EVENT"});

        # Device Control Block (DCB)
    unless ( fetch_DCB ($self) ) {
        carp "can't read Device Control Block for $self->{NAME}\n";
        undef $self;
        return;
    }
    $self->{"_L_BAUD"}{$self->{BAUD}} = $self->{BAUD}; # actual must be ok

	# Read Timeouts
    unless ( GetCommTimeouts($self->{"_HANDLE"}, $self->{"_TIMEOUT"}) ) {
        carp "Error in GetCommTimeouts";
        undef $self;
        return;
    }

    ($self->{RINT},
     $self->{RTOT},
     $self->{RCONST},
     $self->{WTOT},
     $self->{WCONST})= unpack($TIMEOUTformat, $self->{"_TIMEOUT"});

    bless ($self, $class);
    return $self;
}

sub fetch_DCB {
    my $self = shift;
    my $ok;
    my $hr;
    my $fmask;
    my $key;
    my $value;
    my $dcb = " "x32;

    GetCommState($self->{"_HANDLE"}, $dcb) or return;

    ($self->{"_DCBLength"},
     $self->{BAUD},
     $self->{"_BitMask"},
     $self->{"_ResvWORD"},
     $self->{XONLIM},
     $self->{XOFFLIM},
     $self->{DATA},
     $self->{"_Parity"},
     $self->{"_StopBits"},
     $self->{XONCHAR},
     $self->{XOFFCHAR},
     $self->{ERRCHAR},
     $self->{EOFCHAR},
     $self->{EVTCHAR},
     $self->{"_PackWORD"})= unpack($DCBformat, $dcb);

    if ($self->{"_DCBLength"} > 32) {
        carp "invalid DCB block length";
        return;
    }

    if ($Babble) {
        printf "DCBLength= %d\n", $self->{"_DCBLength"};
        printf "BaudRate= %d\n", $self->{BAUD};
        printf "BitMask= %lx\n", $self->{"_BitMask"};
        printf "ResvWORD= %x\n", $self->{"_ResvWORD"};
        printf "XonLim= %x\n", $self->{XONLIM};
        printf "XoffLim= %x\n", $self->{XOFFLIM};
        printf "ByteSize= %d\n", $self->{DATA};
        printf "Parity= %d\n", $self->{"_Parity"};
        printf "StopBits= %d\n", $self->{"_StopBits"};
        printf "XonChar= %x\n", $self->{XONCHAR};
        printf "XoffChar= %x\n", $self->{XOFFCHAR};
        printf "ErrorChar= %x\n", $self->{ERRCHAR};
        printf "EofChar= %x\n", $self->{EOFCHAR};
        printf "EvtChar= %x\n", $self->{EVTCHAR};
        printf "PackWORD= %x\n", $self->{"_PackWORD"};
        printf "handle= %d\n\n", $self->{"_HANDLE"};
    }

    $fmask = 1 + $self->{"_StopBits"};
    while (($key, $value) = each %{ $self->{"_L_STOP"} }) {
        if ($value == $fmask) {
	   $self->{STOP}	= $key;
	}
    }

    $fmask = 1 + $self->{"_Parity"};
    while (($key, $value) = each %{ $self->{"_L_PARITY"} }) {
        if ($value == $fmask) {
           $self->{PARITY}	= $key;
	}
    }

    $fmask = $self->{"_BitMask"};

    $hr = DTR_CONTROL_HANDSHAKE;
    $ok = RTS_CONTROL_HANDSHAKE;

    if ($fmask & ( $hr << 4) ) {
        $self->{HSHAKE} = "dtr";
    }
    elsif ($fmask & ( $ok << 12) ) {
        $self->{HSHAKE} = "rts";
    }
    elsif ($fmask & ( FM_fOutX | FM_fInX ) ) {
        $self->{HSHAKE} = "xoff";
    }
    else {
        $self->{HSHAKE} = "none";
    }

    $self->{BINARY} = ($fmask & FM_fBinary);
    $self->{PARITY_EN} = ($fmask & FM_fParity);

    if ($fmask & FM_fDummy2) {
        carp "Unknown DCB Flow Mask Bit in $self->{NAME}";
    }
    1;
}

sub init_done {
    my $self = shift;
    return 0 unless (defined $self->{"_INIT"});
    return $self->{"_INIT"};
}
    

sub update_DCB {
    my $self = shift;
    my $ok = 0;

    return unless (defined $self->{"_INIT"});

    fetch_DCB ($self);

    if ($self->{"_N_HSHAKE"}) {
        $self->{HSHAKE} = $self->{"_N_HSHAKE"};
        if ($self->{HSHAKE} eq "dtr" ) {
            $self->{"_N_FM_ON"}		= 0x1028;
            $self->{"_N_FM_OFF"}	= 0xffffdfeb;
	}
        elsif ($self->{HSHAKE} eq "rts" ) {
            $self->{"_N_FM_ON"}		= 0x2014;
            $self->{"_N_FM_OFF"}	= 0xffffefd7;
	}
        elsif ($self->{HSHAKE} eq "xoff" ) {
            $self->{"_N_FM_ON"}		= 0x1310;
            $self->{"_N_FM_OFF"}	= 0xffffdfd3;
	}
        else {
            $self->{"_N_FM_ON"}		= 0x1010;
            $self->{"_N_FM_OFF"}	= 0xffffdcd3;
	}
        $self->{"_N_HSHAKE"} = 0;
    }

    if ($self->{"_N_PARITY_EN"}) {
        if (2 == $self->{"_N_PARITY_EN"}) {
            $self->{"_N_FM_ON"}		|= FM_fParity;		# enable
            if ($self->{"_N_FM_OFF"}) {
                $self->{"_N_FM_OFF"}	|= FM_fParity;
	    }
            else { $self->{"_N_FM_OFF"}	= LONGsize; }
	}
	else {
            if ($self->{"_N_FM_ON"}) {
                $self->{"_N_FM_ON"}	&= ~FM_fParity;		# disable
	    }
            if ($self->{"_N_FM_OFF"}) {
                $self->{"_N_FM_OFF"}	&= ~FM_fParity;
	    }
            else { $self->{"_N_FM_OFF"}	= ~FM_fParity; }
	}
	### printf "_N_FM_ON=%lx\n", $self->{"_N_FM_ON"}; ###
	### printf "_N_FM_OFF=%lx\n", $self->{"_N_FM_OFF"}; ###
        $self->{"_N_PARITY_EN"} = 0;
    }

    if ( $self->{"_N_FM_ON"} or $self->{"_N_FM_OFF"} ) {
        $self->{"_BitMask"}	&= $self->{"_N_FM_OFF"};
        $self->{"_BitMask"}	|= $self->{"_N_FM_ON"};
        $self->{"_N_FM_ON"}	= 0;
        $self->{"_N_FM_OFF"}	= 0;
    }

    if ($self->{"_N_XONLIM"}) {
        $self->{XONLIM} = $self->{"_N_XONLIM"} - 1;
        $self->{"_N_XONLIM"} = 0;
    }

    if ($self->{"_N_XOFFLIM"}) {
        $self->{XOFFLIM} = $self->{"_N_XOFFLIM"} - 1;
        $self->{"_N_XOFFLIM"} = 0;
    }

    if ($self->{"_N_BAUD"}) {
        $self->{BAUD} = $self->{"_N_BAUD"};
        $self->{"_N_BAUD"} = 0;
    }

    if ($self->{"_N_DATA"}) {
        $self->{DATA} = $self->{"_N_DATA"};
        $self->{"_N_DATA"} = 0;
    }

    if ($self->{"_N_STOP"}) {
        $self->{"_StopBits"} = $self->{"_N_STOP"} - 1;
        $self->{"_N_STOP"} = 0;
    }

    if ($self->{"_N_PARITY"}) {
        $self->{"_Parity"} = $self->{"_N_PARITY"} - 1;
        $self->{"_N_PARITY"} = 0;
    }

    if ($self->{"_N_XONCHAR"}) {
        $self->{XONCHAR} = $self->{"_N_XONCHAR"} - 1;
        $self->{"_N_XONCHAR"} = 0;
    }

    if ($self->{"_N_XOFFCHAR"}) {
        $self->{XOFFCHAR} = $self->{"_N_XOFFCHAR"} - 1;
        $self->{"_N_XOFFCHAR"} = 0;
    }

    if ($self->{"_N_ERRCHAR"}) {
        $self->{ERRCHAR} = $self->{"_N_ERRCHAR"} - 1;
        $self->{"_N_ERRCHAR"} = 0;
    }

    if ($self->{"_N_EOFCHAR"}) {
        $self->{EOFCHAR} = $self->{"_N_EOFCHAR"} - 1;
        $self->{"_N_EOFCHAR"} = 0;
    }

    if ($self->{"_N_EVTCHAR"}) {
        $self->{EVTCHAR} = $self->{"_N_EVTCHAR"} - 1;
        $self->{"_N_EVTCHAR"} = 0;
    }

    my $dcb = pack($DCBformat,
		   $self->{"_DCBLength"},
		   $self->{BAUD},
		   $self->{"_BitMask"},
		   $self->{"_ResvWORD"},
		   $self->{XONLIM},
		   $self->{XOFFLIM},
		   $self->{DATA},
		   $self->{"_Parity"},
		   $self->{"_StopBits"},
		   $self->{XONCHAR},
		   $self->{XOFFCHAR},
		   $self->{ERRCHAR},
		   $self->{EOFCHAR},
		   $self->{EVTCHAR},
		   $self->{"_PackWORD"});

    if ( SetCommState($self->{"_HANDLE"}, $dcb) ) {
        print "updated DCB for $self->{NAME}\n" if ($Babble);
    }
    else {
	carp "SetCommState failed";
        OS_Error;
        if ($Babble) {
	    printf "\ntried to write:\n";
            printf "DCBLength= %d\n", $self->{"_DCBLength"};
            printf "BaudRate= %d\n", $self->{BAUD};
            printf "BitMask= %lx\n", $self->{"_BitMask"};
            printf "ResvWORD= %x\n", $self->{"_ResvWORD"};
            printf "XonLim= %x\n", $self->{XONLIM};
            printf "XoffLim= %x\n", $self->{XOFFLIM};
            printf "ByteSize= %d\n", $self->{DATA};
            printf "Parity= %d\n", $self->{"_Parity"};
            printf "StopBits= %d\n", $self->{"_StopBits"};
            printf "XonChar= %x\n", $self->{XONCHAR};
            printf "XoffChar= %x\n", $self->{XOFFCHAR};
            printf "ErrorChar= %x\n", $self->{ERRCHAR};
            printf "EofChar= %x\n", $self->{EOFCHAR};
            printf "EvtChar= %x\n", $self->{EVTCHAR};
            printf "PackWORD= %x\n", $self->{"_PackWORD"};
            printf "handle= %d\n", $self->{"_HANDLE"};
        }
    }
}

sub initialize {
    my $self = shift;
    my $item;
    my $fault = 0;
    foreach $item (@_) {
        unless (exists $self->{"_N_$item"}) {
            # must be "exists" so undef=not_settable
            $fault++;
            nocarp or carp "Missing REQUIRED setting for $item";
        }
    }
    unless ($self->{"_INIT"}) {
        $self->{"_INIT"}	= 1	 unless ($fault);
        $self->{"_BitMask"}	= 0x1011;
        $self->{XONLIM}		= 100	 unless ($self->{"_N_XONLIM"});
        $self->{XOFFLIM}	= 100	 unless ($self->{"_N_XOFFLIM"});
        $self->{XONCHAR}	= 0x11	 unless ($self->{"_N_XONCHAR"});
        $self->{XOFFCHAR}	= 0x13	 unless ($self->{"_N_XOFFCHAR"});
        $self->{ERRCHAR}	= 0	 unless ($self->{"_N_ERRCHAR"});
        $self->{EOFCHAR}	= 0	 unless ($self->{"_N_EOFCHAR"});
        $self->{EVTCHAR}	= 0	 unless ($self->{"_N_EVTCHAR"});

        update_timeouts($self);
    }

    if ($self->{"_N_READBUF"} or $self->{"_N_WRITEBUF"}) {
        if ($self->{"_N_READBUF"}) {
            $self->{READBUF} = $self->{"_N_READBUF"};
	}
        if ($self->{"_N_WRITEBUF"}) {
            $self->{WRITEBUF} = $self->{"_N_WRITEBUF"};
	}
        $self->{"_N_READBUF"} = 0;
        $self->{"_N_WRITEBUF"} = 0;
	SetupComm($self->{"_HANDLE"}, $self->{READBUF}, $self->{WRITEBUF});
    }
    purge_all($self);
    return $fault;
}    

sub is_status {
    my $self		= shift;
    my $ok		= 0;
    my $error_p		= " "x4;
    my $CommStatus	= " "x12;

    if (@_ and $testactive) {
        $self->{"_LATCH"} |= shift;
    }

    $ok=ClearCommError($self->{"_HANDLE"}, $error_p, $CommStatus);

    my $Error_BitMask	= unpack("L", $error_p);
    $self->{"_LATCH"} |= $Error_BitMask;
    my @stat = unpack($COMSTATformat, $CommStatus);
    push @stat, $self->{"_LATCH"};

    $stat[ST_BLOCK] &= BM_AllBits;
    if ( $Babble or $self->{"_DEBUG_C"} ) {
        printf "Blocking Bits= %d\n", $stat[ST_BLOCK];
        printf "Input Queue= %d\n", $stat[ST_INPUT];
        printf "Output Queue= %d\n", $stat[ST_OUTPUT];
        printf "Latched Errors= %d\n", $stat[ST_ERROR];
        printf "ok= %d\n", $ok;
    }
    return ($ok ? @stat : undef);
}

sub reset_error {
    my $self = shift;
    my $was  = $self->{"_LATCH"};
    $self->{"_LATCH"} = 0;
    return $was;
}

sub can_baud {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_BAUD"};
}

sub can_databits {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_DATA"};
}

sub can_stopbits {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_STOP"};
}

sub can_dtrdsr {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_DTRDSR"};
}

sub can_handshake {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_HSHAKE"};
}

sub can_parity_check {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_PARITY_CK"};
}

sub can_parity_config {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_PARITY_CFG"};
}

sub can_parity_enable {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_PARITY_EN"};
}

sub can_rlsd_config {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_RLSD_CFG"};
}

sub can_rlsd {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_RLSD"};
}

sub can_16bitmode {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_16BITMODE"};
}

sub is_rs232 {
    my $self = shift;
    return wantarray ? @binary_opt : ($self->{"_TYPE"} == PST_RS232);
}

sub is_modem {
    my $self = shift;
    return wantarray ? @binary_opt : ($self->{"_TYPE"} == PST_MODEM);
}

sub can_rtscts {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_RTSCTS"};
}

sub can_xonxoff {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_XONXOFF"};
}

sub can_xon_char {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_XON_CHAR"};
}

sub can_spec_char {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_SPECHAR"};
}

sub can_interval_timeout {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_INT_TIME"};
}

sub can_total_timeout {
    my $self = shift;
    return wantarray ? @binary_opt : $self->{"_C_TOT_TIME"};
}

sub is_handshake {
    my $self = shift;
    if (@_) {
        return unless $self->{"_C_HSHAKE"};
        return unless (defined $self->{"_L_HSHAKE"}{$_[0]});
        $self->{"_N_HSHAKE"} = $self->{"_L_HSHAKE"}{$_[0]};
        update_DCB ($self);
    }
    return unless fetch_DCB ($self);
    return $self->{HSHAKE};
}

sub are_handshake {
    my $self = shift;
    return unless $self->{"_C_HSHAKE"};
    return if (@_);
    return keys(%{$self->{"_L_HSHAKE"}});
}

sub is_baudrate {
    my $self = shift;
    if (@_) {
        return unless $self->{"_C_BAUD"};
        return unless (defined $self->{"_L_BAUD"}{$_[0]});
        $self->{"_N_BAUD"} = int shift;
        update_DCB ($self);
    }
    return unless fetch_DCB ($self);
    return $self->{BAUD};
}

sub are_baudrate {
    my $self = shift;
    return unless $self->{"_C_BAUD"};
    return if (@_);
    return keys(%{$self->{"_L_BAUD"}});
}

sub is_parity {
    my $self = shift;
    if (@_) {
        return unless $self->{"_C_PARITY_CFG"};
        return unless (defined $self->{"_L_PARITY"}{$_[0]});
        $self->{"_N_PARITY"} = $self->{"_L_PARITY"}{$_[0]};
        update_DCB ($self);
    }
    return unless fetch_DCB ($self);
    return $self->{PARITY};
}

sub are_parity {
    my $self = shift;
    return unless $self->{"_C_PARITY_CFG"};
    return if (@_);
    return keys(%{$self->{"_L_PARITY"}});
}

sub is_databits {
    my $self = shift;
    if (@_) {
        return unless $self->{"_C_DATA"};
        return unless (defined $self->{"_L_DATA"}{$_[0]});
        $self->{"_N_DATA"} = $self->{"_L_DATA"}{$_[0]};
        update_DCB ($self);
    }
    return unless fetch_DCB ($self);
    return $self->{DATA};
}

sub are_databits {
    my $self = shift;
    return unless $self->{"_C_DATA"};
    return if (@_);
    return keys(%{$self->{"_L_DATA"}});
}

sub is_stopbits {
    my $self = shift;
    if (@_) {
        return unless $self->{"_C_STOP"};
        return unless (defined $self->{"_L_STOP"}{$_[0]});
        $self->{"_N_STOP"} = $self->{"_L_STOP"}{$_[0]};
        update_DCB ($self);
    }
    return unless fetch_DCB ($self);
    return $self->{STOP};
}

sub are_stopbits {
    my $self = shift;
    return unless $self->{"_C_STOP"};
    return if (@_);
    return keys(%{$self->{"_L_STOP"}});
}

# single value for save/start
sub is_read_buf {
    my $self = shift;
    if (@_) { $self->{"_N_READBUF"} = int shift; }
    return $self->{READBUF};
}

# single value for save/start
sub is_write_buf {
    my $self = shift;
    if (@_) { $self->{"_N_WRITEBUF"} = int shift; }
    return $self->{WRITEBUF};
}

sub is_buffers {
    my $self = shift;

    return unless (@_ == 2);
    my $rbuf = shift;
    my $wbuf = shift;
    SetupComm($self->{"_HANDLE"}, $rbuf, $wbuf) or return;
    $self->{"_N_READBUF"}	= 0;
    $self->{"_N_WRITEBUF"}	= 0;
    $self->{READBUF}		= $rbuf;
    $self->{WRITEBUF}		= $wbuf;
    1;
}

sub read_bg {
    return unless (@_ == 2);
    my $self = shift;
    my $wanted = shift;
    return unless ($wanted > 0);
    if ($self->{"_R_BUSY"}) {
	nocarp or carp "Second Read attempted before First is done";
	return;
    }
    my $got_p = " "x4;
    my $ok;
    my $got = 0;
    if ($wanted > 4096) {
        $wanted = 4096;
        warn "read buffer limited to 4096 bytes at the moment";
    }
    $self->{"_R_BUSY"} = 1;

    $ok=ReadFile( $self->{"_HANDLE"},
    		  $self->{"_RBUF"},
		  $wanted,
		  $got_p,
		  $self->{"_R_OVERLAP"});

    if ($ok) {
        $got = unpack("L", $got_p);
        $self->{"_R_BUSY"} = 0;
    }
    return $got;
}

sub write_bg {
    return unless (@_ == 2);
    my $self = shift;
    my $wbuf = shift;
    if ($self->{"_W_BUSY"}) {
	nocarp or carp "Second Write attempted before First is done";
	return;
    }
    my $ok;
    my $got_p = " "x4;
    return 0 if ($wbuf eq "");
    my $lbuf = length ($wbuf);
    my $written = 0;
    $self->{"_W_BUSY"} = 1;

    $ok=WriteFile( $self->{"_HANDLE"},
		   $wbuf,
		   $lbuf,
		   $got_p,
		   $self->{"_W_OVERLAP"});

    if ($ok) {
        $written = unpack("L", $got_p);
        $self->{"_W_BUSY"} = 0;
    }
    if ($Babble) {
	print "error=$ok\n";
	print "wbuf=$wbuf\n";
	print "lbuf=$lbuf\n";
	print "write_bg=$written\n";
    }
    return $written;
}

sub read_done {
    return unless (@_ == 2);
    my $self = shift;
    my $wait = yes_true ( shift );
    my $ov;
    my $got_p = " "x4;
    my $wanted = 0;
    $self->{"_R_BUSY"} = 1;

    $ov=GetOverlappedResult( $self->{"_HANDLE"},
			     $self->{"_R_OVERLAP"},
			     $got_p,
			     $wait);
    if ($ov) {
        $wanted = unpack("L", $got_p);
	$self->{"_R_BUSY"} = 0;
	print "read_done=$wanted\n" if ($Babble);
        return (1, $wanted, substr($self->{"_RBUF"}, 0, $wanted));
    }
    return (0, 0, "");
}

sub write_done {
    return unless (@_ == 2);
    my $self = shift;
    my $wait = yes_true ( shift );
    my $ov;
    my $got_p = " "x4;
    my $written = 0;
    $self->{"_W_BUSY"} = 1;

    $ov=GetOverlappedResult( $self->{"_HANDLE"},
			     $self->{"_W_OVERLAP"},
			     $got_p,
			     $wait);
    if ($ov) {
        $written = unpack("L", $got_p);
	$self->{"_W_BUSY"} = 0;
	print "write_done=$written\n" if ($Babble);
        return (1, $written);
    }
    return (0, $written);
}

sub purge_all {
    my $self = shift;
    return if (@_);

    # PURGE_TXABORT | PURGE_RXABORT | PURGE_TXCLEAR | PURGE_RXCLEAR
    unless ( PurgeComm($self->{"_HANDLE"}, 0x0000000f) ) {
        carp "Error in PurgeComm";
        OS_Error;
	return;
    }
    $self->{"_R_BUSY"} = 0;
    $self->{"_W_BUSY"} = 0;
    return 1;
}

sub purge_rx {
    my $self = shift;
    return if (@_);

    # PURGE_RXABORT | PURGE_RXCLEAR
    unless ( PurgeComm($self->{"_HANDLE"}, 0x0000000a) ) {
        OS_Error;
        carp "Error in PurgeComm";
	return;
    }
    $self->{"_R_BUSY"} = 0;
    return 1;
}

sub purge_tx {
    my $self = shift;
    return if (@_);

    # PURGE_TXABORT | PURGE_TXCLEAR
    unless ( PurgeComm($self->{"_HANDLE"}, 0x00000005) ) {
        OS_Error;
        carp "Error in PurgeComm";
	return;
    }
    $self->{"_W_BUSY"} = 0;
    return 1;
}

sub are_buffers {
    my $self = shift;
    return if (@_);
    return ($self->{READBUF}, $self->{WRITEBUF});
}

sub buffer_max {
    my $self = shift;
    return if (@_);
    return ($self->{"_RBUFMAX"}, $self->{"_TBUFMAX"});
}

sub suspend_tx {
    my $self = shift;
    return if (@_);
    return SetCommBreak($self->{"_HANDLE"});
}

sub resume_tx {
    my $self = shift;
    return if (@_);
    return ClearCommBreak($self->{"_HANDLE"});
}

sub xmit_imm_char {
    my $self = shift;
    return unless (@_ == 1);
    my $v = int shift;
    unless ( TransmitCommChar($self->{"_HANDLE"}, $v) ) {
	carp "Can't transmit char: $v";
	return;
    }
    1;
}

sub is_xon_char {
    my $self = shift;
    if ((@_ == 1) and $self->{"_C_XON_CHAR"}) {
        $self->{"_N_XONCHAR"} = 1 + shift;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{XONCHAR};
}

sub is_xoff_char {
    my $self = shift;
    if ((@_ == 1) and $self->{"_C_XON_CHAR"}) {
        $self->{"_N_XOFFCHAR"} = 1 + shift;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{XOFFCHAR};
}

sub is_eof_char {
    my $self = shift;
    if ((@_ == 1) and $self->{"_C_SPECHAR"}) {
        $self->{"_N_EOFCHAR"} = 1 + shift;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{EOFCHAR};
}

sub is_event_char {
    my $self = shift;
    if ((@_ == 1) and $self->{"_C_SPECHAR"}) {
        $self->{"_N_EVTCHAR"} = 1 + shift;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{EVTCHAR};
}

sub is_error_char {
    my $self = shift;
    if ((@_ == 1) and $self->{"_C_SPECHAR"}) {
        $self->{"_N_ERRCHAR"} = 1 + shift;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{ERRCHAR};
}

sub is_xon_limit {
    my $self = shift;
    if (@_) {
	return unless ($self->{"_C_XONXOFF"});
	my $v = int shift;
	return if (($v < 0) or ($v > SHORTsize));
        $self->{"_N_XONLIM"} = ++$v;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{XONLIM};
}

sub is_xoff_limit {
    my $self = shift;
    if (@_) {
	return unless ($self->{"_C_XONXOFF"});
	my $v = int shift;
	return if (($v < 0) or ($v > SHORTsize));
        $self->{"_N_XOFFLIM"} = ++$v;
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    return $self->{XOFFLIM};
}

sub is_read_interval {
    my $self = shift;
    if (@_) {
        return unless ($self->{"_C_INT_TIME"});
	my $v = int shift;
	return if (($v < 0) or ($v > LONGsize));
        if ($v == LONGsize) {
            $self->{"_N_RINT"} = $v; # Win32 uses as flag
	}
	else {
            $self->{"_N_RINT"} = ++$v;
	}
        return unless update_timeouts ($self);
    }
    return $self->{RINT};
}

sub is_read_char_time {
    my $self = shift;
    if (@_) {
        return unless ($self->{"_C_TOT_TIME"});
	my $v = int shift;
	return if (($v < 0) or ($v >= LONGsize));
        $self->{"_N_RTOT"} = ++$v;
        return unless update_timeouts ($self);
    }
    return $self->{RTOT};
}

sub is_read_const_time {
    my $self = shift;
    if (@_) {
        return unless ($self->{"_C_TOT_TIME"});
	my $v = int shift;
	return if (($v < 0) or ($v >= LONGsize));
        $self->{"_N_RCONST"} = ++$v;
        return unless update_timeouts ($self);
    }
    return $self->{RCONST};
}

sub is_write_const_time {
    my $self = shift;
    if (@_) {
        return unless ($self->{"_C_TOT_TIME"});
	my $v = int shift;
	return if (($v < 0) or ($v >= LONGsize));
        $self->{"_N_WCONST"} = ++$v;
        return unless update_timeouts ($self);
    }
    return $self->{WCONST};
}

sub is_write_char_time {
    my $self = shift;
    if (@_) {
        return unless ($self->{"_C_TOT_TIME"});
	my $v = int shift;
	return if (($v < 0) or ($v >= LONGsize));
        $self->{"_N_WTOT"} = ++$v;
        return unless update_timeouts ($self);
    }
    return $self->{WTOT};
}

sub update_timeouts {
    return unless (@_ == 1);
    my $self = shift;
    unless ( GetCommTimeouts($self->{"_HANDLE"}, $self->{"_TIMEOUT"}) ) {
        carp "Error in GetCommTimeouts";
        return;
    }

    ($self->{RINT},
     $self->{RTOT},
     $self->{RCONST},
     $self->{WTOT},
     $self->{WCONST})= unpack($TIMEOUTformat, $self->{"_TIMEOUT"});

    if ($self->{"_N_RINT"}) {
        if ($self->{"_N_RINT"} == LONGsize) {
            $self->{RINT} = $self->{"_N_RINT"}; # Win32 uses as flag
	}
	else {
            $self->{RINT} = $self->{"_N_RINT"} -1;
	}
        $self->{"_N_RINT"} = 0;
    }

    if ($self->{"_N_RTOT"}) {
        $self->{RTOT} = $self->{"_N_RTOT"} -1;
        $self->{"_N_RTOT"} = 0;
    }

    if ($self->{"_N_RCONST"}) {
        $self->{RCONST} = $self->{"_N_RCONST"} -1;
        $self->{"_N_RCONST"} = 0;
    }

    if ($self->{"_N_WTOT"}) {
        $self->{WTOT} = $self->{"_N_WTOT"} -1;
        $self->{"_N_WTOT"} = 0;
    }

    if ($self->{"_N_WCONST"}) {
        $self->{WCONST} = $self->{"_N_WCONST"} -1;
        $self->{"_N_WCONST"} = 0;
    }

    $self->{"_TIMEOUT"} = pack($TIMEOUTformat,
		               $self->{RINT},
		               $self->{RTOT},
		               $self->{RCONST},
		               $self->{WTOT},
		               $self->{WCONST});

    if ( SetCommTimeouts($self->{"_HANDLE"}, $self->{"_TIMEOUT"}) ) {
	return 1;
    }
    else {
        carp "Error in SetCommTimeouts";
        return;
    }
}


  # true/false parameters

sub is_binary {
    my $self = shift;
    if (@_) {
        $self->{"_N_BINARY"} = 1 + yes_true ( shift );
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    ### printf "_BitMask=%lx\n", $self->{"_BitMask"}; ###
    return ($self->{"_BitMask"} & FM_fBinary);
}

sub is_parity_enable {
    my $self = shift;
    if (@_) {
        $self->{"_N_PARITY_EN"} = 1 + yes_true ( shift );
        update_DCB ($self);
    }
    else {
        return unless fetch_DCB ($self);
    }
    ### printf "_BitMask=%lx\n", $self->{"_BitMask"}; ###
    return ($self->{"_BitMask"} & FM_fParity);
}

sub dtr_active {
    return unless (@_ == 2);
    my $self = shift;
    my $onoff = yes_true ( shift ) ? SETDTR : CLRDTR ;
    my $ok = EscapeCommFunction($self->{"_HANDLE"}, $onoff);
    return wantarray ? @binary_opt : $ok;
}

sub rts_active {
    return unless (@_ == 2);
    my $self = shift;
    my $onoff = yes_true ( shift ) ? SETRTS : CLRRTS ;
    my $ok = EscapeCommFunction($self->{"_HANDLE"}, $onoff);
    return wantarray ? @binary_opt : $ok;
}

sub break_active {
    return unless (@_ == 2);
    my $self = shift;
    my $onoff = yes_true ( shift ) ? SETBREAK : CLRBREAK ;
    my $ok = EscapeCommFunction($self->{"_HANDLE"}, $onoff);
    return wantarray ? @binary_opt : $ok;
}

sub xon_active {
    return unless (@_ == 1);
    my $self = shift;
    return EscapeCommFunction($self->{"_HANDLE"}, SETXON);
}

sub xoff_active {
    return unless (@_ == 1);
    my $self = shift;
    return EscapeCommFunction($self->{"_HANDLE"}, SETXOFF);
}

sub is_modemlines {
    return unless (@_ == 1);
    my $self = shift;
    my $mstat = " " x4;
    unless ( GetCommModemStatus($self->{"_HANDLE"}, $mstat) ) {
        carp "Error in GetCommModemStatus";
        return;
    }
    my $result = unpack ("L", $mstat);
    return $result;
}

sub debug_comm {
    my $self = shift;
    if (ref($self))  {
        if (@_) { $self->{"_DEBUG_C"} = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
            nocarp or carp "Debug level: $self->{NAME} = $self->{\"_DEBUG_C\"}";
            return $self->{"_DEBUG_C"};
        }
    } else {
        if (@_) { $Babble = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
            nocarp or carp "Debug Class = $Babble";
            return $Babble;
        }
    }
}

sub close {
    my $self = shift;
    my $ok;

    return unless (defined $self->{NAME});

    if ($Babble) {
        carp "Closing $self " . $self->{NAME};
    }
    if ($self->{"_HANDLE"}) {
        purge_all ($self);
        update_timeouts ($self);			# if any running ??
        $ok=CloseHandle($self->{"_HANDLE"});
        if ($Babble) {
            print "Closing handle $self->{\"_HANDLE\"} for $self->{NAME}\n";
        }
        $self->{"_HANDLE"} = undef;
    }
    if ($self->{"_R_EVENT"}) {
        $ok=CloseHandle($self->{"_R_EVENT"});
        $self->{"_R_EVENT"} = undef;
    }
    if ($self->{"_W_EVENT"}) {
        $ok=CloseHandle($self->{"_W_EVENT"});
        $self->{"_W_EVENT"} = undef;
    }
    # Microsoft samples never check the result either!
    $self->{NAME} = undef;
}

sub DESTROY {
    my $ok;
    my $self = shift;

    return unless (defined $self->{NAME});

    if ($Babble or $self->{"_DEBUG_C"}) {
        carp "Destroying $self->{NAME}";
    }
    $self->close;
}

1;  # so the require or use succeeds

# Autoload methods go after =cut, and are processed by the autosplit program.

__END__

=pod

=head1 NAME

Win32API::CommPort - Raw Win32 system API calls for serial communications.

=head1 SYNOPSIS

  use Win32;
  require 5.003;
  use Win32API::CommPort qw( :STAT 0.12 );

  ## when available ##  use Win32API::File 0.05 qw( :ALL );

=head2 Constructors

  $PortObj = new Win32API::CommPort ($PortName)
       || die "Can't open $PortName: $^E\n";

  @required = qw( BAUD DATA STOP );
  $faults = $PortObj->initialize(@required);
  if ($faults) { die "Required parameters not set before initialize\n"; }

=head2 Configuration Utility Methods

  set_no_messages;			# test suite use
  nocarp || carp "Something fishy";

  $a = SHORTsize;			# 0xffff
  $a = LONGsize;			# 0xffffffff
  $answer = Yes_true("choice");		# 1 or 0

  OS_Error unless ($API_Call_OK);	# prints error

  $PortObj->init_done  || die "Not done";

  $PortObj->fetch_DCB  || die "Not done";
  $PortObj->update_DCB || die "Not done";

=head2 Capability Methods (read only)

     # true/false capabilities
  $a = $PortObj->can_baud;     	# else fixed
  $a = $PortObj->can_databits;
  $a = $PortObj->can_stopbits;
  $a = $PortObj->can_dtrdsr;
  $a = $PortObj->can_handshake;
  $a = $PortObj->can_parity_check;
  $a = $PortObj->can_parity_config;
  $a = $PortObj->can_parity_enable;
  $a = $PortObj->can_rlsd;    	 # receive line signal detect (carrier)
  $a = $PortObj->can_rlsd_config;
  $a = $PortObj->can_16bitmode;
  $a = $PortObj->is_rs232;
  $a = $PortObj->is_modem;
  $a = $PortObj->can_rtscts;
  $a = $PortObj->can_xonxoff;
  $a = $PortObj->can_xon_char;
  $a = $PortObj->can_spec_char;
  $a = $PortObj->can_interval_timeout;
  $a = $PortObj->can_total_timeout;

     # list output capabilities
  ($rmax, $wmax) = $PortObj->buffer_max;
  ($rbuf, $wbuf) = $PortObj->are_buffers;	# current
  @choices = $PortObj->are_baudrate;		# legal values
  @choices = $PortObj->are_handshake;
  @choices = $PortObj->are_parity;
  @choices = $PortObj->are_databits;
  @choices = $PortObj->are_stopbits;

=head2 Configuration Methods

     # most methods can be called two ways:
  $PortObj->is_handshake("xoff");           # set parameter
  $flowcontrol = $PortObj->is_handshake;    # current value (scalar)

     # similar
  $PortObj->is_baudrate(9600);
  $PortObj->is_parity("odd");
  $PortObj->is_databits(8);
  $PortObj->is_stopbits(1.5);
  $PortObj->debug_comm(0);
  $PortObj->is_xon_limit(100);      # bytes left in buffer
  $PortObj->is_xoff_limit(100);     # space left in buffer
  $PortObj->is_xon_char(0x11);
  $PortObj->is_xoff_char(0x13);
  $PortObj->is_eof_char(0x0);
  $PortObj->is_event_char(0x0);
  $PortObj->is_error_char(0);       # for parity errors

  $rbuf = $PortObj->is_read_buf;    # read_only except internal use
  $wbuf = $PortObj->is_write_buf;

  $PortObj->is_buffers(4096, 4096);  # read, write
	# returns current in list context

  $PortObj->is_read_interval(100);    # max time between read char (millisec)
  $PortObj->is_read_char_time(5);     # avg time between read char
  $PortObj->is_read_const_time(100);  # total = (avg * bytes) + const 
  $PortObj->is_write_char_time(5);
  $PortObj->is_write_const_time(100);

  $PortObj->is_binary(T);		# just say Yes (Win 3.x option)
  $PortObj->is_parity_enable(F);	# faults during input

=head2 Operating Methods

  ($BlockingFlags, $InBytes, $OutBytes, $LatchErrorFlags) = $PortObj->is_status
	|| warn "could not get port status\n";

  $ClearedErrorFlags = $PortObj->reset_error;
        # The API resets errors when reading status, $LatchErrorFlags
	# is all $ErrorFlags since they were last explicitly cleared

  if ($BlockingFlags) { warn "Port is blocked"; }
  if ($BlockingFlags & BM_fCtsHold) { warn "Waiting for CTS"; }
  if ($LatchErrorFlags & CE_FRAME) { warn "Framing Error"; }

Additional useful constants may be exported eventually.

  $count_in = $PortObj->read_bg($InBytes);
  ($done, $count_in, $string_in) = $PortObj->read_done(1);
	# background read with wait until done

  $count_out = $PortObj->write_bg($output_string);	# background write
  ($done, $count_out) = $PortObj->write_done(0);

  $PortObj->suspend_tx;			# output from write buffer
  $PortObj->resume_tx;
  $PortObj->xmit_imm_char(0x03);	# bypass buffer (and suspend)

  $PortObj->dtr_active(T);		# direct to hardware
  $PortObj->rts_active(Yes);		# returns status of API call
  $PortObj->break_active(N);		# NOT state of bit

  $PortObj->xoff_active;		# simulate received xoff
  $PortObj->xon_active;			# simulate received xon

  $PortObj->purge_all;
  $PortObj->purge_rx;
  $PortObj->purge_tx;

  $ModemStatus = $PortObj->is_modemlines;
  if ($ModemStatus & $PortObj->MS_RLSD_ON) { print "carrier detected"; }

  $PortObj->close;	## undef $PortObj preferred

=head1 DESCRIPTION

This provides fairly low-level access to the Win32 System API calls
dealing with serial ports.

Uses features of the Win32 API to implement non-blocking I/O, serial
parameter setting, event-loop operation, and enhanced error handling.

To pass in C<NULL> as the pointer to an optional buffer, pass in C<$null=0>.
This is expected to change to an empty list reference, C<[]>, when perl
supports that form in this usage.

Beyond raw access to the API calls and related constants, this module
will eventually handle smart buffer allocation and translation of return
codes.

=head2 Initialization

The constructor is B<new> with a F<PortName> (as the Registry
knows it) specified. This will do a B<CreateFile>, get the available
options and capabilities via the Win32 API, and create the object.
The port is not yet ready for read/write access. First, the desired
I<parameter settings> must be established. Since these are tuning
constants for an underlying hardware driver in the Operating System,
they should all checked for validity by the method calls that set them.
The B<initialize> method takes a list of required parameters and confirms
they have been set. For others, it will attempt to deduce defaults from
the hardware or from other parameters. The B<initialize> method returns
the number of faults (zero if the port is setup ok). The B<update_DCB>
method writes a new I<Device Control Block> to complete the startup and
allow the port to be used. Ports are opened for binary transfers. A
separate C<binmode> is not needed. The USER must release the object
if B<initialize> or B<update_DCB> does not succeed.

The fault checking in B<initialize> consists in verifying an I<_N_$item>
internal variable exists for each I<$item> in the input list. The
I<_N_$item> is created for each parameter that is set either directly
or by default. A derived class must create the I<_N_$items> for any
varibles it adds to the base class if it wants B<initialize> to check
them. Win32API::CommPort supports the following:

	$item		_N_$item	    setting method
	------		---------	    --------------
	BAUD		"_N_BAUD"	    is_baudrate
	BINARY		"_N_BINARY"	    is_binary
	DATA		"_N_DATA"	    is_databits
	EOFCHAR		"_N_EOFCHAR"	    is_eof_char
	ERRCHAR		"_N_ERRCHAR"	    is_error_char
	EVTCHAR		"_N_EVTCHAR"	    is_event_char
	HSHAKE		"_N_HSHAKE"	    is_handshake
	PARITY		"_N_PARITY"	    is_parity
	PARITY_EN	"_N_PARITY_EN"	    is_parity_enable
	RCONST		"_N_RCONST"	    is_read_const_time
	READBUF		"_N_READBUF"	    is_read_buf
	RINT		"_N_RINT"	    is_read_interval
	RTOT		"_N_RTOT"	    is_read_char_time
	STOP		"_N_STOP"	    is_stopbits
	WCONST		"_N_WCONST"	    is_write_const_time
	WRITEBUF	"_N_WRITEBUF"	    is_write_buf
	WTOT		"_N_WTOT"	    is_write_char_time
	XOFFCHAR	"_N_XOFFCHAR"	    is_xoff_char
	XOFFLIM		"_N_XOFFLIM"	    is_xoff_limit
	XONCHAR		"_N_XONCHAR"	    is_xon_char
	XONLIM		"_N_XONLIM"	    is_xon_limit

Some individual parameters (eg. baudrate) can be changed after the
initialization is completed. These will automatically update the
I<Device Control Block> as required. The I<init_done> method indicates
when I<initialize> has completed successfully.


  $PortObj = new Win32API::CommPort ($PortName)
       || die "Can't open $PortName: $^E\n";

  if $PortObj->can_databits { $PortObj->is_databits(8) };
  $PortObj->is_baudrate(9600);
  $PortObj->is_parity("none");
  $PortObj->is_stopbits(1.5);
  $PortObj->is_handshake("rts");
  $PortObj->is_buffers(4096, 4096);
  $PortObj->dtr_active(T);

  @required = qw( BAUD DATA STOP PARITY );
  $PortObj->initialize(@required) || undef $PortObj;

  $PortObj->dtr_active(f);
  $PortObj->is_baudrate(300);

  $PortObj->close;

  undef $PortObj;  # closes port AND frees memory in perl

The F<PortName> maps to both the Registry I<Device Name> and the
I<Properties> associated with that device. A single I<Physical> port
can be accessed using two or more I<Device Names>. But the options
and setup data will differ significantly in the two cases. A typical
example is a Modem on port "COM2". Both of these F<PortNames> open
the same I<Physical> hardware:

  $P1 = new Win32API::CommPort ("COM2");

  $P2 = new Win32API::CommPort ("\\\\.\\Nanohertz Modem model K-9");

$P1 is a "generic" serial port. $P2 includes all of $P1 plus a variety
of modem-specific added options and features. The "raw" API calls return
different size configuration structures in the two cases. Win32 uses the
"\\.\" prefix to identify "named" devices. Since both names use the same
I<Physical> hardware, they can not both be used at the same time. The OS
will complain. Consider this A Good Thing.

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
methods can be used in two different ways:

=item method called with an argument

The parameter is set to the argument, if valid. An invalid argument
returns I<false> (undef) and the parameter is unchanged. After B<init_done>,
the port will be updated immediately if allowed. Otherwise, the value
will be applied when B<update_DCB> is called.

=item method called with no argument in scalar context

The current value is returned. If the value is not initialized either
directly or by default, return "undef" which will parse to I<false>.
For binary selections (true/false), return the current value. All
current values from "multivalue" selections will parse to I<true>.
Current values may differ from requested values until B<init_done>.
There is no way to see requests which have not yet been applied.
Setting the same parameter again overwrites the first request. Test
the return value of the setting method to check "success".

=back

=head2 Exports

Nothing is exported by default. The following tags can be used to have
large sets of symbols exported:

=over 4

=item :PARAM

Utility subroutines and constants for parameter setting and test:

	LONGsize	SHORTsize	nocarp		Yes_true
	OS_Error

=item :STAT

Serial communications status constants. Included are the constants for
ascertaining why a transmission is blocked:

	BM_fCtsHold	BM_fDsrHold	BM_fRlsdHold	BM_fXoffHold
	BM_fXoffSent	BM_fEof		BM_fTxim	BM_AllBits

Which incoming bits are active:

	MS_CTS_ON	MS_DSR_ON	MS_RING_ON	MS_RLSD_ON

What hardware errors have been detected:

	CE_RXOVER	CE_OVERRUN	CE_RXPARITY	CE_FRAME
	CE_BREAK	CE_TXFULL	CE_MODE

Offsets into the array returned by B<status:>

	ST_BLOCK	ST_INPUT	ST_OUTPUT	ST_ERROR

=item :RAW

The constants and wrapper methods for low-level API calls. Details of
these methods may change with testing. Some may be inherited from
Win32API::File when that becomes available.

  $result=ClearCommError($handle, $Error_BitMask_p, $CommStatus);
  $result=ClearCommBreak($handle);
  $result=SetCommBreak($handle);
  $result=GetCommModemStatus($handle, $ModemStatus);
  $result=GetCommProperties($handle, $CommProperties);
  $result=GetCommState($handle, $DCB_Buffer);
  $result=SetCommState($handle, $DCB_Buffer);
  $result=SetupComm($handle, $in_buf_size, $out_buf_size);
  $result=ReadFile($handle, $buffer, $wanted, $got, $template);
  $result=WriteFile($handle, $buffer, $size, $count, $template);

  $result=GetCommTimeouts($handle, $CommTimeOuts);
  $result=SetCommTimeouts($handle, $CommTimeOuts);
  $result=EscapeCommFunction($handle, $Func_ID);
  $result=GetCommConfig($handle, $CommConfig, $Size);
  $result=SetCommConfig($handle, $CommConfig, $Size);
  $result=PurgeComm($handle, $flags);

  $result=GetCommMask($handle, $Event_Bitmask);
  $result=SetCommMask($handle, $Event_Bitmask);
  $hEvent=CreateEvent($security, $reset_req, $initial, $name);
  $handle=CreateFile($file, $access, $share, $security,
                     $creation, $flags, $template);
  $result=CloseHandle($handle);
  $result=ResetEvent($hEvent);
  $result=TransmitCommChar($handle, $char);
  $result=WaitCommEvent($handle, $Event_Bitmask, $lpOverlapped);
  $result=GetOverlappedResult($handle, $lpOverlapped, $count, $bool);

Flags used by B<PurgeComm:>

	PURGE_TXABORT	PURGE_RXABORT	PURGE_TXCLEAR	PURGE_RXCLEAR

Function IDs used by EscapeCommFunction:

	SETXOFF		SETXON		SETRTS		CLRRTS
	SETDTR		CLRDTR		SETBREAK	CLRBREAK

Events used by B<WaitCommEvent:>

	EV_RXCHAR	EV_RXFLAG	EV_TXEMPTY	EV_CTS
	EV_DSR		EV_RLSD		EV_BREAK	EV_ERR
	EV_RING		EV_PERR		EV_RX80FULL	EV_EVENT1
	EV_EVENT2

Errors specific to B<GetOverlappedResult:>

	ERROR_IO_INCOMPLETE	ERROR_IO_PENDING

=item :COMMPROP

The constants for the I<CommProperties structure> returned by
B<GetCommProperties>. Included mostly for completeness.

	BAUD_USER	BAUD_075	BAUD_110	BAUD_134_5
	BAUD_150	BAUD_300	BAUD_600	BAUD_1200
	BAUD_1800	BAUD_2400	BAUD_4800	BAUD_7200
	BAUD_9600	BAUD_14400	BAUD_19200	BAUD_38400
	BAUD_56K	BAUD_57600	BAUD_115200	BAUD_128K

	PST_FAX		PST_LAT		PST_MODEM	PST_PARALLELPORT
	PST_RS232	PST_RS422	PST_X25		PST_NETWORK_BRIDGE
	PST_RS423	PST_RS449	PST_SCANNER	PST_TCPIP_TELNET
	PST_UNSPECIFIED

	PCF_INTTIMEOUTS		PCF_PARITY_CHECK	PCF_16BITMODE
	PCF_DTRDSR		PCF_SPECIALCHARS	PCF_RLSD
	PCF_RTSCTS		PCF_SETXCHAR		PCF_TOTALTIMEOUTS
	PCF_XONXOFF

	SP_BAUD		SP_DATABITS	SP_HANDSHAKING	SP_PARITY
	SP_RLSD		SP_STOPBITS	SP_SERIALCOMM	SP_PARITY_CHECK

	DATABITS_5	DATABITS_6	DATABITS_7	DATABITS_8
	DATABITS_16	DATABITS_16X

	STOPBITS_10	STOPBITS_15	STOPBITS_20

	PARITY_SPACE	PARITY_NONE	PARITY_ODD	PARITY_EVEN
	PARITY_MARK

	COMMPROP_INITIALIZED

=item :DCB

The constants for the I<Device Control Block> returned by B<GetCommState>
and updated by B<SetCommState>. Again, included mostly for completeness.
But there are some combinations of "FM_f" settings which are not currrently
supported by high-level commands. If you need one of those, please report
the lack as a bug.

	CBR_110		CBR_300		CBR_600		CBR_1200
	CBR_2400	CBR_4800	CBR_9600	CBR_14400
	CBR_19200	CBR_38400	CBR_56000	CBR_57600
	CBR_115200	CBR_128000	CBR_256000

	DTR_CONTROL_DISABLE	DTR_CONTROL_ENABLE	DTR_CONTROL_HANDSHAKE
	RTS_CONTROL_DISABLE	RTS_CONTROL_ENABLE	RTS_CONTROL_HANDSHAKE
	RTS_CONTROL_TOGGLE

	EVENPARITY	MARKPARITY	NOPARITY	ODDPARITY
	SPACEPARITY

	ONESTOPBIT	ONE5STOPBITS	TWOSTOPBITS

	FM_fBinary		FM_fParity		FM_fOutxCtsFlow
	FM_fOutxDsrFlow		FM_fDtrControl		FM_fDsrSensitivity
	FM_fTXContinueOnXoff	FM_fOutX		FM_fInX
	FM_fErrorChar		FM_fNull		FM_fRtsControl
	FM_fAbortOnError	FM_fDummy2

=item :ALL

All of the above. Except for the I<test suite>, there is not really a good
reason to do this.

=back

=head1 NOTES

The object returned by B<new> is NOT a I<Filehandle>. You
will be disappointed if you try to use it as one.

e.g. the following is WRONG!!____C<print $PortObj "some text";>

An important note about Win32 filenames. The reserved device names such
as C< COM1, AUX, LPT1, CON, PRN > can NOT be used as filenames. Hence
I<"COM2.cfg"> would not be usable for B<$Configuration_File_Name>.

This module uses Win32::API extensively. The raw API calls are B<very>
unforgiving. You will certainly want to start perl with the B<-w> switch.
If you can, B<use strict> as well. Try to ferret out all the syntax and
usage problems BEFORE issuing the API calls (many of which modify tuning
constants in hardware device drivers....not where you want to look for bugs).

Thanks to Ken White for testing on NT.

=head1 KNOWN LIMITATIONS

The current version of the module has been designed for testing using
the ActiveState and Core (GS 5.004_02) ports of perl for Win32 without
requiring a compiler or using XS. In every case, compatibility has been
selected over performance. Since everything is (sometimes convoluted but
still pure) perl, you can fix flaws and change limits if required. But
please file a bug report if you do. This module has been tested with
each of the binary perl versions for which Win32::API is supported: AS
builds 315, 316, and 500 and GS 5.004_02. It has only been tested on
Intel hardware.

=over 4

=item Tutorial

With all the options, this module needs a good tutorial. It doesn't
have one yet. The demo programs with B<Win32::SerialPort> provide a
starting point for common functions.

=item Buffers

The size of the Win32 buffers are selectable with B<is_buffers>. But each read
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
exceeds the value set by B<is_read_interval>. It does this by timestamping
each character. It appears that at least one character must by received
to initialize the mechanism.

The other model defines the total time allowed to complete the operation.
A fixed overhead time is added to the product of bytes and per_byte_time.
A wide variety of timeout options can be defined by selecting the three
parameters: fixed, each, and size.

Read_total = B<is_read_const_time> + (B<is_read_char_time> * bytes_to_read)

Write_total = B<is_write_const_time> + (B<is_write_char_time> * bytes_to_write)

=back

=head1 BUGS

ActiveState ports of Perl for Win32 before build 500 do not support the
tools for building extensions and so will not support later versions of
this extension. In particular, the automated install and test scripts in
this distribution do not work with ActiveState builds 3xx.

There is no parameter checking on the "raw" API calls. You probably should
be familiar with using the calls in "C" before doing much experimenting.

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

Wi32::SerialPort - High-level user interface/front-end for this module

Win32API::File I<when available>

Win32::API - Aldo Calpini's "Magic", http://www.divinf.it/dada/perl/

Perltoot.xxx - Tom (Christiansen)'s Object-Oriented Tutorial

=head1 COPYRIGHT

Copyright (C) 1998, Bill Birthisel. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head2 COMPATIBILITY

This is still Beta code and may be subject to functional changes which
are not fully backwards compatible. This version (0.12) adds an
I<Install.PL> script to put modules into the documented Namespaces.
The script uses I<MakeMaker> tools not available in ActiveState 3xx
builds. Users of those builds will need to install manually (see README).
Some of the optional exports (those under the "RAW:" tag) have been
renamed in this version. I do not know of any scripts outside the test
suite which will be affected. 8 Nov 1998.

=cut
