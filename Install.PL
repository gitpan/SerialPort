use strict;
use ExtUtils::Install qw( install_default );

exit main();

sub main
{
    install_default( "Win32/SerialPort" )
      or die "Can't install package Win32/SerialPort: $!\n";
    # install_default() should append to perl/lib/perllocal.pod but doesn't
    # as of Perl5.004_04 so use "make install" if this is important to you.
    0;
}

__END__
