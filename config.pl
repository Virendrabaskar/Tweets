#!/usr/bin/perl -w

#
# config.pl
#
# Developed by Baskar Nallathambi <baskarmusiri@gmail.com>
#
# Changelog:
# 2015-06-26 - Main config file


{
    # Get from https://apps.twitter.com/
    consumer_key    => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    consumer_secret => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    token           => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    token_secret    => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    owner           => "user_name",

    #Following keys will get only client authorize the twitter app
    #App user (Client)
    '@other_user' => {
        token => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        token_secret => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
}

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3

