#!/usr/bin/env ruby

require 'rubygems'
require 'fql'
require './config'

options = {access_token: FB_ACCESS_TOKEN}
location_matches = ["universityofstandrews", "standrews", "st.andrews", "saintandrews"]

friends =  Fql.execute('SELECT uid, name, affiliations, current_location, education FROM user WHERE uid=me() OR uid IN (SELECT uid2 FROM friend WHERE uid1 = me())',options)

friends = friends.find_all { |f| 
   (f["affiliations"].map{|e| e["nid"]}.include? 16777588) || (f["education"].map{|e| e["school"]["id"]}.include? 16777588)
}
uids = friends.map{|f| f["uid"]}.join(",")


events = {}
puts "fetching events..."
ev = Fql.execute("SELECT name, eid, start_time, end_time, host, description, creator, location, privacy, venue FROM event WHERE eid IN (SELECT eid from event_member WHERE uid IN (#{uids})) AND privacy='open'", options)
ev.each do |e|
  if e["location"]
    location = e["location"].downcase.gsub(/\s/, "") 
    if location_matches.any? { |w| location =~ /#{w}/ }
      events[e["eid"]] = e
    end
  end
end

puts "found #{events.count} events"
