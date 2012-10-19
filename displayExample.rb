#----------------------------------------------------------------
# Simulation Display
#----------------------------------------------------------------

# line = hash of line names to array of stops
# stations = hash of station names => 
#                  hashes for each line => hash of trains at station
#               OR hash for "passenger" => hash of passengers at station
# trains = hash of train names =>  hash of passengers

def displayState(lines,stations,trains)
    lines.keys.sort.each { |color|
        stops = lines[color]
        puts color
        stops.each { |stop| 
            pStr = ""
            tStr = ""
            
            stations[stop]["passenger"].keys.sort.each { |passenger|
                pStr << passenger << " "
            }
            
            stations[stop][color].keys.sort.each { |trainNum| 
                tr = color+" "+trainNum
                tStr << "[" << tr
                if trains[tr] != nil
                    trains[tr].keys.sort.each { |p|
                        tStr << " " << p
                    }
                end
                tStr << "]"
            }
            
            printf("  %25s %10s %-10s\n", stop, pStr, tStr)
        }	
    }
    puts 
end

# Example of how to use displayState
def displayExample 
    lines = { }
    lines["Black"] = ["S1","S2"] 

    stations = {}
    stations["S1"] = { }
    stations["S2"] = { }
    stations["S1"]["Black"] = { } 
    stations["S2"]["Black"] = { } 
    stations["S1"]["passenger"] = { } 
    stations["S2"]["passenger"] = { } 
    stations["S1"]["passenger"]["Jack"] = 0
    stations["S2"]["passenger"]["John"] = 0

    trains = { }
    trains["Black 1"] = { }
    trains["Black 1"]["Jim"] = 0

    puts "Lines = " + lines.inspect
    puts "Stations = " + stations.inspect
    puts "Trains = " + trains.inspect

    displayState(lines,stations,trains)

    stations["S2"]["Black"]["1"] = 0
    displayState(lines,stations,trains)

    trains["Black 1"].delete("Jim")
    stations["S2"]["passenger"]["Jim"] = 0
    displayState(lines,stations,trains)
end

displayExample

