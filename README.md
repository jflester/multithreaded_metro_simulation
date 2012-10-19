<h4>METRO</h4>
A multithreaded metro simulation that simulates the Washington Metro (though could
easily be adapted to other metro systems) by creating Train and Person threads.

Threads are compliant with *Ruby 1.8.6*

Threads may **not** work properly in *Ruby 1.8.7* versions and later.

Method *verify* has **not** been implemented. If written, verify should be used
to make sure that the threads are running correctly:
ie. that people only get off trains at stops and not between stops;
trains only stop at stations and not elsewhere; etc.
<h4>SIM</h4>
Reads the command line and decides on the appropiate action.

Command line may called with one of three options: *display*, *verify*, or *simulate*.

Verify has **not** been implemented in **METRO.RB**
<h4>DISPLAYEXAMPLE</h4>
Provides function *displayState* and an example of how to use said function.
<h4>GOTEST</h4>
Runs a few tests on **METRO.RB**