Getting started
===============

Refer to the JOP wiki for some general background and starting material:
http://www.jopwiki.com/Getting_started

Bare minimum to get stuff working
---------------------------------

    cd jop/
    make tools
    cd asm/
    sh jopser.sh
    cd ../xilinx/nexys2/
    ise jop.xise

Then synthesise, implement, create a bit file and program it onto the board.

    cd ../../
    make java_app P3=NexysTest

Now you can download the image in `java/target/dist/bin/` via serial using
the `down.exe` app (which you can run via wine, see http://www.jopwiki.com/Linux)

And you should see the LEDs scanning back and forth while the 7seg increments
once per second.

The code causing this demo to happen is in `java/target/src/test/test/NexysTest.java`
