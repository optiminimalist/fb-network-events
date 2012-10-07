#!/usr/bin/env ruby

require 'rubygems'
require 'fql'
require './config'


options = {access_token: FB_ACCESS_TOKEN}
location_matches = ["universityofstandrews", "standrews", "st.andrews", "saintandrews"]

# Query all friends
friends =  Fql.execute('SELECT uid, name, affiliations, current_location, education  
                        FROM user 
                        WHERE uid=me() OR uid IN 
                            (SELECT uid2 FROM friend WHERE uid1 = me())',options)

# Only use people related to the University of St Andrews
friends = friends.find_all { |f| 
   (f["affiliations"].map{|e| e["nid"]}.include? 16777588) || (f["education"].map{|e| e["school"]["id"]}.include? 16777588)
}




events = {}
puts "fetching events..."

# query all events by friends
uids = friends.map{|f| f["uid"]}.join(",")
ev = Fql.execute("SELECT name, eid, start_time, end_time, host, description, creator, location, privacy, venue 
                  FROM event 
                  WHERE eid IN 
                      (SELECT eid from event_member WHERE uid IN (#{uids}))
                  AND privacy='open'", options)
                  
# evaluate if events should be included in the list
ev.each do |e|
  match = false
  
  if e["location"]
    location = e["location"].downcase.gsub(/\s/, "") 
    if location_matches.any? { |w| location =~ /#{w}/ }
      match = true
    end
  end
  
  events[e["eid"]] = e if match
  
end

puts "found #{events.count} events"
