use Switch;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use strict;
use warnings;
use bot;
use room;
use Class::Inspector;

package xtModule;

    sub new {
        my $self = {};
        bless($self);
        shift;
        $self->{parent} = shift;
        %{$self->{xtHandlers}} =     (
                                        'j#js' => 'handleJoinServer', 
                                        'j#jr' => 'handleJoinRoom', 
                                        'j#jp' => 'handleJoinPlayer',
                                        'u#h' => 'handleHeartBeat',
                                        'f#epfgr' => 'handleEPFGetPoints',
                                        'u#pbi' => 'handlePlayerByID',
                                        'u#sp' => 'handleSendPosition', 
                                        'u#sf' => 'handleSendFrame',
                                        'u#sa' => 'handleSendAction',
                                        'u#se' => 'handleSendEmote',
                                        'u#sb' => 'handleThrowBall',
                                        'u#ss' => 'handleSendSafeMessage',
                                        'u#gbffl' => 'handleGbffl',
                                        'm#sm' => 'handleSendMessage',
                                        'i#gi' => 'handleGetInventory',
                                        'i#ai' => 'handleAddItem',
                                        's#upc' => 'handleUpdateClothes',
                                        's#uph' => 'handleUpdateClothes',
                                        's#upf' => 'handleUpdateClothes',
                                        's#upn' => 'handleUpdateClothes',
                                        's#upb' => 'handleUpdateClothes',
                                        's#upa' => 'handleUpdateClothes',
                                        's#upe' => 'handleUpdateClothes',
                                        's#upl' => 'handleUpdateClothes',
                                        's#upp' => 'handleUpdateClothes',
                                        'g#af' => 'handleAddFurniture',
                                        'g#au' => 'handleAddIgloo', 
                                        'g#gail' => 'handleGetAllIglooLayouts',
                                        'g#gii' => 'getIglooInventory',
                                        'g#gm' => 'handleGetIglooDetails',
                                        'g#ggd' => 'handleGetGameData',
                                        'g#uic' => 'handleUpdateIgloo',
                                        'g#uiss' => 'handleUpdateIglooString',
                                        'g#gili' => 'handleGetIglooLikes',
                                        'g#im' => 'handleIglooManage',
                                        'g#aloc' => 'handleBuyIglooLocation',
                                        'g#ag' => 'handleBuyFloor',
                                        'g#gr' => 'handleGetOpenedIgloos',
                                        'p#pg' => 'handleGetPuffle',
                                        't#at' => 'handleOpenBook', 
                                        'p#pg' => 'handleGetPuffle',
                                        'o#k' => 'handleKickPlayer',
                                        'o#m' => 'handleMutePlayer',
                                        'o#initban' => 'handleInitBan',
                                        'o#ban' => 'handleBan',
                                        'o#moderatormessage' => 'handleWarn',
                                        'b#br' => 'handleBuddyRequest',
                                        #'i#gi' => 'handleGetItems', 
                                        #'l#mst' => 'handleStartMail',
                                        #'l#mg' => 'handleGetMail',
                                        #'u#glr' => 'handleGetLatestRevision',
                                        
                                    );
        $self->{rooms} = {
959 => room->new($self, 1, 959), # Smoothie
955 => room->new($self, 2, 955), # Puffle Launch
942 => room->new($self, 3, 942), # Balloon Pop
916 => room->new($self, 4, 916), # Aqua Grabber
200 => room->new($self, 5, 200), # Ski Village
912 => room->new($self, 6, 912), # Catchin' Waves
921 => room->new($self, 7, 921), # Mission 8
805 => room->new($self, 8, 805), # Ice Berg
998 => room->new($self, 9, 998), # Card Jitsu
919 => room->new($self, 10, 919), # Paint By Letters: Lime Green Dojo Clean
400 => room->new($self, 11, 400), # The Beach
923 => room->new($self, 12, 923), # Mission 10
220 => room->new($self, 13, 220), # Find Four (Lodge)
994 => room->new($self, 14, 994), # igloo_card
868 => room->new($self, 15, 868), # Party18
857 => room->new($self, 16, 857), # Party7
899 => room->new($self, 17, 899), # Party
948 => room->new($self, 18, 948), # Grab and Spin
865 => room->new($self, 19, 865), # Party15
964 => room->new($self, 20, 964), # Potion
803 => room->new($self, 21, 803), # HQ
904 => room->new($self, 22, 904), # Ice Fishing
853 => room->new($self, 23, 853), # Party3
211 => room->new($self, 24, 211), # Agent Lobby Solo
908 => room->new($self, 25, 908), # Mission 2
431 => room->new($self, 26, 431), # Puffle Hotel Spa
861 => room->new($self, 27, 861), # Party11
432 => room->new($self, 28, 432), # Puffle Hotel Roof
321 => room->new($self, 29, 321), # Dojo Exterior
340 => room->new($self, 30, 340), # The Stage
903 => room->new($self, 31, 903), # Hydro Hopper
860 => room->new($self, 32, 860), # Party10
812 => room->new($self, 33, 812), # Dojo Fire
917 => room->new($self, 34, 917), # Paint By Letters: My Puffle
911 => room->new($self, 35, 911), # Mission 3
435 => room->new($self, 36, 435), # School Solo
808 => room->new($self, 37, 808), # The Mine
814 => room->new($self, 38, 814), # Lake
926 => room->new($self, 39, 926), # DJ3K
944 => room->new($self, 40, 944), # Feed a Puffle
320 => room->new($self, 41, 320), # The Dojo
859 => room->new($self, 42, 859), # Party9
924 => room->new($self, 43, 924), # Game24
907 => room->new($self, 44, 907), # Mission 1
876 => room->new($self, 45, 876), # Party26
110 => room->new($self, 46, 110), # Coffee Shop
913 => room->new($self, 47, 913), # Mission 4
811 => room->new($self, 48, 811), # Box Dimension
957 => room->new($self, 49, 957), # Rollerscape
863 => room->new($self, 50, 863), # Party13
323 => room->new($self, 51, 323), # Agent Command
856 => room->new($self, 52, 856), # Party6
112 => room->new($self, 53, 112), # Club Penguin
915 => room->new($self, 54, 915), # Mission 6
858 => room->new($self, 55, 858), # Party8
954 => room->new($self, 56, 954), # Water Sensei
420 => room->new($self, 57, 420), # Pirate Ship
801 => room->new($self, 58, 801), # Snow Forts
121 => room->new($self, 59, 121), # Lounge
212 => room->new($self, 60, 212), # Agent Lobby Multi
952 => room->new($self, 61, 952), # Dance Contest
950 => room->new($self, 62, 950), # System Defender
996 => room->new($self, 63, 996), # 
326 => room->new($self, 64, 326), # CJ Snow Dojo
956 => room->new($self, 65, 956), # Bits And Bolts
947 => room->new($self, 66, 947), # Puffle Shuffle
810 => room->new($self, 67, 810), # Cove
855 => room->new($self, 68, 855), # Party5
852 => room->new($self, 69, 852), # Party2
920 => room->new($self, 70, 920), # Mission 7
943 => room->new($self, 71, 943), # Ring the Bell
324 => room->new($self, 72, 324), # Dojo Exterior Solo
433 => room->new($self, 73, 433), # Cloud Forest
806 => room->new($self, 74, 806), # Underground Pool
410 => room->new($self, 75, 410), # Lighthouse
963 => room->new($self, 76, 963), # Spy Drills
890 => room->new($self, 77, 890), # Party99
918 => room->new($self, 78, 918), # Paint By Letters: Burnt out Bulbs
999 => room->new($self, 79, 999), # Sled Race
230 => room->new($self, 80, 230), # Ski Hill
430 => room->new($self, 81, 430), # Puffle Hotel Lobby
922 => room->new($self, 82, 922), # Mission 9
423 => room->new($self, 83, 423), # The Crows Nest
815 => room->new($self, 84, 815), # Underwater
901 => room->new($self, 85, 901), # Bean Counters
330 => room->new($self, 86, 330), # Pizza Parlor
902 => room->new($self, 87, 902), # Puffle Roundup
862 => room->new($self, 88, 862), # Party12
867 => room->new($self, 89, 867), # Party17
958 => room->new($self, 90, 958), # Scorn Battle
995 => room->new($self, 91, 995), # Card'jitsu Water
422 => room->new($self, 92, 422), # Treasure Hunt
953 => room->new($self, 93, 953), # Fire Sensei
221 => room->new($self, 94, 221), # Find Four (Attic)
905 => room->new($self, 95, 905), # Cart Surfer
210 => room->new($self, 96, 210), # Sports Shop
854 => room->new($self, 97, 854), # Party4
949 => room->new($self, 98, 949), # Puffle Rescue
866 => room->new($self, 99, 866), # Party16
910 => room->new($self, 100, 910), # Pizzatron 3000
877 => room->new($self, 101, 877), # Party27
875 => room->new($self, 102, 875), # Party25
909 => room->new($self, 103, 909), # Thin Ice
100 => room->new($self, 104, 100), # Town Center
914 => room->new($self, 105, 914), # Mission 5
946 => room->new($self, 106, 946), # Puffle paddle
300 => room->new($self, 107, 300), # The Plaza
120 => room->new($self, 108, 120), # Night Club
804 => room->new($self, 109, 804), # Boiler Room
310 => room->new($self, 110, 310), # Pet Shop
800 => room->new($self, 111, 800), # The Dock
421 => room->new($self, 112, 421), # Ship's Hold
906 => room->new($self, 113, 906), # Jetpack Adventure
960 => room->new($self, 114, 960), # Ice Jam
130 => room->new($self, 115, 130), # Clothes Shop
122 => room->new($self, 116, 122), # school
813 => room->new($self, 117, 813), # Cavemine
878 => room->new($self, 118, 878), # Party28
864 => room->new($self, 119, 864), # Party14
941 => room->new($self, 120, 941), # Puffle Soaker
900 => room->new($self, 121, 900), # Astro Barrier
851 => room->new($self, 122, 851), # Party1
927 => room->new($self, 123, 927), # Mission 11
1100 => room->new($self, 124, 1100), # My Penguin 
925 => room->new($self, 125, 925), # Game25
951 => room->new($self, 126, 951), # Sensei
997 => room->new($self, 127, 997), # Card'jitsu Fire
809 => room->new($self, 128, 809), # Forest
213 => room->new($self, 129, 213), # Agent VR
816 => room->new($self, 130, 816), # Card'jitsu Water
111 => room->new($self, 131, 111), # Mancala
802 => room->new($self, 132, 802), # Ice Rink
874 => room->new($self, 133, 874), # Party24
411 => room->new($self, 134, 411), # Beacon
807 => room->new($self, 135, 807), # Mine Shack
945 => room->new($self, 136, 945), # Memory Card



                                
                            };
        $self->{iglooData} = {openedIgloos => {}, cachedString => '%'};
        $self->{globalBot} = bot->new($self->{parent}, undef);
        
        $self->{globalBot}->{crumbs}->{playerID} = 0;
        $self->{globalBot}->{crumbs}->{userName} = 'CPEmu Bot';
        $self->{globalBot}->{crumbs}->{memberDays} = 2000;
        $self->{globalBot}->{properties}->{isLoggedIn} = 1;
        $self->{globalBot}->{crumbs}->{color} = 5;
        $self->{globalBot}->{crumbs}->{head} = 413;
        $self->{globalBot}->{crumbs}->{body} = 4131;
        $self->{globalBot}->{crumbs}->{feet} = 6075;
        foreach my $key (keys($self->{rooms})) {
            $self->{rooms}->{$key}->addClient($self->{globalBot});
        }
        # First packet on login
        # %xt%gps%-1%69327887%0%.%xt%lp%-1%69327887|Rodger110|5|3|1163|125|0|4641|0|0|0|0|0|0|1|0|523|0|%4434%0%1440%1359210480003%1569%0%9437%%8%1%0%02%.%xt%glr%-1%7907%.%xt%jr%53%856%69327887|Rodger110|5|3|1163|125|0|4641|0|0|0|0|0|0|1|0|523|0|%97051987|Hv2009|37|4|0|0|0|4779|0|0|7101|0|503|142|1|1|1004|16|%174264263|Tessa 2572|47|3|0|0|0|4585|0|6149|609|9085|565|150|1|1|212|13|%.%xt%ap%53%69327887|Rodger110|5|3|1163|125|0|4641|0|0|0|0|0|0|1|0|523|0|%.%xt%spts%-1%69327887%0%
        return $self;
    }
    sub makeXt {
        my $self = shift;
        my $packet = '%xt%';
        foreach my $arg (@_){
            $packet .= $arg.'%';
        }
        return $packet;
    }
    sub sendAllRooms {
        my $self = shift;
        my @packet = @_;
        
        
        foreach my $clientID (keys($self->{parent}->{parent}->{clients})) {
            my $client = $self->{parent}->{parent}->{clients}->{$clientID};
            next if(!$client->{properties}->{currentRoom});
            $packet[1] = $client->{properties}->{currentRoom}->{intID};
            $client->write($self->makeXt(@packet));
        }
    }
    sub getClientByPlayerID {
        my $self = shift;
        my $playerID = shift;
        
        foreach my $client (values($self->{parent}->{parent}->{clients})){
            if($client->{crumbs}->{playerID} == $playerID){
                return $client;
            }
        }
        return undef;
    }
    sub getClientByUserName {
        my $self = shift;
        my $userName = shift;
        
        foreach my $client (values($self->{parent}->{parent}->{clients})){
            if(lc($client->{crumbs}->{userName}) eq lc($userName)){
                return $client;
            }
        }
        return undef;
    }
    sub handleXT {
        my $self = shift;
        my $client = shift;
        my $readData = shift;
        my $handler;
        my @packet = split('%', $readData);
        $handler = $self->{xtHandlers}->{$packet[3]} or $handler = 'unknownHandler';
        $self->$handler($client, $packet[3], $readData, splice(@packet, 4));
        
    }
    sub handleLogin {
        my $self = shift;
        my $client = shift;
        my $isLogin = shift;
        
        if($isLogin){
            my $loginKey = crypto::generateLoginKey($client);
            $client->write($self->makeXt('l', -1, join('|', $client->{crumbs}->{playerID}, 0, $client->{crumbs}->{userName}, $loginKey, 1, 5, 0, 'false', 'false', 0), 'partya', 'partya', $self->{parent}->{config}->{serverID}.',1|3115,1|3651,1|'));
            # %xt%l%-1%100|0|John|KSKf}ekmvWlbrXDMu}MR|1|5|0|false|false|0%0%0%3100,1|%
            $client->updateLoginKey($loginKey);
            $self->{parent}->{parent}->removeClient($client);
            return;
        }

        $client->updateLoginKey(' ');
        $client->write($self->makeXt('l', -1));
    }
    sub sendError {
        my $self = shift;
        my $client = shift;
        my $errorID = shift;
        my $forceRemove = shift // 1;
        my @additionalArgs = @_;
        
        $client->write($self->makeXt('e', -1, $errorID, @additionalArgs));
        $self->{parent}->{parent}->removeClient($client) if($forceRemove);
    }
    sub unknownHandler {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $self->{parent}->{logger}->info("Client ID $client->{key} sent invalid packet $readData!");
    }

    sub handleJoinServer {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_; # %xt%lp%-1%'.$client->makePlayerString().'%4434%0%1440%1359210480003%1569%0%9437%%8%1%0%02%.
        $client->write($self->makeXt('js', -1, $client->{crumbs}->{isEPF}, 0, $client->{crumbs}->{isModerator}, 0));
        $client->write($self->makeXt('lp', -1, $client->makePlayerString(), $client->{crumbs}->{coins}, 0, 1440, time()*1000, 0, 0, 187, '', 7, 1, 0, 385, 1, 02));
        $client->write($self->makeXt('activefeatures', -1, 20130901));
        $client->write($self->makeXt('mdvls', -1, '{"recipes":[{"availability":0,"ingredientIds":[0,3,4,1,2,0,3,4],"potionId":1},{"availability":1,"ingredientIds":[2,1,4,1,0,2,1,4],"potionId":2},{"availability":2,"ingredientIds":[0,0,3,3,4,4,1,1],"potionId":3},{"availability":3,"ingredientIds":[2,2,1,1,4,4,1,1],"potionId":4},{"availability":4,"ingredientIds":[2,0,1,0,4,0,3,0],"potionId":5},{"availability":5,"ingredientIds":[0,3,4,1,1,4,3,0],"potionId":6},{"availability":6,"ingredientIds":[1,2,1,2,4,3,4,3],"potionId":7},{"availability":7,"ingredientIds":[0,3,3,4,4,4,1,2],"potionId":8},{"availability":8,"ingredientIds":[4,0,2,3,3,2,0,4],"potionId":9},{"availability":9,"ingredientIds":[1,5,4,5,3,5,0,5],"potionId":10}],"unlockDayIndex":0,"potionsPerGame":5,"maxPotions":99,"maxSpeed":220}'));
        $client->write($self->makeXt('mdvlp', -1, '{"potionsMade":[0,0,0,0,0,0,0,0,0,0],"msgIndex":1,"ingredients":[1,1,1,1,1],"inventory":[0,0,0,0,0,0,0,0,0,0],"golden":0}'));
        
        $self->joinRoom($client, 100, 0, 0);
    }
    sub handleHeartBeat {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('h', -1));
    }
    sub handlePlayerByID {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('pbi', -1, 0, 0));
    }
    sub handleSendPosition {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        $client->{properties}->{frame} = 0;
        $client->{properties}->{x} = $packet[1];
        $client->{properties}->{y} = $packet[2];
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('sp', $packet[0], $client->{crumbs}->{playerID}, $packet[1], $packet[2]));
    }
    sub handleSendFrame {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->{properties}->{frame} = $packet[1];
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('sf', $packet[0], $client->{crumbs}->{playerID}, $packet[1]));
    }
    sub handleSendAction {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('sa', $packet[0], $client->{crumbs}->{playerID}, $packet[1]));
    }
    sub handleSendEmote {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('se', $packet[0], $client->{crumbs}->{playerID}, $packet[1]));
    }
    sub handleThrowBall {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('sb', $packet[0], $client->{crumbs}->{playerID}, $packet[1], $packet[2]));
    }
    sub handleSendSafeMessage {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('ss', $packet[0], $client->{crumbs}->{playerID}, $packet[1]));
    }
    sub handleSendMessage {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        my $show = 1;
        
        
        if(substr($packet[2], 0, 1) eq '!') {
            # A Command, possibly.
            my @commandParams = split(" ", $packet[2]);
            $commandParams[0] = lc($commandParams[0]);
            $show = $self->{parent}->{modules}->{commandModule}->handleCommand($client, @commandParams) if($self->{parent}->{modules}->{commandModule}->{commandHandlers}->{$commandParams[0]}); # Handle if the command is valid, skip if not
        }
        return if($client->{properties}->{muted});
        $client->{properties}->{currentRoom}->writeAll($self->makeXt('sm', $packet[0], $client->{crumbs}->{playerID}, $packet[2])) if($show);
    }
    sub handleJoinRoom {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        $self->joinRoom($client, $packet[1], $packet[2], $packet[3]);
    }
    sub joinRoom {
        my $self = shift;
        my $client = shift;
        my $extID = shift;
        my $x = shift;
        my $y = shift;
        
        return $self->sendError($client, 210, 0) if(!exists($self->{rooms}->{$extID}));
        $client->{properties}->{x} = $x;
        $client->{properties}->{y} = $y;
        $client->{properties}->{currentRoom}->removeClient($client) if($client->{properties}->{currentRoom} != 0);
        $self->{rooms}->{$extID}->addClient($client);
    }
    sub handleGetInventory {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        my $str = '';
        foreach my $key (keys($client->{crumbs}->{items})){
            $str .= $key.'%';
        }
        $client->write($self->makeXt('gi', -1, $str));
    }
    sub handleAddItem {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->addItem($packet[1]);
        $client->updateCoins($client->{crumbs}->{coins}-100); # No, this is not a mistake
        $client->write($self->makeXt('ai', $packet[0], $packet[1], $client->{crumbs}->{coins}));
    }
    sub handleAddFurniture {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->addFurniture($packet[1]);
        $client->updateCoins($client->{crumbs}->{coins}-100);
        $client->write($self->makeXt('af', $packet[0], $packet[1], $client->{crumbs}->{coins}));
    }
    sub handleAddIgloo {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->addIgloo($packet[1]);
        $client->write($self->makeXt('au', $packet[0], $packet[1], 5000));
    }
    sub handleUpdateClothes {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        my $intID = $packet[0];
        my $itemID = $packet[1];
        return $client->addItem($itemID) if(!$client->hasItem($itemID));
        switch($handler) {
            case('s#upc') {
                $client->updateColor($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upc', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#uph') {
                $client->updateHead($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('uph', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upf') {
                $client->updateFace($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upf', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upn') {
                $client->updateNeck($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upn', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upb') {
                $client->updateBody($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upb', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upa') {
                $client->updateHand($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upa', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upe') {
                $client->updateFeet($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upe', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upl') {
                $client->updateFlag($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upl', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
            case('s#upp') {
                $client->updatePhoto($itemID);
                $client->{properties}->{currentRoom}->writeAll($self->makeXt('upp', $intID, $client->{crumbs}->{playerID}, $itemID));
            }
        }
    }
    sub handleGetAllIglooLayouts {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        

        $client->write($self->makeXt('gail', $packet[0], $client->{crumbs}->{playerID}, 0));
        #%xt%gail%1039%207569249%0%15523041:1:1:1:0:0:1:1:0:%.%xt%gaili%1039%0%15523041|0%
        $client->write($self->makeXt('gaili', $packet[0], 0, ($client->{crumbs}->{playerID}+10).'|0'));
    }
    sub getIglooInventory {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        my $furniture = '';
        my $floors = '';
        my $igloos = '';
        my $backgrounds = '';
        while(my($key, $value) = each(%{$client->{crumbs}->{furniture}})){
            $furniture .= "$key|0|$value,";
        }
        while(my($key, $value) = each(%{$client->{crumbs}->{igloos}})){
            $igloos .= "$key|$key,";
        }
        while(my($key, $value) = each(%{$client->{crumbs}->{floors}})){
            $floors .= "$key|$key,";
        }
        while(my($key, $value) = each(%{$client->{crumbs}->{iglooBackgrounds}})){
            $backgrounds .= "$key|$key,";
        }
        $client->write($self->makeXt('gii', -1, $furniture, $floors, $igloos, $backgrounds));
    }
    sub handleGetIglooDetails {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        my $intID = $packet[1];
        my $extID = $intID+5000;
        if(!$self->{rooms}->{$extID}){
            $self->{rooms}->{$extID} = room->new($self, $intID, $extID);
            $self->{rooms}->{$extID}->{iglooSummary} = ($client->{crumbs}->{playerID} == $intID) ? $client->makeIglooDetails() : $self->makeIglooDetailsByID($intID);
        }
        $client->write($self->makeXt("gm", $packet[0], $client->{crumbs}->{playerID}, $self->{rooms}->{$extID}->{iglooSummary}))
    }
    sub handleJoinPlayer {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        my $roomID = $packet[1];
        if(!exists($self->{rooms}->{$roomID})) {
            $self->{rooms}->{$roomID} = room->new($self, $roomID-5000, $roomID);
            $self->{rooms}->{$roomID}->{iglooSummary} = $client->makeIglooDetails();
        }
        $client->write($self->makeXt('jp', $packet[0], $roomID));
        $self->joinRoom($client, $roomID, 0, 0);
    }

    sub handleGetGameData {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('ggd', $packet[0], ''));
    }
    sub handleUpdateIgloo {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        $client->updateIglooID($packet[2]) if($packet[2] ne $client->{crumbs}->{iglooID});
        $client->updateFloor($packet[3]) if($packet[3] ne $client->{crumbs}->{floorID});
        $client->updateIglooBackgroundID($packet[4]) if($packet[4] ne $client->{crumbs}->{iglooBackgroundID});
        $client->updateMusicID($packet[5]) if($packet[5] ne $client->{crumbs}->{musicID});
        $client->updateIglooString($packet[6]) if($packet[6] && $packet[6] ne $client->{crumbs}->{iglooString});
    }
    sub handleUpdateIglooString {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        return $self->openIgloo($client) if($client->{properties}->{isIglooClosed} && $packet[2] eq $client->{crumbs}->{playerID}.'|0');
        $self->closeIgloo($client) if(!$client->{properties}->{isIglooClosed} && $packet[2] eq $client->{crumbs}->{playerID}.'|1');
    }
    sub handleGetIglooLikes {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('gili', $packet[0], 0, 0, 0));
    }
    sub handleIglooManage {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('im', $packet[0], $packet[1], 0));
    }
    sub handleBuyIglooLocation {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->addIglooBackground($packet[1]);
        $client->write($self->makeXt('aloc', $packet[0], $packet[1], $client->{crumbs}->{coins}));
    }
    sub handleBuyFloor {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->addFloor($packet[1]);
        $client->write($self->makeXt('ag', $packet[0], $packet[1], $client->{crumbs}->{coins}));
    }
    sub handleGetOpenedIgloos {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        $client->write('%xt%gr%-1%'.$client->{crumbs}->{iglooLikes}.'%0%'.$self->{iglooData}->{cachedString});
    }
    sub openIgloo {
        my $self = shift;
        my $client = shift;
        
        $self->{iglooData}->{openedIgloos}->{$client->{key}} = $client->{crumbs}->{playerID}.'|'.$client->{crumbs}->{userName}.'|'.$client->{crumbs}->{iglooLikes}.'|0|0';
        $self->generateOpenedIglooString();
        $client->{properties}->{isIglooClosed} = 0;
        $self->{rooms}->{$client->{crumbs}->{playerID}+5000}->{iglooSummary} = $client->makeIglooDetails();
    }
    sub closeIgloo {
        my $self = shift;
        my $client = shift;
        my %openedIgloos = %{$self->{iglooData}->{openedIgloos}};
        delete($self->{iglooData}->{openedIgloos}->{$client->{key}});
        $self->generateOpenedIglooString();
        $client->{properties}->{isIglooClosed} = 1;
        $self->{rooms}->{$client->{crumbs}->{playerID}+5000}->{iglooSummary} = $client->makeIglooDetails();
    }
    sub generateOpenedIglooString {
        my $self = shift;
        #my $string = '%xt%gr%-1%0';
        my $string = '%';
        foreach my $value (values($self->{iglooData}->{openedIgloos})){
        $string .= $value.'%';
        }
        $self->{iglooData}->{cachedString} = $string;
    }
    sub handleGbffl {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write('%xt%gbffl%-1%%');
    }
    sub handleOpenBook {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('at', $packet[0], $packet[1], 2, 1));
        
    }
    sub handleGetPuffle {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;    
        
        $client->write($self->makeXt('pg', '2'));
    }
    sub handleEPFGetPoints {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        $client->write($self->makeXt('epfgr', -1, -1));
    }
    sub handleKickPlayer {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        return if(!$client->{crumbs}->{isModerator});
        
        my $targetClient = $self->getClientByPlayerID($packet[1]) or return;
        $self->kickClient($client, $targetClient);
    }
    sub handleMutePlayer {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        
        return if(!$client->{crumbs}->{isModerator});
        my $targetClient = $self->getClientByPlayerID($packet[1]);
        $self->muteClient($client, $targetClient);
    }
    sub handleInitBan {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        return if(!$client->{crumbs}->{isModerator});
        
        my $targetClient = $self->getClientByPlayerID($packet[1]) or return;
        
        $client->write($self->makeXt('initban', $packet[0], $packet[1], $targetClient->{properties}->{warned}, $targetClient->{crumbs}->{banNum}, $packet[2], $targetClient->{crumbs}->{userName}));
    }
    sub handleBan {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        return if(!$client->{crumbs}->{isModerator});
        my $targetClient = $self->getClientByPlayerID($packet[1]);
        $self->banClient($client, $packet[1], $packet[2], $packet[3], $packet[4], $packet[5], $targetClient);
    }
    sub handleWarn {
        my $self = shift;
        my $client = shift;
        my $handler = shift;
        my $readData = shift;
        my @packet = @_;
        return if(!$client->{crumbs}->{isModerator});
        my $targetClient = $self->getClientByPlayerID($packet[2]);
        
        $self->warnClient($client, $targetClient, $packet[1]);
    }
    sub warnClient {
        my $self = shift;
        my $moderatorClient = shift;
        my $targetClient = shift;
        my $warnReason = shift;
        
        $targetClient->{properties}->{warned} = 1;
        $targetClient->write($self->makeXt('moderatormessage', -1, $warnReason));
        $self->{parent}->{logger}->info('Client ID '.$targetClient->{key}.' has been warned by '.$moderatorClient->{crumbs}->{userName}.'.');
    }
    sub kickClient {
        my $self = shift;
        my $moderatorClient = shift;
        my $targetClient = shift;

        $targetClient->write($self->sendError($targetClient, 5, 1));
        $self->{parent}->{logger}->info('Client ID '.$targetClient->{key}.' has been kicked by '.$moderatorClient->{crumbs}->{userName}.'.');
    }
    sub muteClient {
        my $self = shift;
        my $moderatorClient = shift;
        my $targetClient = shift;
        
        $targetClient->{properties}->{muted} = (($targetClient->{properties}->{muted}) ? 0 : 1);
        $self->{parent}->{logger}->info('Client ID '.$targetClient->{key}.' has been (un)muted by '.$moderatorClient->{crumbs}->{userName}.'.');
    }
    sub banClient {
        my $self = shift;
        my $moderatorClient = shift;
        my $playerID = shift;
        my $banMessage = shift;
        my $banID = shift;
        my $banLength = shift;
        my $banReason = shift;
        my $targetClient = shift;
        
        my $banStamp = time()+3600*$banLength if($banLength);
        
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `isBanned` =  1, `bannedUntil` = ?, `bannedBy` = ?, `banNum` = `banNum` + 1 WHERE  `playerID` = ?'), $banStamp, $moderatorClient->{crumbs}->{playerID}, $playerID); 
        
        if($targetClient){
            $targetClient->write($self->{parent}->{modules}->{xtModule}->makeXt('ban', -1, $banMessage, $banID, $banLength, $banReason));
            $self->{parent}->{parent}->removeClient($targetClient);
        }
        $self->{parent}->{logger}->info('PlayerID '.$playerID.' has been banned by '.$moderatorClient->{crumbs}->{userName}.'.');
    }
    sub unbanClient {
        my $self = shift;
        my $moderatorClient = shift;
        my $userName = shift;
        
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('UPDATE `users` SET `isBanned` = 0, `bannedUntil` =  0 WHERE  `userName` = ?'), $userName);
        ($moderatorClient) ? $self->{parent}->{logger}->info('User '.$userName.' has been unbanned by '.$moderatorClient->{crumbs}->{userName}.'.') : $self->{parent}->{logger}->info('User '.$userName.' has been unbanned by the server as the ban has expired.');
    }
1;
