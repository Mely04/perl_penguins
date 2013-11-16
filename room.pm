use strict;
use warnings; 

package room;

    sub new {
        shift;
        my $self = {};
        bless($self);
        
        $self->{parent} = shift;
        $self->{intID} = shift;
        $self->{extID} = shift;
        
        $self->{clients} = {};
        return $self;
    }
    sub addClient {
        my $self = shift;
        my $client = shift;

        $self->{clients}->{$client->{crumbs}->{playerID}} = $client;
        my $str = '';
        foreach my $mClient (values($self->{clients})) {
            $str .= $mClient->makePlayerString().'%';
        }
        $client->write("%xt%jr%$self->{intID}%$self->{extID}%$str");
        $self->writeAll($self->{parent}->makeXt('ap', $self->{intID}, $client->makePlayerString()));
        $client->{properties}->{currentRoom} = $self;
    }
    sub removeClient {
        my $self = shift;
        my $client = shift;
        delete($self->{clients}->{$client->{crumbs}->{playerID}});
        $client->{properties}->{currentRoom} = undef;
        $self->writeAll($self->{parent}->makeXt('rp', -1, $client->{crumbs}->{playerID}));
    }
    sub writeAll {
        my $self = shift;
        my $data = shift;
        
        foreach my $client (values($self->{clients})){
            $client->write($data);
        }
    }
1;
