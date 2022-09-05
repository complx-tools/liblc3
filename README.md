liblc3
======

Extensible LC-3 Simulator Framework written in C++. Mainly used in CS2110 at Georgia Tech.  Maintained by Brandon (bwhitehead0308 [AT] gmail [DOT] com).

__Special Note__ Let me know if your school is using any portion of the tools provided here. The tools are subject to change every semester as new features are added or stuff is tweaked based on student feedback. I don't want to break anyone's setup, and would like to keep users in the loop with changes and suggest features.


# Features
* Support for all instructions including LC-3 interrupts.
* Support for the 2019 revision of the LC-3
* Support for running instructions, and assembling LC-3 assembly code.
* Features for running assembly code
    * Backstepping/Undoing instructions
    * Stepping into/out/over a subroutine
    * Running X number of instructions
* Trace file support.
* Powerful Debugger Framework
  * Ability to set breakpoints at specific locations
  * Ability to create watchpoints which trigger when a write to a register/memory location happens
  * Ability to set a temporary breakpoint/watchpoint that only triggers X times
  * Ability to mark a subroutine/trap as a blackbox and have the simulator automatically step over it
  * For the above ability to add a condition for the breakpoint/watchpoint to trigger
  * Ability to define all of the above in the assembly source file for easier debugging (and won't affect the grader)
* Ability to extend liblc3 via plugins
  * Plugins can add new device registers, traps, send interrupts, and add a new instruction


# Installation
Currently only Ubuntu packages are distributed to install those

$ sudo add-apt-repository ppa:tricksterguy87/complx
$ sudo apt update
$ sudo apt-get install -y liblc3

There's also a development package liblc3-dev which includes headers, cmake files for downstream projects.

