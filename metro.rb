###############################################################################
### Description: A multi-threaded Ruby program that simulates               ###
###              the Washington Metro by creating Train and Person threads  ###
### Name: John Flester                                                      ###
###                                                                         ###
### Threads are compliant with Ruby 1.8.6                                   ###
### Threads may not work properly in Ruby 1.8.7 versions and later.         ###
###############################################################################

require "monitor"
Thread.abort_on_exception = true   # to avoid hiding errors in threads 
$station = {}
$finish = 0
  
def people(name, persons, lines, cond, monitors)
  persons_two = persons.dup
  lines_two = lines.dup
  off = ""
  on = ""
  nameTrain = ""
  for x in 0..persons_two[name].length - 1
    lines_two.keys.each{ |colour|
      right = 0
      lines_two[colour].each{ |stop|
        if (stop.eql?persons_two[name][x])
          right += 1
          on = stop
        end
        if (right == 1)
          lines_two[colour].each{ |stop|
            if (stop.eql?persons_two[name][x+1])
              right +=1
              off = stop
            end
          }
        end
      }
      if (right == 2)
        monitors[colour].synchronize {
          cond[colour].wait_until{$station[on][colour].length == 1}
          $station[on][colour].keys.each{ |number|
            nameTrain = colour + " " + number.to_s
            puts name + " boarding train " + nameTrain + " at " + on + "\n"
            cond[colour].wait_until{$station[off][colour][number]}
            $stdout.flush
          }
          puts name + " leaving train " + nameTrain + " at " + off + "\n"
          $stdout.flush
          cond[colour].broadcast
        }
      else
        next
      end
      q = x + 1
      if (q = persons_two[name].length - 1)
        break
      end
    }
  end
  $finish += 1
end

def trains(name, wMonitor, line, condTrain, condPerson, numPeople)
  line_two = line.dup
  if (name =~ /(\w+)\s(\d+)/)
    colour = $1
    number = $2
    stop_one = ""
    first = 1
    line_two[colour].each { |z|
      if (first == 1)
        stop_one = z
        first = 0
      else
        break
      end
    }
    first = 1
    wMonitor.synchronize {
      condTrain.wait_until{$station[stop_one][colour].length == 0}
      $station[stop_one][colour][number] = 1
      puts "Train " + name + " entering " + stop_one + "\n"
      condPerson.broadcast
      condTrain.wait 0.01
      $station[stop_one][colour].delete(number)
      puts "Train " + name + " leaving " + stop_one + "\n"
      $stdout.flush
      condTrain.broadcast
    }
    if (numPeople == 0)
      line_two[colour].each{ |stop| #trip going down
        if (first == 1)
          first = 0
          next
        end
        wMonitor.synchronize {
          condTrain.wait_until{$station[stop][colour].length == 0}
          $station[stop][colour][number] = 1
          puts "Train " + name + " entering " + stop + "\n"
          condPerson.broadcast
          condTrain.wait 0.01
          $station[stop][colour].delete(number)
          puts "Train " + name + " leaving " + stop + "\n"
          $stdout.flush
          condTrain.broadcast
        }
      }
      line_two[colour] = line_two[colour].reverse
      first = 1
      line_two[colour].each { |stop| #and now the trip back up
        if (first == 1)
          first = 0
          next
        end
        wMonitor.synchronize {
          condTrain.wait_until{$station[stop][colour].size == 0}
          $station[stop][colour][number] = 1
          puts "Train " + name + " entering " + stop + "\n"
          condPerson.broadcast
          condTrain.wait 0.01
          $station[stop][colour].delete(number)
          puts "Train " + name + " leaving " + stop + "\n"
          $stdout.flush
          condTrain.broadcast
        }
      }
      else
        while ($finish != numPeople)
          line_two[colour].each{ |stop| #going down
            if (first == 1)
              first = 0
              next
            end
            wMonitor.synchronize {
              condTrain.wait_until{$station[stop][colour].length == 0}
              $station[stop][colour][number] = 1
              puts "Train " + name + " entering " + stop + "\n"
              $stdout.flush
              condPerson.broadcast
              condTrain.wait 0.01
              $station[stop][colour].delete(number)
              puts "Train " + name + " leaving " + stop + "\n"
              $stdout.flush
              condTrain.broadcast
            }
          }
          line_two[colour] = line_two[colour].reverse
          first = 1
          line_two[colour].each{ |stop| #trip going back up
            if (first == 1)
              first = 0
              next
            end
            wMonitor.synchronize {
              condTrain.wait_until{$station[stop][colour].size == 0}
              $station[stop][colour][number] = 1
              puts "Train " + name + " entering " + stop + "\n"
              $stdout.flush
              condPerson.broadcast
              condTrain.wait 0.01
              $station[stop][colour].delete(number)
              puts "Train " + name + " leaving " + stop + "\n"
              $stdout.flush
              condTrain.broadcast
            }
          }
          line_two[colour] = line_two[colour].reverse
          first = 1
        end
      end
    end
  end

#----------------------------------------------------------------
# Metro Simulator
#----------------------------------------------------------------

def simulate(lines,numTrains,passengers,simMonitor)
    # puts lines.inspect
    # puts numTrains.inspect
    # puts passengers.inspect
    # puts simMonitor.inspect
  trainT = []
  passT = []
  trainNames = {}
  condPass = {}
  condTrain = {}
  numPeople = 0
  simMonitor.keys.each{ |colour|
    condPass[colour] = simMonitor[colour].new_cond
    condTrain[colour] = simMonitor[colour].new_cond
  }
  lines.keys.sort.each{ |m|
    lines[m].each{ |stations|
      if ($station[stations] == nil)
        $station[stations] = {}
      end
      $station[stations]["passenger"] = {}
      $station[stations][m] = {}
    }
  }
  lines.keys.each{ |colour|
    lines[colour].each{ |stop|
      $station.keys.each{ |stop_two|
        if (stop.eql?stop_two)
          $station[stop_two][colour] = {}
        end
      }
    }
  }
  numTrains.keys.each{ |name|
    for v in 1..numTrains[name]
      trainNames[name + " " +v.to_s] = name
    end
  }
  passengers.keys.sort.each{ |q|
    numPeople += 1
    $station.keys.sort.each{ |t|
      if (passengers[q][0] == t)
        $station[t]["passenger"][q] = 1
      end
    }
  }
  passengers.keys.each{ |q|
    passT.push(Thread.new do people(q, passengers, lines, condPass, simMonitor) end)
  }
  trainNames.keys.each{ |name|
    trainT.push(Thread.new do trains(name, simMonitor[trainNames[name]], lines, condTrain[trainNames[name]], condPass[trainNames[name]], numPeople) end)
  }
  for x in 0..trainT.length - 1
    trainT[x].join()
  end
  for x in 0..passT.length - 1
    passT[x].join()
  end
end

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
    puts color + "\n"
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
  puts "\n"
end

def display(lines,passengers,output)

    # puts lines.inspect
    # puts passengers.inspect
    # puts output.inspect
  stations = {}
  lines.keys.sort.each{ |d|
    lines[d].each{ |station|
      if (stations[station] == nil)
        stations[station] = {}
      end
      stations[station]["passenger"] = {}
      if (stations[station][d] == nil)
        stations[station][d] = {}
      end
    }
  }
  passengers.keys.sort.each{ |q|
    stations.keys.sort.each{ |r|
      if (passengers[q][0] == r)
        stations[r]["passenger"][q] = 1
      end
    }
  }
  trains = {}
  displayState(lines, stations, trains)
  output.each {|o|
    puts o + "\n"
    if (o =~ /(\w+)\s/)
      first = $1
      if (first.eql?"Train") then
        regex = o.scan(/^(\w+)\s(\w+)\s(\d+)\s(\w+)\s(\S+(\s\S+)*)$/)
        if (regex[0][3].eql?"entering") then
          stations[regex[0][4]][regex[0][1]][regex[0][2]] = 1
        elsif (regex[0][3].eql?"leaving") then
          stations[regex[0][4]][regex[0][1]].delete(regex[0][2])
        end
      else
        regex = o.scan(/^(\S+(\s\S+)*)\s(\w+)\s(\w+)\s(\w+)\s(\d+)\s\w+\s(\S+(\s\S+)*)$/)
        regex = nil_remover(regex)
        name = regex[3] + " " + regex[4]
        if (trains[name] == nil)
          trains[name] = {} #train hasn't been added yet, so add it
        end
        if (regex[1].eql?"boarding") then
          stations[regex[5]]["passenger"].delete(regex[0]) #delete person
          trains[name][regex[0]] = 1 #add person to train
        elsif (regex[1].eql?"leaving") then
          trains[name].delete(regex[0]) #delete person from train
          stations[regex[5]]["passenger"][regex[0]] = 1 # add person to station
        end
      end
    end
    displayState(lines,stations,trains)
  }
end

def nil_remover(list)
  noNils = []
  x = 0
  for i in 0..list[0].length - 1
    if (list[0][i].nil?)
      next
    else
      noNils[x] = list[0][i]
      x += 1
    end
  end
  noExtras = []
  noExtras[0] = noNils[0]
  go = 0
  for i in 1..noNils.length - 1
    if (noNils[i].eql?"leaving")
      go = i
      break
    elsif (noNils[i].eql?"boarding")
      go = i
      break
    end
  end
  x = 1
  for i in go..noNils.length - 1
    noExtras[x] = noNils[i]
    x += 1
  end
  noExtras
end

#----------------------------------------------------------------
# Simulation Verifier
#----------------------------------------------------------------

def verify(lines,numTrains,passengers,output)

    # puts lines.inspect
    # puts numTrains.inspect
    # puts passengers.inspect
    # puts output.inspect
    # AND COMPLETELY OPTIONAL
    # return false
    return true
end