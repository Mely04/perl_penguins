use threads;
use threads::shared;
use Thread::Queue;

package threadManager;

    sub new {
        my $self = {};
        bless($self);
        shift;
        $self->{parent} = shift;
        $threadNum = shift;
        for($i = 0; $i != $threadNum; $i++){
            $self->addThread();
        }
        return $self;
    }
    sub addThread {
        my $self = shift;
        
        threads->create(\&$self->{parent}->handleNewThread, $self->{parent});
        
    }
1;
