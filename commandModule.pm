
use strict;
use warnings;

package commandModule;

sub new {
    my $self = {};
    bless($self);
    shift;
    $self->{parent} = shift;
    %{$self->{commandHandlers}} = (
                           '!ai' => \&addItem,
                           '!pin' => \&updatePin,
                           '!af' => \&addFurniture,
                           '!ui' => \&updateIglooID,
                           '!igloo' => \&updateIglooID,
                           '!um' => \&updateMusicID,
                           '!music' => \&updateMusicID,
                           '!uf' => \&updateFloorID,
                           '!floor' => \&updateFloorID,
                           '!ub' => \&updateIglooBackgroundID,
                           '!background' => \&updateIglooBackgroundID,
                           '!resetigloo' => \&resetIgloo,
                           '!ri' => \&resetIgloo,
                           '!ac' => \&addCoins,
                           '!jr' => \&joinRoom,
                           '!kick' => \&kickClient,
                           '!mute' => \&muteClient,
                           '!ban' => \&banClient,
                           '!unban' => \&unbanClient,
                           '!ping' => \&handlePing,
                           '!id' => \&handleGetID,
                           '!getid' => \&getIDByUser,
                           '!global' => \&handleSendGlobal,
                           '!find' => \&handleFindPlayer,
                           '!badge' => \&handleTogglePlayerBadge,
                           '!nick' => \&handleChangePlayerNick,
                       );
    return $self;
}
sub handleCommand {
    my $self = shift;
    $self->{commandHandlers}->{$_[1]}->($self, @_); # Send over the arguments to the function, $_1 is the command
}
sub addItem { 
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    return if(!$command[1] || !$client->addItem($command[1]));
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('ai', -1, $command[1], $client->{crumbs}->{coins}));
}
sub addFurniture {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    return if($command[2] && !Scalar::Util::looks_like_number($command[2]));
    return if(!$command[1] || !$client->addFurniture($command[1], $command[2])); # Add furniture itemID, number of item
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('af', -1, $command[1], $client->{crumbs}->{coins}));
}
sub addCoins {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    $client->updateCoins($command[1]+$client->{crumbs}->{coins});
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('zo', -1, $client->{crumbs}->{coins}));
}
sub joinRoom {
    my $self = shift;
    my $client  = shift;
    my @command = @_;

    $self->{parent}->{modules}->{xtModule}->joinRoom($client, $command[1], 0, 0);
    return;
}
sub kickClient {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$client->{crumbs}->{isModerator});
    my $targetClient = $self->{parent}->{modules}->{xtModule}->getClientByUserName($command[1]) or return;
    $self->{parent}->{modules}->{xtModule}->kickClient($client, $targetClient);
    return;
}
sub muteClient {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$client->{crumbs}->{isModerator});
    my $targetClient = $self->{parent}->{modules}->{xtModule}->getClientByUserName($command[1]) or return;
    $self->{parent}->{modules}->{xtModule}->muteClient($client, $targetClient);
    return;
}
sub banClient {
    my $self = shift;
    my $client  = shift;
    shift;
    my @command = @_;
    return if(!$client->{crumbs}->{isModerator} || !$command[0]);
    
    
    if(Scalar::Util::looks_like_number($command[0])){
        my $targetClient = $self->{parent}->{modules}->{xtModule}->getClientByPlayerID($command[0]);
        
        if(!$targetClient){
            $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `isBanned`,`playerID`,`userName`,`banNum` FROM `users` WHERE `playerID` = ?', \&continueBanClient, 2, $self, $client), $command[0]); 
            return;
        }
        
        $client->write($self->{parent}->{modules}->{xtModule}->makeXt('initban', -1, $targetClient->{crumbs}->{playerID}, $targetClient->{properties}->{warned}, $targetClient->{crumbs}->{banNum}, '',  $targetClient->{crumbs}->{userName}));
        return;
    }
    
    my $username = lc(join(' ', @command));
    my $targetClient = $self->{parent}->{modules}->{xtModule}->getClientByUserName($username);
    if(!$targetClient){
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `isBanned`,`playerID`,`userName`,`banNum` FROM `users` WHERE `userName` = ?', \&continueBanClient, 2, $self, $client), $username); 
        return;
    }
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('initban', -1, $targetClient->{crumbs}->{playerID}, $targetClient->{properties}->{warned}, $targetClient->{crumbs}->{banNum}, '',  $targetClient->{crumbs}->{userName}));
    return;
}
sub continueBanClient {
    my $self = shift;
    my $client = shift;
    my $clientInfo = shift // return;
    my %clientInfo = %{$clientInfo};
    
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('initban', -1, $clientInfo{playerID}, 0, $clientInfo{banNum}, '', $clientInfo{userName}));
}
sub unbanClient {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    return if(!$client->{crumbs}->{isModerator} || !$command[1]);
    $self->{parent}->{modules}->{xtModule}->unbanClient($client, $command[1]);
    return;
}
sub handlePing {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    $self->{parent}->{modules}->{xtModule}->{globalBot}->sayTo($client, 'Pong!');
    return 1;
}
sub handleGetID {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    $self->{parent}->{modules}->{xtModule}->{globalBot}->sayTo($client, 'Your player ID is: '.$client->{crumbs}->{playerID});
    return 1;
}
sub getIDByUser {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    $command[1] = lc($command[1]);
    return if(!$client->{crumbs}->{isModerator} || !$command[1]);
    my $user = $self->{parent}->{modules}->{xtModule}->getClientByUserName($command[1]);
    
    if($user){
         $self->{parent}->{modules}->{xtModule}->{globalBot}->sayTo($client, $user->{crumbs}->{userName}.'\'s ID is: '.$user->{crumbs}->{playerID}); 
         return 0;
    }
    $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `playerID` FROM `users` WHERE `userName` = ?', \&continueIDByUser, 3, $self, $client, $command[1]), $command[1]) if(!$user); 
    return 0;
}
sub continueIDByUser {
    my $self = shift;
    my $client = shift;
    my $userName = shift;
    my $id =  shift;
    $id = @{$id}[0];
    
    return if(!$id);
    
    $self->{parent}->{modules}->{xtModule}->{globalBot}->sayTo($client, $userName.'\'s ID is: '.$id); 
}
sub handleSendGlobal {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$client->{crumbs}->{isModerator} || !$command[1]);
    shift(@command);
    $self->{parent}->{modules}->{xtModule}->sendAllRooms('sm', undef, $self->{parent}->{modules}->{xtModule}->{globalBot}->{crumbs}->{playerID}, join(' ', @command));
    return 0;
}
sub updatePin {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    $client->updateFlag($command[1]);
    $client->{properties}->{currentRoom}->writeAll($self->{parent}->{modules}->{xtModule}->makeXt('upl', $client->{properties}->{currentRoom}->{intID}, $client->{crumbs}->{playerID}, $command[1]));
    return 1;
}
sub updateIglooID {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    $client->updateIglooID($command[1]);
    return 1;
}
sub updateMusicID {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    $client->updateMusicID($command[1]);
    return 1;
}
sub updateFloorID {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    $client->updateFloor($command[1]);
    return 1;
}
sub updateIglooBackgroundID {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    return if(!$command[1] || !Scalar::Util::looks_like_number($command[1]));
    
    $client->updateIglooBackgroundID($command[1]);
    return 1;
}
sub resetIgloo {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    $client->updateIglooID(1);
    $client->updateIglooBackgroundID(1);
    $client->updateFloor(0);
    $client->updateMusicID(0);
    return 1;
}
sub handleFindPlayer {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$command[1] || !$client->{crumbs}->{isModerator});
    
    my $player = $self->{parent}->{modules}->{xtModule}->getClientByUserName($command[1]);
    return if(!$player);
    
    $client->write($self->{parent}->{modules}->{xtModule}->makeXt('bf', $client->{properties}->{currentRoom}->{intID}, $player->{properties}->{currentRoom}->{extID}));
}
sub handleTogglePlayerBadge {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$client->{crumbs}->{isModerator});
    $client->{crumbs}->{memberDays} = (($client->{crumbs}->{memberDays} == 20) ? 2000 : 20);
    $self->{parent}->{modules}->{xtModule}->joinRoom($client, $client->{properties}->{currentRoom}->{extID}, 0, 0);
    $self->{parent}->{logger}->info('User '.$client->{crumbs}->{userName}.' has toggled their badge!');
    return 0;
}
sub handleChangePlayerNick {
    my $self = shift;
    my $client  = shift;
    my @command = @_;
    
    return if(!$client->{crumbs}->{isModerator} || !$command[1]);
    
    $self->{parent}->{logger}->info('User '.$client->{crumbs}->{userName}.' changed their nickname to '.$command[1].'!');
    
    $client->{crumbs}->{userName} = $command[1];
    $self->{parent}->{modules}->{xtModule}->joinRoom($client, $client->{properties}->{currentRoom}->{extID}, 0, 0);
    return 0;
}

1;
