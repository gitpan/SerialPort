package AltPort;
# Inheritance test

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.10';
require Exporter;
use SerialPort qw( :STAT :PARAM 0.10 );
@ISA = qw( Exporter SerialPort );
@EXPORT= qw();
@EXPORT_OK= @SerialPort::EXPORT_OK;
%EXPORT_TAGS = %SerialPort::EXPORT_TAGS;

my $in = BM_fCtsHold;
print "AltPort import=$in\n";
1;
