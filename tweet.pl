#!/usr/bin/perl -w

#
# tweet.pl
#
# Developed by Baskar Nallathambi <baskarmusiri@gmail.com>
#
# Changelog:
# 2015-06-26 - created
#

use strict;
use Config::Any;
use FindBin;
use Getopt::Long;
use Net::Twitter;


my ($post_tweet,$send_dm,$account,$help);

usage() if (!GetOptions(
        'post=s'   => \$post_tweet,
        'direct_message=s' => \$send_dm,
        'account=s'        => \$account, 
        'help'                => \$help,
    ));

usage() if ( defined $help );

usage() unless (defined $post_tweet or defined $send_dm);


#Get the config keys 
my $config_file = "$FindBin::Bin/config.pl";
die "Invalid file $config_file ! " unless -f $config_file;
my $config = Config::Any->load_files(
    {
        files   => [$config_file],
        use_ext => 1
    }
);
my $main_config = $config->[0]->{$config_file};



eval {
    post_tweet($main_config,$account,$post_tweet) if defined $post_tweet;
    send_dm($main_config,$account,$send_dm) if defined $send_dm;
};
if ( my $err = $@ ) {
    warn "HTTP Response Code: ", $err->code, "\n",
    "HTTP Message......: ", $err->message, "\n",
    "Twitter error.....: ", $err->error, "\n";
}



## METHODS 

sub post_tweet {
    my ($main_config,$account,$message) = @_;
    my $consumer_key = $main_config->{consumer_key};
    my $consumer_secret = $main_config->{consumer_secret};
    my $token;
    my $token_secret;

    if ( defined $main_config->{$account} ) {
        #this will be used to post tweet in given account timeline 
        #otherwise will posted in own account

        $token = $main_config->{$account}->{token};
        $token_secret = $main_config->{$account}->{token_secret};
    }
    else {
         $token = $main_config->{token};
         $token_secret = $main_config->{token_secret};
    }

    my $nt = Net::Twitter->new(
        traits   => [qw/API::RESTv1_1/],
        consumer_key        => $consumer_key,
        consumer_secret     => $consumer_secret,
        access_token        => $token,
        access_token_secret => $token_secret,
        ssl                 => 1,
    );
    my $result = $nt->update($message);

    print "User : $account \n" if (defined $account);
    print "Posted Message :  $message \n";
}


sub send_dm {
    my ($main_config,$account,$message) = @_;
    my $token = $main_config->{token};
    my $token_secret = $main_config->{token_secret};
    my $consumer_key = $main_config->{consumer_key};
    my $consumer_secret = $main_config->{consumer_secret};

    #if no account specified DM will send to own account
    $account = $main_config->{owner} unless defined $account;

    my $nt = Net::Twitter->new(
        traits   => [qw/API::RESTv1_1/],
        consumer_key        => $consumer_key,
        consumer_secret     => $consumer_secret,
        access_token        => $token,
        access_token_secret => $token_secret,
        ssl                 => 1,
    );
    my $result = $nt->new_direct_message({
            screen_name => $account,
            text        => $message
        });
    print "User : $account \n" if (defined $account);
    print "Posted Message :  $message \n";

}


sub usage {
    print "\nusage: perl tweet.pl [-a|--account ] \"\@virendra_baskar\" [-p|--post] | [-d|--direct_message] \"Hello world \"\n\n ";
    print "Example :\n";
    print "\t to post tweet on user acc :\t perl tweet.pl  -a \"\@virendra_baskar\" -p \"Post from terminal #perl \"\n\n";
    print "\t to post tweet on own acc  :\t perl tweet.pl  -p \"Post from terminal #perl \"\n\n";
    print "\t to send DM                :\t perl tweet.pl  -a \"\@virendra_baskar\" -d \"DM from terminal #perl \"\n\n";
    exit;
}


# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3
