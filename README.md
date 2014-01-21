# gypsee

"Geocaching - Your Profile" cache finds list generator for Livejournal

## Introduction

This was originally a Vimscript macro, but I decided to rewrite it as a Ruby script
using Nokogiri to parse the geocaching HTML to make it more robust.

## Usage

Make sure you have the Nokogiri gem:

    gem install nokogiri

First, log in to geocaching.com and download the "Your Profile" page at http://www.geocaching.com/my/

Then run the script on it:

    ruby gyp.rb yourprofile.htm
    
By default, the script will extract the geocache finds from the most recent full weekend. (Saturday and Sunday)
However, you can also specify a date range. For example:

    ruby gyp.rb yourprofile.htm 2014-01-01 2014-01-07
    
<!-- vim: set tw=0 -->