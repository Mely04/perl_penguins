use strict;
use bot;
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
use logger;
use IO::Epoll;
use IO::Poll;
use POSIX;
use Fcntl;

package socketBase;
    sub new {
        shift;
        my $self = {};
        bless($self);
        $self->{child} = shift;
        $self->{clients} = ();
        return $self;
    }
    sub createSocket {
        my $self = shift;
        my $addr = shift;
        my $port = shift;
        
        my $socket = IO::Socket::INET->new(LocalAddr => $addr, LocalPort => $port, Proto => 0, Listen => Socket->SOMAXCONN(), ReuseAddr => 1, Blocking => 0);
        if(!$socket){
            $self->{child}->{logger}->error("Could not bind server to address $addr at port $port! Error: $@", 1);
        }
        $self->{mainSocket} = $socket;
    }
    sub prepareLoop {
        my $self = shift;
        $self->{jobStamp} = time();
        $self->{child}->{modules}->{mysqlModule}->executeQuery($self->{child}->{modules}->{mysqlModule}->createQuery('UPDATE `servers` SET `online` = ? WHERE  `ID` = ?'), 0, $self->{child}->{config}->{serverID});
        $self->{poller} = IO::Epoll::epoll_create($self->{child}->{config}->{maxPOP}+$self->{child}->{config}->{sqlConnNum}+2);
        foreach my $key (keys($self->{child}->{modules}->{mysqlModule}->{connections})){
            IO::Epoll::epoll_ctl($self->{poller}, IO::Epoll::EPOLL_CTL_ADD(), $key, IO::Epoll::EPOLLIN());
        }
        IO::Epoll::epoll_ctl($self->{poller}, IO::Epoll::EPOLL_CTL_ADD(), fileno($self->{mainSocket}), IO::Epoll::EPOLLIN());
    }
    sub clientLoop {
        my $self = shift;
        eval {
        while(1) {
            my @readable = @{IO::Epoll::epoll_wait($self->{poller}, $self->{child}->{config}->{maxPOP}+$self->{child}->{config}->{sqlConnNum}+2, -1)};
            foreach my $pollArray (@readable){
                my $fileNo = @{$pollArray}[0];
                if($self->{child}->{modules}->{mysqlModule}->{connections}->{$fileNo}) {
                    $self->{child}->{modules}->{mysqlModule}->handleFinishedQuery($fileNo);
                    next;
                }
                if($fileNo == fileno($self->{mainSocket})){
                    $self->addClient();
                    next;
                }
                my $client = $self->getClientByFD($fileNo);
                next if(!$client);
                eval { # To keep the server from crashing on error!
                    $self->{child}->parseData($client, $client->read());
                };
                if($@){
                    $self->{child}->{logger}->error('There was a almost fatal error! We WERE able to recover...Error: '.$@);
                }
            
            }
            if(time()-$self->{jobStamp} >= 30){
                $self->{child}->doJobs();
                $self->{jobStamp} = time();
            }
        }
    };
    }
    sub addClient {
        my $self = shift;

        $self->{child}->{modules}->{mysqlModule}->executeQuery($self->{child}->{modules}->{mysqlModule}->createQuery('UPDATE `servers` SET `online` = ? WHERE  `ID` = ?'), scalar(keys(%{$self->{clients}}))+1, $self->{child}->{config}->{serverID});
        my $rawClient = $self->{mainSocket}->accept();
        IO::Epoll::epoll_ctl($self->{poller}, IO::Epoll::EPOLL_CTL_ADD(), fileno($rawClient), IO::Epoll::EPOLLIN());
        my $client = client->new($self->{child}, $rawClient);
        my $flags = fcntl($rawClient, Fcntl::F_GETFL, 0);
        $flags = fcntl($rawClient, Fcntl::F_SETFL, $flags | Fcntl::O_NONBLOCK);
        my $key = fileno($rawClient);
        $self->{clients}->{$key} = $client;
        $client->{key} = $key;
        $client->{properties}->{IP} = $self->getClientIP($client);
        $self->{child}->{loggedIPs}->{$client->{properties}->{IP}} = ($self->{child}->{loggedIPs}->{$client->{properties}->{IP}}) ? $self->{child}->{loggedIPs}->{$client->{properties}->{IP}}+1 : 1;
        if($self->{child}->{loggedIPs}->{$client->{properties}->{IP}} && $self->{child}->{loggedIPs}->{$client->{properties}->{IP}} > 3){
            $self->{child}->{logger}->info("Client ID ".$client->{key}." is being removed because they have more than 3 connections.");
            return $self->removeClient($client);
        }
        $self->{child}->{clientNum} = $self->{child}->{clientNum}+1;
        $self->{child}->{logger}->info('New client accepted! Client ID: '.$client->{key}.'.');
    }
    sub removeClient {
        my $self = shift;
        my $client = shift;
        $client->closeMethod();
        POSIX::close(fileno($client->{rawClient})); # Close by file descriptor.
        delete($self->{clients}->{$client->{key}});
        $self->{child}->{modules}->{mysqlModule}->executeQuery($self->{child}->{modules}->{mysqlModule}->createQuery('UPDATE `servers` SET `online` = ? WHERE  `ID` = ?'), scalar(keys(%{$self->{clients}}))+1, $self->{child}->{config}->{serverID});
        $self->{child}->{loggedIPs}->{$client->{properties}->{IP}} = $self->{child}->{loggedIPs}->{$client->{properties}->{IP}}-1;
        $self->{child}->{logger}->info("Client ID ".$client->{key}." has disconnected from the server.");
    }
    sub getClientIP {
        # Broken?
        my $self = shift;
        my $client = shift;
        
        return $client->{rawClient}->peerhost();
    }
    sub getClientByFD {
        my $self = shift;
        my $FD = shift;
        return $self->{clients}->{$FD};
    }
1;
