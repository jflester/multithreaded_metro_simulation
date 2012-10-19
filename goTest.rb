#!/usr/bin/env ruby

for t in 1..4 do
	cmd = "ruby sim.rb display pub#{t}.in > pub#{t}-display.log"
        puts "TESTING: #{cmd}"
        system(cmd)
end

for t in 6..9 do
	cmd = "ruby sim.rb verify pub#{t}.in > pub#{t}-verify.log"
        puts "TESTING: #{cmd}"
        system(cmd)
end

for t in 1..6 do
	cmd = "ruby sim.rb simulate pub#{t}.in > pub#{t}-simulate.log"
        puts "TESTING: #{cmd}"
        system(cmd)
end

