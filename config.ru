require './scouting'
app = Scouting
files = Rack::File.new('public')

run Rack::Cascade.new([files,app], [405,404,403])