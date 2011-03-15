Getting started
===============

Refer to the JOP wiki for some general background and starting material:
http://www.jopwiki.com/Getting_started

Bare minimum to get stuff working
---------------------------------

### Build tools and jopser image

    cd jop/
    make tools
    cd asm/
    sh jopser.sh
    
### Create BIT file for FPGA

    cd ../xilinx/nexys2/
    ise jop.xise

Then synthesise, implement, create a bit file and program it onto the board. You
could also use one of the pre-provided BIT files in the Downloads link above.

### Compile demo app

    cd ../../
    make java_app P3=NexysTest

Now you can download the image `java/target/dist/bin/NexysTest.jop` via serial using
the `down_posix` app:

    gcc -o down_posix ./c_src/down_posix.c
    ./down_posix -usb -e java/target/dist/bin/NexysTest.jop /dev/ttyS0

After it finishes, you should see the LEDs scanning back and forth while the 7seg
increments once per second. Also, the current time should print out on the serial
console.

The code causing this demo to happen is in `java/target/src/test/test/NexysTest.java`
