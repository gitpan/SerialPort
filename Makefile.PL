####    use ExtUtils::MakeMaker;
####    # See lib/ExtUtils/MakeMaker.pm for details of how to influence
####    # the contents of the Makefile that is written.
####    WriteMakefile(
####        'NAME'	=> 'SerialPort',
####        'VERSION_FROM' => 'SerialPort.pm', # finds $VERSION
####    );

print "\n\n  Beta code for Win32::SerialPort and Win32API::CommPort\n";
print "           No 'Makefile' will be created\n";
print "     so skip customary 'make', 'dmake', 'nmake' step\n\n";
print "The tests will run automatically on perl 5.004 and above (1+ minute)\n";
print "         Test with nothing connected to COM1\n\n";
print "On ActiveState Build 3xx, or to run individual tests, type:\n";
print "    C:\\> perl test1.t Page_Pause_Time (1..5)\n";
print "Continue with 'perl test2.t' through 'perl test5.t'\n";
print "See README and other documentation for additional information.\n\n";

use Test::Harness;

runtests ("test1.t", "test2.t", "test3.t", "test4.t", "test5.t");
