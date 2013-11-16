use strict;
use warnings;
use XML::Simple;
use POSIX;
use crypto qw(getLoginHash);

package xmlModule;
    sub new {
        my $self = {};
        bless($self);
        shift;
        $self->{parent} = shift;
        %{$self->{xmlHandlers}} = ('verChk' => 'handleVerChk', 'rndK' => 'handleRndK', 'login' => 'beginXMLLogin');
        return $self;
    }
    sub parseXML {
        my $self = shift;
        my $readData = shift;
        my $parsedXML;
        eval {local $SIG{ALRM} = sub{die('');}; alarm(1); $parsedXML = XML::Simple::parse_string($readData); alarm(0);};
        if($@){
            return 0;
        }
        else {
            return $parsedXML;
        }
    }
    sub handleXML {
        my $self = shift;
        my $client = shift;
        my $readData = shift;
        my $parsedXML = shift;
        if($readData eq '<policy-file-request/>'){
            $client->write('<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>');
            return;
        }
        my $handlerName = $self->{xmlHandlers}->{$parsedXML->{body}->{action}} or return;
        return if(!exists(&$handlerName));
        $self->$handlerName($client, $parsedXML);
    }
    sub parseAndHandleXML {
        my $self = shift;
        my $client = shift;
        my $readData = shift;
        my $parsedXML = $self->parseXML($readData) or return;
        $self->handleXML($client, $readData, $parsedXML);
    }
    # Handler block
    
    sub handleVerChk {
        my $self = shift;
        my $client = shift;
        my $parsedXML = shift;
        
        # This is static for right now. (and maybe forever)
        $client->write("<msg t='sys'><body action='apiOK' r='0'></body></msg>");
    }
    sub handleRndK {
        my $self = shift;
        my $client = shift;
        my $parsedXML = shift;
        my $key = crypto::generateRndK();
        $self->{parent}->{logger}->info("Client ID $client->{key} was given rndK: $key");
        $client->write("<msg t='sys'><body action='rndK' r='-1'><k>$key</k></body></msg>");
        $client->{properties}{rndK} = $key;
    }
    sub beginXMLLogin {
        my $self = shift;
        my $client = shift;
        my $parsedXML = shift;
        
        return $self->getPasswordByUsername($client->{key}, $parsedXML->{body}->{login}->{nick}, $parsedXML->{body}->{login}->{pword}) if($self->{parent}->{config}->{isLogin});
        $self->getLoginKeyByUsername($client->{key}, $parsedXML->{body}->{login}->{nick}, $parsedXML->{body}->{login}->{pword});
    }
    sub continueXMLLogin {
        my ($self, $client, $username, $recievedPassword, $resultArray) = @_;
        $client = $self->{parent}->{parent}->{clients}->{$client};
        
        if(!defined($resultArray)){
            $self->{parent}->{modules}->{xtModule}->sendError($client, 101);
            $self->{parent}->{logger}->info("Client ID $client->{key} has attempted to identify with invalid username $username!");
            return;
        }
        my @resultArray = @{$resultArray};
        my $dbPassword = $resultArray[0];
        my $isBanned = $resultArray[1];
        my $bannedTime = $resultArray[2];

        if($isBanned) {{ # Double braces to use last
            if(!$bannedTime){
                $self->{parent}->{modules}->{xtModule}->sendError($client, 603);
            }
            else {
                if($bannedTime <= time()){
                    $self->{parent}->{modules}->{xtModule}->unbanClient(undef, $username);
                    last;
                }
                $self->{parent}->{modules}->{xtModule}->sendError($client, 601, 1, POSIX::ceil(($bannedTime-time())/3600));
            }
            return;
            $self->{parent}->{logger}->info("Client ID $client->{key} attempted to login but was banned! Disconnecting...");
        }}

        if($dbPassword eq ' '){
                $self->{parent}->{parent}->removeClient($client);
                $self->{parent}->{logger}->info("Client ID $client->{key} attempted to login but had no login key! Disconnecting...");
            }
        
        if(crypto::getLoginHash($self->{parent}->{config}->{isLogin}, $dbPassword, $client->{properties}{rndK}) eq $recievedPassword){
           if(!$self->{parent}->{config}->{isLogin}) {
              
              foreach my $secondClient (values($self->{parent}->{parent}->{clients})){
                    if(lc($secondClient->{crumbs}->{userName}) eq lc($username))
                    {
                        $self->{parent}->{parent}->removeClient($secondClient);
                        $self->{parent}->{logger}->info("Username $username has logged in twice! Removing previous client...");
                    }
                }
            }
            $client->{properties}->{isLoggedIn} = 1;
            $client->initializeCrumbs($username);
            $self->{parent}->{logger}->info("Client ID $client->{key} has successfully identified as $username!");
        }
        else {
            $self->{parent}->{modules}->{xtModule}->sendError($client, 101);
            $self->{parent}->{logger}->info("Client ID $client->{key} has failed to identify as $username!");
        }
    }
    sub getPasswordByUsername {
        my ($self, $clientID, $username, $password) = @_;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `password`, `isBanned`, `bannedUntil` FROM `users` WHERE `username` = ?', \&continueXMLLogin, 3, $self, $clientID, $username, $password), $username); 
    }
    sub getLoginKeyByUsername {
        my ($self, $clientID, $username, $password) = @_;
        $self->{parent}->{modules}->{mysqlModule}->executeQuery($self->{parent}->{modules}->{mysqlModule}->createQuery('SELECT `loginKey`, `isBanned`, `bannedUntil` FROM `users` WHERE `username` = ?', \&continueXMLLogin, 3, $self, $clientID, $username, $password), $username); 

    }
    # End of handler block
1;
