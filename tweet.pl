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
use Data::Dumper;

my ($post_tweet,$send_dm,$user,$authorize,$help);

usage() if (!GetOptions(
        'post=s'   => \$post_tweet,
        'direct-message=s' => \$send_dm,
        'user=s'        => \$user, 
        'authorize=s'        => \$authorize,
        'help'                => \$help,
    ));

usage() if ( defined $help );

if( defined $authorize ) {
    print "New user authorization : $authorize \n";

}
else {

    usage() unless (defined $post_tweet or defined $send_dm);
}


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
    if (defined $authorize) {
        auth_new_user($main_config,$authorize);
    }else{
        post_tweet($main_config,$user,$post_tweet) if defined $post_tweet;
        send_dm($main_config,$user,$send_dm) if defined $send_dm;
    }
};
if ( my $err = $@ ) {
    warn "HTTP Response Code: ", $err->code, "\n",
    "HTTP Message......: ", $err->message, "\n",
    "Twitter error.....: ", $err->error, "\n";
}



## METHODS 

sub post_tweet {
    my ($main_config,$user,$message) = @_;
    my $consumer_key = $main_config->{consumer_key};
    my $consumer_secret = $main_config->{consumer_secret};
    my $token;
    my $token_secret;

    $user = lc $user;

    if ( defined $main_config->{$user} ) {
        #this will be used to post tweet in given user timeline 
        #otherwise will posted in own user

        $token = $main_config->{$user}->{token};
        $token_secret = $main_config->{$user}->{token_secret};
    }
    else {
         $token = $main_config->{token};
         $token_secret = $main_config->{token_secret};
    }

    print "Please wait ...\n";
    my $nt = Net::Twitter->new(
        traits   => [qw/API::RESTv1_1/],
        consumer_key        => $consumer_key,
        consumer_secret     => $consumer_secret,
        access_token        => $token,
        access_token_secret => $token_secret,
        ssl                 => 1,
    );
    my $result = $nt->update($message);

    print "User : $user \n" if (defined $user);
    print "Posted Message :  $message \n";
}


sub send_dm {
    my ($main_config,$user,$message) = @_;
    my $token = $main_config->{token};
    my $token_secret = $main_config->{token_secret};
    my $consumer_key = $main_config->{consumer_key};
    my $consumer_secret = $main_config->{consumer_secret};

    #if no user specified DM will send to own user
    $user = $main_config->{owner} unless defined $user;

    print "Please wait ...\n";
    my $nt = Net::Twitter->new(
        traits   => [qw/API::RESTv1_1/],
        consumer_key        => $consumer_key,
        consumer_secret     => $consumer_secret,
        access_token        => $token,
        access_token_secret => $token_secret,
        ssl                 => 1,
    );
    my $result = $nt->new_direct_message({
            screen_name => $user,
            text        => $message
        });
    print "User : $user \n";
    print "Posted Message :  $message \n";

}


sub auth_new_user {
    my ($main_config,$user) = @_;
    my $consumer_key = $main_config->{consumer_key};
    my $consumer_secret = $main_config->{consumer_secret};

    my $nt = Net::Twitter->new(
        traits          => ['API::RESTv1_1', 'OAuth'],
        consumer_key    => $consumer_key,
        consumer_secret => $consumer_secret
    );
    
    print "Please wait ...\n";
    unless ( $nt->authorized ) {
        # The client is not yet authorized: Do it now
        print "Let the $user authorize this app at \n\n\t", $nt->get_authorization_url, "\n\n";
        print "Enter the authorization PIN# provided by the $user : \t";

        my $pin = <STDIN>;
        chomp $pin;

        print "Please wait ...\n";

        if ( $pin ) {
            eval {
                update_config($nt->request_access_token(verifier => $pin),$main_config); 
            };
            if ($@) {
                my $msg = $@;
                print "Exception : $msg\n";
                print "Authorization fails $user\n";
            }
        }else {
            print "Undefined PIN# \n";
        }
    }
}

sub update_config {
   my($token, $token_secret, $user_id, $screen_name,$main_config) = @_;
   
   $main_config->{lc "\@$screen_name"} = {
       token => $token,
       token_secret => $token_secret,
       user_id => $user_id,       
   };

   open FH, ">", "$config_file" or die $!;
   print FH Dumper $main_config;
   close(FH);

   print "Config updated for new user : \@$screen_name\n";
   print "Hereafter you can post tweet for the user \@$screen_name\n";
   send_dm($main_config,"\@$screen_name","Thank you for Authorizing us \@$main_config->{owner}");
}

sub usage {
    print "\nusage: perl tweet.pl [-u|--user ] \"\@virendra_baskar\" [-p|--post] | [-d|--direct-message] \"Hello world \"\n\n ";
    print "Example :\n";
    print "\t to post tweet on own acc  :\t perl tweet.pl  -p \"Post from terminal #perl \"\n\n";
    print "\t to authorize new user     :\t perl tweet.pl  -a \"\@virendra_baskar\"\n\n";
    print "\t to post tweet on user acc :\t perl tweet.pl  -u \"\@virendra_baskar\" -p \"Post from terminal #perl \"\n\n";
    print "\t to send DM                :\t perl tweet.pl  -u \"\@virendra_baskar\" -d \"DM from terminal #perl \"\n\n";
    exit;
}


# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3
