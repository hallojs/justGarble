JustGarble
==========

This is a fork of the justGarbled repo [1]_ which now contains a (quick and 
really dirty) Dockerfile to get things up and running again.


What is JustGarble?
-------------------

JustGarble is a system for garbling and evaluating boolean circuits. It also
contains modules to build circuits starting from individual gates, as well
as measuring latencies of various steps. Apart from building circuits in 
memory, circuits can also be read from files, specified in the Simple
Circuit Description (SCD) format, specified in the accompanying SCD_Format
file.

Setting up JustGarble
---------------------

*JustGarble is designed to work on x86-64 machines running Linux. We have
tested JustGarble on Ubuntu 12.10 with gcc-4.6.3, and expect it to work on
similar configurations.*

This is a pretty old setup. To get JustGarble running anyway, follow the steps
below:

- Build the conatiner: ``docker build -t <tag> .``
- Run the container: ``docker run -it --rm <tag>``
- To perform a quick test:

  - ``cd bin``
  - ``LD_LIBRARY_PATH=../../msgpack-c ./AESFullTest.out``

This should output two numbers, and these are approximate estimates 
for garbling and evaluation times on the system.


How to use JustGarble
---------------------

JustGarble is intended to be used as part of an external application,
from source and compiled along with the application. Examples of usage are
in tests. 

LargeCircuitTest shows how to build a large circuit on the fly, then garble
and evaluate it. The size of the circuit is to be provided as an argument
to the program. CircuitFileTest is a similar program that also shows how to
use the SCD read/write functions to store the generated circuit in a file.

- To build LargeCircuitTest, run: ``make Large``
- To run: ``cd bin`` and ``LD_LIBRARY_PATH=../../msgpack-c ./LargeCircuitTest.out <number_of_gates_in_thousands>``

- To build CircuitFileTest, run: ``make File``
- To run: ``cd bin`` and ``LD_LIBRARY_PATH=../../msgpack-c ./CircuitFileTest.out <number_of_gates_in_thousands>``

AESFullTest builds an AES circuit, then garbles and evaluates the circuit.
The circuit is built in stages, using smaller circuits that implement the 
S-BOX, GF(2^8) arithmetic etc, described in ``aescircuits.c``. After building,
the circuit is written to a file. The second part reads the circuit from a 
file, and garbles and evaluates the result, timing both operations. 
Writing the circuit to a file is not a necessary step, of course, and only
serves to demonstrate how reading and writing SCD files works. Moreover,
the building step has to be performed only once. Subsequent runs can just
use the circuit from the file and save time.

- To build AESFullTest, run ``make AES``
- To run: ``cd bin`` and ``LD_LIBRARY_PATH=../../msgpack-c ./bin/AESFullTest.out``

To use JustGarble in your system, a good starting point would be looking at
LargeCircuitTest if you plan to generate circuits on the fly, and 
CircuitFileTest if circuit generation happens rarely and common usage involves
loading template circuits. As in these files, your program would have to 
include the appropriate headers and need to initialize and manipulate 
GarbledCircuit data structures. Using JustGarble as a black-box component
does not require understanding how the internals of the system beyond what 
is provided in include/justGarble.h.


Changing the garbling scheme & DKC
----------------------------------

The default garbling scheme is GaX (i.e. free-xor is turned on, but garbled
row reduction is turned off). The default DKC is A2. To change these, modify
common.h and dkc.h accordingly and recompile. For example, to turn
on garbled row reduction, the ``#define ROW_REDUCTION``-line should be 
uncommented. Similarly, a different DKC can be turned on. 
For 80-bit block DKCs, make sure that the ``#define TRUNCATED``-
line is also uncommented.


Customization and Extensions
----------------------------

The starting point for customizing and extending JustGarble is understanding
the representation of circuits and the garbling process, and this would
involve following the control flow in ``garble.c``, ``eval.c``, ``gates.c``, 
and parts of ``circuits.c``. Adding your own garbling scheme involves changing 
the garbleCircuit and evaluate routines, specifically the steps in the main
loops of each. Designing a new DKC is much easier, especially if row-reduction 
is not enabled. To do this, just change the DKC operations in garbleCircuit
and evaluate. Changing the representation of circuits and bit-sizes of the 
keys involved is a much more invasive change, and will likely affect most of
the code base.


Other JustGarble features
-------------------------

The JustGarble framework can be used to measure the performance of new
designs for garbling schemes. The ``check.c`` file implements a randomized 
checking mechanism to check correctness, by comparing the garbled-evaluated
output with the output of the function implemented in code. 


Using without AES-NI
--------------------

JustGarble expects support for AESNI, and if the system does not have AES-NI,
then, the ``aes.c``, ``aes.h``, ``aes_locl.h``, ``garble.c``, and ``eval.c``
have to be patched at appropriate locations to use non-AESNI routines. This is
fairly straightforward to do, and does not have any side-effects, except for the 
slower garbling and evaluation times.

References
----------

.. [1] Bellare, M., Hoang, V. T., Keelveedhi, S., & Rogaway, P. (2013, May).Efficient garbling from a fixed-key blockcipher. In 2013 IEEE Symposium on Security and Privacy (pp. 478-492). IEEE.
