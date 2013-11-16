use Scalar::Util;
use Sereal;
use strict;
package client;

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
                                    lastMsg => 0,
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
        $self->{properties}->{lastMsg} = time();
        return $self;
    }
    sub closeMethod {
        my $self = shift;
        $self->{properties}->{currentRoom}->removeClient($self) if($self->{properties}->{currentRoom});
        $self->{parent}->{modules}->{xtModule}->closeIgloo($self) if(!$self->{properties}->{isIglooClosed});
    }
    sub write {
        my $self = shift;
        my $data = shift;
        send($self->{rawClient}, $data.chr(0), 0);
    }
    sub read {
        my $self = shift;
        my $message = shift;
        recv($self->{rawClient}, my $data, 12288, 0);
        return $data;
    }
    sub initializeCrumbs {
        my $self = shift;
        my $username = shift;
        $self->getAllCrumbs($username);
    }
    sub getAllCrumbs {
        my $self = shift;
        my $username = shift;
        my $statement = $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `playerID`, `userName`, `items`,`furniture`,`igloos`,`iglooBackgrounds`,`floors`,`isModerator`,`banNum`,`isEPF`,`registerTime`,`coins`,`color`,`head`,`face`,`neck`,`body`,`hand`,`feet`,`flag`,`photo`, `iglooID`, `iglooString`, `musicID`, `floorID`, `iglooBackgroundID`,`memberDays` FROM `users` WHERE `userName` = ?', \&finishGetCrumbs, 2, $self), $username);
    }
    sub finishGetCrumbs {
        my $self = shift;
        my $crumbs = shift;
        my %crumbs = %{$crumbs};
        foreach my $key (keys(%crumbs)){
            my $value = $crumbs{$key};
            next if(!$value);
            if(ref($self->{crumbs}->{$key}) eq 'HASH') {
                $value = Sereal::Decoder::decode_sereal($crumbs{$key});
            }
            $self->{crumbs}->{$key} = $value;
        }
        $self->{parent}->{modules}->{xtModule}->handleLogin($self, $self->{parent}->{config}->{isLogin}); # Finish login in XT module
    }
    sub updateLoginKey {
        my $self = shift;
        my $loginKey = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `loginKey` = ? WHERE `playerID` = ?'), $loginKey, $self->{crumbs}->{playerID});
    }
    sub updateItems {
        my $self = shift;
        my $items = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `items` = ? WHERE `playerID` = ?'), $items, $self->{crumbs}->{playerID});
    }
    sub updateFurniture {
        my $self = shift;
        my $furniture = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `furniture` = ? WHERE `playerID` = ?'), $furniture, $self->{crumbs}->{playerID});
    }
    sub addItem {
        my $self = shift;
        my $itemID = shift;
        
        return 0 if($self->hasItem($itemID) || !Scalar::Util::looks_like_number($itemID));
        $self->{crumbs}->{items}->{$itemID} = 1;
        $self->updateItems(Sereal::Encoder::encode_sereal($self->{crumbs}->{items}));
        return 1;
    }
    sub addFurniture {
        my $self = shift;
        my $itemID = shift;
        my $num = shift // 1;
        return 0 if(!Scalar::Util::looks_like_number($itemID));
        $self->{crumbs}->{furniture}->{$itemID} = $self->{crumbs}->{furniture}->{$itemID} ?  $self->{crumbs}->{furniture}->{$itemID}+$num : 1;
        $self->updateFurniture(Sereal::Encoder::encode_sereal($self->{crumbs}->{furniture}));
        return 1;
    }
    sub addIgloo {
        my $self = shift;
        my $iglooID = shift;
        
        $self->{crumbs}->{igloos}->{$iglooID} = 1;
        $self->updateIgloos(Sereal::Encoder::encode_sereal($self->{crumbs}->{igloos}));
    }
    sub addIglooBackground {
        my $self = shift;
        my $backgroundID = shift;
        
        $self->{crumbs}->{iglooBackgrounds}->{$backgroundID} = 1;
        $self->updateIglooBackgrounds(Sereal::Encoder::encode_sereal($self->{crumbs}->{iglooBackgrounds}));
    }
    sub updateIglooBackgrounds {
        my $self = shift;
        my $backgrounds = shift;
        
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `iglooBackgrounds` = ? WHERE `playerID` = ?'), $backgrounds, $self->{crumbs}->{playerID});
    }
    sub addFloor {
        my $self = shift;
        my $floorID = shift;
        
        $self->{crumbs}->{floors}->{$floorID} = 1;
        $self->updateFloors(Sereal::Encoder::encode_sereal($self->{crumbs}->{floors}));
    }
    sub updateFloors {
        my $self = shift;
        my $floors = shift;
        
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `floors` = ? WHERE `playerID` = ?'), $floors, $self->{crumbs}->{playerID});
    }
    sub updateIgloos {
        my $self = shift;
        my $igloos = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `igloos` = ? WHERE `playerID` = ?'), $igloos, $self->{crumbs}->{playerID});
    }
    sub hasItem {
        my $self = shift;
        my $itemID = shift;
        return 1 if(exists($self->{crumbs}->{items}->{$itemID}));
        return 0;
    }
    sub updateColor {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `color` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{color} = $itemID;
    }
    sub updateHead {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `head` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{head} = $itemID;
    }
    sub updateFace {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `face` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{face} = $itemID;
    }
    sub updateNeck {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `neck` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{neck} = $itemID;
    }
    sub updateBody {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `body` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{body} = $itemID;
    }
    sub updateHand {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `hand` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{hand} = $itemID;
    }
    sub updateFeet {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `feet` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{feet} = $itemID;
    }
    sub updateFlag {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `flag` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{flag} = $itemID;
    }
    sub updatePhoto {
        my $self = shift;
        my $itemID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `photo` = ? WHERE `playerID` = ?'), $itemID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{photo} = $itemID;
    }
    sub updateIglooString {
        my $self = shift;
        my $iglooString = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `iglooString` = ? WHERE `playerID` = ?'), $iglooString, $self->{crumbs}->{playerID});
        $self->{crumbs}->{iglooString} = $iglooString;
        $self->{parent}->{modules}->{xtModule}->{rooms}->{$self->{crumbs}->{playerID}+5000}->{iglooSummary} = $self->makeIglooDetails();
    }
    sub updateIglooID {
        my $self = shift;
        my $iglooID = shift;
        
        $self->addIgloo($iglooID) if(!$self->{crumbs}->{igloos}->{$iglooID});
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `iglooID` = ? WHERE `playerID` = ?'), $iglooID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{iglooID} = $iglooID;
        $self->{parent}->{modules}->{xtModule}->{rooms}->{$self->{crumbs}->{playerID}+5000}->{iglooSummary} = $self->makeIglooDetails();
    }
    sub updateIglooBackgroundID {
        my $self = shift;
        my $iglooBackground = shift;
        $self->addIglooBackground($iglooBackground) if(!$self->{crumbs}->{iglooBackgrounds}->{$iglooBackground});
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `iglooBackgroundID` = ? WHERE `playerID` = ?'), $iglooBackground, $self->{crumbs}->{playerID});
        $self->{crumbs}->{iglooBackgroundID} = $iglooBackground;
        $self->{parent}->{modules}->{xtModule}->{rooms}->{$self->{crumbs}->{playerID}+5000}->{iglooSummary} = $self->makeIglooDetails();
    }
    sub updateFloor {
        my $self = shift;
        my $floor = shift;
        $self->addFloor($floor) if(!$self->{crumbs}->{floors}->{$floor});
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `floorID` = ? WHERE `playerID` = ?'), $floor, $self->{crumbs}->{playerID});
        $self->{crumbs}->{floorID} = $floor;
        $self->{parent}->{modules}->{xtModule}->{rooms}->{$self->{crumbs}->{playerID}+5000}->{iglooSummary} = $self->makeIglooDetails();
    }
    sub updateMusicID {
        my $self = shift;
        my $musicID = shift;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `musicID` = ? WHERE `playerID` = ?'), $musicID, $self->{crumbs}->{playerID});
        $self->{crumbs}->{musicID} = $musicID;
        $self->{parent}->{modules}->{xtModule}->{rooms}->{$self->{crumbs}->{playerID}+5000}->{iglooSummary} = $self->makeIglooDetails();
    }
    sub updateCoins {
        my $self = shift;
        my $coins = shift;
        
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `coins` = ? WHERE `playerID` = ?'), $coins, $self->{crumbs}->{playerID});
        $self->{crumbs}->{coins} = $coins;
    }

    sub makePlayerString {
        my $self = shift;
        my $string = '';
        $string .= $self->{crumbs}->{playerID}.'|';
        $string .= $self->{crumbs}->{userName}.'|';
        $string .= $self->{parent}->{config}->{bitMask}.'|'; # Bitmask.
        $string .= $self->{crumbs}->{color}.'|';
        $string .= $self->{crumbs}->{head}.'|';
        $string .= $self->{crumbs}->{face}.'|';
        $string .= $self->{crumbs}->{neck}.'|';
        $string .= $self->{crumbs}->{body}.'|';
        $string .= $self->{crumbs}->{hand}.'|';
        $string .= $self->{crumbs}->{feet}.'|';
        $string .= $self->{crumbs}->{flag}.'|';
        $string .= $self->{crumbs}->{photo}.'|';
        $string .= $self->{properties}->{x}.'|';
        $string .= $self->{properties}->{y}.'|';
        $string .= $self->{properties}->{frame};
        $string .= '|1|'.$self->{crumbs}->{memberDays};
        $string .= '|0|{"spriteScale":100,"spriteSpeed":100,"ignoresBlockLayer":false,"invisible":false,"floating":false}|';
        return $string;
    }
    sub makeIglooDetails {
        my $self = shift;
        my $string = '';
        $string .= $self->{crumbs}->{playerID}.':1:1:';
        $string .= $self->{properties}->{isIglooClosed}.':';
        $string .= $self->{crumbs}->{musicID}.':';
        $string .= $self->{crumbs}->{floorID}.':';
        $string .= $self->{crumbs}->{iglooBackgroundID}.':';
        $string .= $self->{crumbs}->{iglooID}.':0:';
        $string .= $self->{crumbs}->{iglooString};
        return $string;
    }
1;
