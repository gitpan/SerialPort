Win32::SerialPort and Win32API::CommPort
VERSION=0.10, 29 August 1998

Hello Beta testers:

The current version of the module has been designed for testing using
the ActiveState and Core (GS 5.004_02) ports of perl for Win32 without
requiring a compiler or using XS. In every case, compatibility has been
selected over performance. Since everything is (sometimes convoluted but
still pure) perl, you can fix flaws and change limits if required. But
please file a bug report if you do.

This is the first public beta. Some features are not yet implemented.
I suspect there are still bugs - but I don't know of any. If the code
does not match the documentation, consider it a bug and please report it.
Please tell me what doesn't work, what you dislike (or like), and what
should be added (or deleted). One very visible change from the alpha is
the division into two modules:

1. Win32::SerialPort is the high-level user interface. It inherits from
   CommPort.

2. Win32API::CommPort is the raw API calls and other internal details
   that most users won't need to know much about.

These modules use Aldo Calpini's Win32::API module extensively. It is
available at:

    http://www.divinf.it/dada/perl/Win32API-0_011.zip

for AS build 3xx and GS 5.004_02. For AS build 5xx, it is available as
the package Win32-API using PPM on the ActiveState repository.
Get it, install it, and test it BEFORE trying Win32API::SerialPort. The
"-w" complaints (xxx used only once) under AS 3xx are normal.

See the NOTES and KNOWN LIMITATIONS in the SerialPort documentation. The
".pod" is embedded in the ".pm". The comments on "-w" and "use strict"
are especially relevant when you start calling this module from your own
code. This module has been tested on Win95 with AS Builds 315 and 500 and
the GS binary 5.004_02. Thanks to Ken White for testing on NT. Also thanks
to the others who have contributed comments and suggestions.

FILES:
    Changes		- for history lovers
    MANIFEST		- file list
    README.txt		- this file
    README    		- same file with CPAN-friendly name
    Makefile.PL		- incomplete, but still the "starting point"
    SerialPort.pm	- the reason you're reading this
    CommPort.pm		- the raw API calls and other internals
    SerialPort.html	- since AS 3xx doesn't have pod2html
    CommPort.html	- since AS 3xx doesn't have pod2html
    test1.t		- RUN ME FIRST, tests and creates configuration
    test2.t		- tests restarting_a_configuration and timeouts
    test3.t		- Inheritance and export version of test1.t
    test4.t		- Inheritance version of test2.t
    test5.t		- tests to optional exports from CommPort
    AltPort.pm		- Inheritance stub
    demo1.plx		- talks to a "really dumb" terminal
    demo2.plx		- "poor man's" readline and chat
    demo3.plx		- looks like a setup menu - but only looks :-(
    demo4.plx		- simplest setup: "new", "required param", "restart"
    demo5.plx		- a basic "waitfor" function
    demo6.plx		- a basic "readline" function

This is a preliminary release for testing only. While I will try to
maintain backwards compatibility from this point forward, I can't
guarantee it.  This module is NOT ready for production use.
Consider the lack of an Install program to be a feature and run in a
"standalone" directory. Run 'perl Makefile.PL' first with nothing
connected to "COM1". On ActiveState Build 3xx this will give test
instructions. On 5.004 and above it will run the tests automatically
with the Benchmark routines. This tests most of the module methods and
leaves the port set for 9600 baud, 1 stop, 8 data, no parity, no
handshaking, and other defaults. At various points in the testing, it
expects unconnected CTS and DTR lines. The final configuration is saved
as COM1_test.cfg.

The tests may be run individually by typing 'perl test?.t Page_Delay'.
With no delay, the tests execute too rapidly to follow from an MS-DOS
bo individually by typing 'perl test?.t Page_Delay'.
With no delay, some tests execute too rapidly to follow from the
command line. Delay may be set from 1 to 5 seconds.

All tests are expected to pass - I would be very interested in hearing
about failures ("not ok"). These tests should be run from a command
line (DOS box).

Connect a dumb terminal (or a PC that acts like one) to COM1 and setup
the equivalent configuration. Starting demo1.plx should print a three
line message on both the terminal and the Win32 command line. The
terminal keyboard (only) now accepts characters which it prints to both
screens until a CONTROL-Z is typed. Also included is demo2.plx - a truly
minimal chat program. Bi-directional communication without an event loop,
sockets, pipes (or much utility ;-) This one uses CAPITAL-Q from the
active keyboard to quit since <STDIN> doesn't like CONTROL-Z. And each
command shell acts a little differently (Cygnus "bash", COMMAND.COM).
Try running the terminal at 4800 baud to get errors (or 300 to get
"breaks").

AltPort.pm and test3.t implement the "basic Inheritance test" discussed
in perltoot and other documentation. It also imports the :STAT constants.
It's otherwise only slightly modified from test1.t (you'll get a different
"alias" if you run test2.t or demo3.plx after test3.t). There are only
subtle functional changes between test2.t and test4.t. But test4.t also
calls CommPort methods directly rather than through SerialPort.

You can read (most of the important) settings with demo3.plx. If you
give it a (valid) configuration file on the command line, it will open
the port with those parameters (and "initialized" set - so you can test
simple changes: see the parity example at the end of demo3.plx).

Demo4.plx is a "minimum" script showing just the basics needed to get
started.

Demo5.plx and demo6.plx are first drafts of as-yet-unimplemented functions.
Try them out. Since there is no "stty", you have to set the options by hand.
Use any editor. Let me know if the descriptions are useable. And if any
more options are necessary.

Please tell me what does and what doesn't work. Which systems "croak".
You can share this with anyone. But it's still beta code. Don't trust it
for anything important. And watch for frequent updates at:

%%%% http://members.aol.com/Bbirthisel/alpha.html

or CPAN under Win32::SerialPort and Win32API::CommPort

Thanks,

-bill

Copyright (C) 1998, Bill Birthisel. All rights reserved. This module is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.
