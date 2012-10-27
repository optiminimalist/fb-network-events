#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require './config'

fbids = $stdin.readlines
fbids.each do |f|
 
  if /.*\/events\/([0-9]+)/ =~ f
    f = $1
  end
  
  puts f
  postData = Net::HTTP.post_form(URI.parse("http://#{USERNAME}:#{PASSWORD}@www.saintlet.com/dates/add/#{f}"), 
                                 {'postKey'=>'postValue'})

  puts postData.body
end