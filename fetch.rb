#!/usr/bin/env ruby

require 'rubygems'
require 'fql'
require './config'

options = {access_token: FB_ACCESS_TOKEN}


friends =  Fql.execute('SELECT uid, name, affiliations, current_location, education FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())',options)
puts friends

friends = friends.find_all { |e| 
   !e["affiliations"].map{|e| e["nid"]}.include? 16777588
}

puts friends.map{|f| f["education"]}.inspect
exit

events = {}
friends[0,30].each_with_index do |f,index|
  puts "(#{index+1}/#{friends.count}) fetching events from #{f['name']}"
  ev = Fql.execute("SELECT name,eid,start_time,end_time, host, description, creator, location, privacy, venue FROM event WHERE eid IN (SELECT eid from event_member WHERE uid = #{f['uid']})", options)
  
  ev.each do |e|
    if e["location"]
      location = e["location"].downcase.gsub(/\s/, "") 
      if ["universityofstandrews", "standrews", "st.andrews"].any? { |w| location =~ /#{w}/ }
        events[e["eid"]] = e
      end
    end
  end
end

puts "found #{events.count} events"
