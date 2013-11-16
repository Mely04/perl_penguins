use strict;
use warnings;
use client;
use Socket qw(SOMAXCONN sockaddr_in inet_ntoa);
use IO::Socket::INET;
use IO::Select;
use XML::Simple;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use xmlModule;
use xtModule;
use mysql;
use commandModule;
use logger;
use socketBase;



package socketInterface;
    
    $SIG{'INT'} = \&sig;
    $SIG{ALRM} = sub{return;};
    sub new {
        my $self = {};
        bless($self);
        shift;
        $self->{logger} = logger->new();
        $self->{parent} = socketBase->new($self);
        $self->{loggedIPs} = {};
        $self->{jobs} = {
                            30 => \&removeInactiveClients
            
            
                        };
        return $self;
    }
    sub sig {
        exit;
    }
    sub init {
        my $self = shift;
        %{$self->{config}} = @_;
        $self->{modules} =     {
                                    mysqlModule => mysql->new($self, $self->{config}->{sqlConnNum}, $self->{config}->{sqlAddr}, $self->{config}->{sqlPort}, $self->{config}->{sqlDB}, $self->{config}->{sqlUser}, $self->{config}->{sqlPass}),
                                    xmlModule => xmlModule->new($self),
                                    xtModule => xtModule->new($self),
                                    commandModule => commandModule->new($self),
                                };
        $self->{clientNum} = 0;
        $self->{parent}->createSocket($self->{config}->{bindAddr}, $self->{config}->{bindPort});
        $self->{parent}->prepareLoop();
        $self->{logger}->info('Server successfully started!');
    }
    sub doJobs {
        my $self = shift;
        my $elapsedTime = time()-$self->{parent}->{jobStamp};
        foreach my $time (keys(%{$self->{jobs}})){
            
            $self->{jobs}->{$time}->($self) if($elapsedTime >= $time);
        }
    }
    sub removeInactiveClients {
        my $self = shift;
        foreach my $client (keys(%{$self->{parent}->{clients}})){
            my $client = $self->{parent}->{clients}->{$client};
            next if((time() - $client->{properties}->{lastMsg}) <= $self->{config}->{maxIdle});
            $self->{parent}->removeClient($client);
            $self->{logger}->info("Client ID $client->{key} was idle for too long! Removing client...");
        }
    }
    sub parseData {
        my $self = shift;
        my $client = shift;
        my $readData = shift;
        if($readData eq '') {
            $self->{parent}->removeClient($client);
            return;
        }
        if(index($readData, chr(0)) == -1){
            $self->{logger}->info("Client ID $client->{key} sent a malformed packet! Removing client...");
            $self->{parent}->removeClient($client);
            return;
        }
        my @readData = split(chr(0), $readData);
       
        $client->{properties}->{lastMsg} = time();
        
        foreach $readData (@readData){
                    $self->{logger}->info("Handling data: $readData...");
            if(substr($readData, 0, 1) eq '%'){ 
                if(!$client->{properties}->{isLoggedIn}) {
                    $self->{parent}->removeClient($client);
                    return $self->{logger}->info("Client ID $client->{key} tried to send a XT packet without logging in! Disconnecting...");
                }
                $self->{modules}->{xtModule}->handleXT($client, $readData);
            }
            
            else { # XML
                if($client->{properties}->{isLoggedIn}){
                    $self->{parent}->removeClient($client);
                    $self->{logger}->info("Client ID $client->{key} tried to login twice! Removing client...");
                }
                my $parseXML = $self->{modules}->{xmlModule}->parseAndHandleXML($client, $readData);
            }
        }
    }

