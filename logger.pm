use strict;
use warnings;
use strict;
use warnings;
use Term::ANSIColor;

package logger;

    sub new {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        return $self;
    }
    sub info {
        my $self = shift;
        my $msg  = shift;
        
        my $TIME = localtime;
        $msg = Term::ANSIColor::colored("[$TIME] [INFO]: ", 'bold blue').Term::ANSIColor::colored($msg, 'bright_yellow');
        print $msg.chr(10);
    }
    sub error {
        my $self = shift;
        my $msg = shift;
        my $fatal = shift // 0;
        
        my $TIME = localtime;
        $msg = Term::ANSIColor::colored("[$TIME] [ERROR]: ", 'bold red').Term::ANSIColor::colored($msg, 'bright_yellow');
        print $msg.chr(10);
        exit if($fatal);
    }
1;
