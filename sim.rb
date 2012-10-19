#!/usr/bin/env ruby

require "metro.rb"
Thread.abort_on_exception = true   # to avoid hiding errors in threads 

# read command line and decide on display(), verify() or simulate()

$simFileHeaders = ["=== Lines ===", "=== Trains ===", "=== Passengers ===", "=== Output ===" ]
    
def readParams(fname,lines,numTrains,passengers,simOut)
    begin
        f = File.open(fname)
    rescue Exception => e
        puts e
        exit(1)
    end

    headerLines = $simFileHeaders[0]
    headerTrains = $simFileHeaders[1]
    headerPassenger = $simFileHeaders[2]
    headerOutput = $simFileHeaders[3]

    section = nil
    f.each_line{|line|
        line.chomp!
        line.strip!
        if line == "" || line =~ /^%/
            # skip blank lines & lines beginning with %
        elsif line == headerLines || line == headerTrains ||
		line == headerPassenger || line == headerOutput
            section = line
        elsif section == headerLines
            parts = line.split(',')
            color = parts.shift.strip
            stations = []
            parts.each { |s| stations.push(s.strip!) }
            lines[color] = stations
        elsif section == headerTrains
            parts = line.split('=')
            color = parts.shift.strip
            numTrains[color] = parts[0].to_i
        elsif section == headerPassenger
            parts = line.split(',')
            name = parts.shift.strip
            stations = []
            parts.each { |s| stations.push(s.strip!) }
            passengers[name] = stations
        elsif section == headerOutput
            simOut.push(line)
        else
            puts "ERROR: simFile format error at #{line}"
            exit(1)
        end
    }
end

def printParams(lines,numTrains,passengers)
    headerLines = $simFileHeaders[0]
    headerTrains = $simFileHeaders[1]
    headerPassenger = $simFileHeaders[2]
    headerOutput = $simFileHeaders[3]
    
    puts headerLines
    lines.each { |name,stations| 
	s = ""
	s << name
	stations.each { |st| s << ", " << st }
	puts s
    }
    
    puts headerTrains 
    numTrains.each { |name,num| puts "#{name}=#{num}" }
    
    puts headerPassenger 
    passengers.each { |name,stations| 
    	s = ""
	s << name
	stations.each { |st| s << ", " << st }
	puts s
    }
    
    puts headerOutput
end

def goSim
    if ARGV.length != 2
        puts "Usage: ruby sim.rb [simulate|verify|display] <simFileName>"
        exit(1)
    end
    
    # list command line parameters
    cmd = "% ruby sim.rb "
    ARGV.each { |a| cmd << a << " " }
    puts cmd

    lines = { }
    numTrains = { }
    passengers = { }
    simOut = []
    readParams(ARGV[1],lines,numTrains,passengers,simOut)
  
    if ARGV[0] == "verify"
        result = verify(lines,numTrains,passengers,simOut)
        if result
            puts "VALID"
        else
            puts "INVALID"
            exit(1)
        end

    elsif ARGV[0] == "simulate"
	printParams(lines,numTrains,passengers)
        simMonitor = {}
        lines.each_key { |k| simMonitor[k] = Monitor.new }	
        simulate(lines,numTrains,passengers,simMonitor)

    elsif ARGV[0] == "display"
        display(lines,passengers,simOut)

    else
        puts "Usage: sim [simulate|verify|display] <simFileName>"
        exit(1)
    end
    exit(0)
end

goSim
