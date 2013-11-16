use strict;
use warnings;


package bot;
use base qw(client);
sub new {
         my $self = {};
        bless($self);
        shift;
        $self->{parent} = shift;
        $self->{rawClient} = shift;
        %{$self->{properties}} = (
                                    rndK => '', 
                                    isLoggedIn => 0,
                                    currentRoom => 0,
                                    x => 0, 
                                    y => 0,
                                    frame => 0, 
                                    isIglooClosed => 1,
                                    muted => 0,
                                    warned => 0,
                                );
        %{$self->{crumbs}} = (
                                playerID => 0, 
                                userName => '', 
                                isModerator => 0,
                                memberDays => 20,
                                isEPF => 0,
                                coins => 0, 
                                items => {},
                                color => 0, 
                                head => 0, 
                                face => 0, 
                                neck => 0, 
                                body => 0, 
                                hand => 0, 
                                feet => 0, 
                                flag => 0, 
                                photo => 0,
                                furniture => {},
                                igloos => {},
                                iglooBackgrounds => {},
                                floors => {},
                                iglooID => 0,
                                iglooString => '',
                                musicID => 0,
                                floorID => 0,
                                iglooBackgroundID => 1,
                                iglooLikes => 0,
                                iglooID => 0,
                                iglooString => '',
                            );
        return $self;
    
}
sub write {
    return 1;
}
sub read {
    return 1;
}
sub initializeCrumbs {
    return 1;
}
 sub getAllCrumbs {
    return 1;
}
sub finishGetCrumbs {
    return 1;
}
sub sayTo {
    my $self = shift;
    my $targetClient = shift;
    my $message = shift;

    
    $targetClient->write($self->{parent}->{modules}->{xtModule}->makeXt('sm', $targetClient->{properties}->{currentRoom}->{intID}, $self->{crumbs}->{playerID}, $message));
}
1;
