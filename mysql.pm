use strict;
use warnings;
use POSIX;
use IO::Epoll;
use DBI;
use Data::Dumper;
package mysql;

    sub new {
        my $self = {};
        bless($self);
        shift;
        $self->{parent} = shift;
        my ($connectionNum, $host, $port, $db, $user, $password) = @_;
        $self->{connectionNum} = $connectionNum;
        $self->{host} = $host;
        $self->{port} = $port;
        $self->{db} = $db;
        $self->{user} = $user;
        $self->{password} = $password;
        $self->{connections} = ();
        $self->createConnections($connectionNum);
        return $self;
    }
    sub createConnections {
        my $self = shift;
        my $connectionNum = shift;
        for(my $i = 1; $i <= $connectionNum; $i++){
            my $connection = $self->connect($self->{host}, $self->{port}, $self->{db}, $self->{user}, $self->{password}) or $self->{parent}->{logger}->error("Could not create MySQL connection number $i. $!", 1);
            my $fd = $connection->mysql_fd;
            $self->{connections}->{$fd} = {connection => $connection};
            $self->{parent}->{logger}->info("Created MySQL connection number $i! FD $fd");
        }
    }
    sub reInitConnection {
        my $self = shift;
        my $oldFd = shift;
        delete($self->{connections}->{$oldFd});
        my $connection = $self->connect($self->{host}, $self->{port}, $self->{db}, $self->{user}, $self->{password}) or $self->{parent}->{logger}->error("Could not reconnect to database! $!", 1);
        my $fd = $connection->mysql_fd;
        $self->{connections}->{$fd} = {connection => $connection};
        my $result = IO::Epoll::epoll_ctl($self->{parent}->{parent}->{poller}, IO::Epoll::EPOLL_CTL_ADD(), $fd, IO::Epoll::EPOLLIN());
        #print $result.chr(10);
        POSIX::close($oldFd);
        $self->{parent}->{logger}->info("Re-created MySQL connection! FD $fd ".$self->{parent}->{parent}->{poller});
    }
    sub getFreeConnection {
        my $self = shift;
        foreach my $key (keys(%{$self->{connections}})) {
            return $key if(!$self->{connections}->{$key}->{inUse});
        }
        return undef;
    }
    sub connect {
        my $self = shift;
        my $host = shift;
        my $port = shift;
        my $db = shift;
        my $user = shift;
        my $password = shift;
        my $connection = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $user, $password) or exit; 
        return $connection;
    }
    sub createQuery {
        my $self = shift;
        my $statement = shift;
        my $returnFunction = shift;
        my $returnType = shift;
        my $connection = $self->getFreeConnection() or return $self->{parent}->{logger}->error("Could not get MySQL connection from pool! Are all of them in use?");
        $connection = $self->{connections}->{$connection};
        $connection->{inUse} = 1;
        $connection->{returnFunction} = $returnFunction;
        $connection->{returnType} = $returnType;
        $connection->{args} = \@_;
        $connection->{statement} = $connection->{connection}->prepare($statement, {async => 1});
        return $connection->{statement}
    }
    sub executeQuery {
        my $self = shift;
        my $statement = shift;
        return if(!$statement);
        $statement->execute(@_);
    }
    sub handleFinishedQuery {
        my $self = shift;
        my $fd = shift;
        my $connection = $self->{connections}->{$fd};
        
        return $self->reInitConnection($fd) if(!$connection->{inUse});
        $connection->{statement}->mysql_async_result; # Grab the result to prevent it from calling again
        
        if(!$connection->{returnFunction}) {
                $connection->{inUse} = 0;
                return;
        }
        my $result;
        if($connection->{returnType} == 1){ # 1 is the code for single result
            $result = $self->getSingleResult($connection->{statement});
        }
        elsif($connection->{returnType} == 2){  # 2 is the code for hash result
            $result = $self->getResultHash($connection->{statement});
        }
        elsif($connection->{returnType} == 3){  # 3 is the code for array result
            $result = $self->getResultArray($connection->{statement});
        }
        $connection->{inUse} = 0;
        $connection->{returnFunction}->(@{$connection->{args}}, $result);
        
    }
    sub getSingleResult {
        my $self = shift;
        my $statement = shift;
        
        my @array = $statement->fetchrow_arrayref();
        return $array[0][0];
    }
    sub getResultArray {
        my $self = shift;
        my $statement = shift;
        
        my @array = $statement->fetchrow_arrayref();
        return $array[0];
    }
    sub getResultHash {
        my $self = shift;
        my $statement = shift;
        
        my @array = $statement->fetchrow_hashref();
        return $array[0];
    }
1;
