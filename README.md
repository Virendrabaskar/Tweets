# Tweets
Post tweets and send DM in twitter from command line.

`perl tweet.pl --authorize @user_name`

`perl tweet.pl --user @user_name --post "Hello World !"`

`perl tweet.pl --help`

####Pre-Requiste 

#####Perl Modules
1. Net::Twitter
1. Config::Any
1. FindBin
1. Getopt::Long
1. Data::Dumper


To install perl module
 
  `sudo cpanm install Net::Twitter`

#####Twitter Keys and Access Tokens

Create an app and get access keys from here https://apps.twitter.com/


#####How to use

* Set valid keys in config file.
* Create a Sym link for tweet.pl and config.pl inorder to access from everywhere in terminal.
 
  `sudo ln -s <path>/tweet.pl /usr/bin/tweet`
   
  `sudo ln -s <path>/config.pl /usr/bin/config.pl`

  `tweet --help`
