# Lab 4: Hex Calculator
#### Objective: Program the FPGA on the Nexys A7-100T board to function as a simple hexadecimal calculator capable of adding and subtracting four-digit hexadecimal numbers using a 16-button keypad module (Pmod KYPD) connected to the Pmod port JA (See Section 10 of the Reference Manual) directly or via an optional 2x6-pin cable with three dots (or VDD/GND) facing up on both ends

### How to Use:

* Enter a multi-digit hex number using the keypad one character at a time to appear on the 7-segment displays

* Enter the first operand, press the “+” key (BTNU)

* Enter the second operand and press the “=” key (BTNL) so that the value of the sum of the operands appears on the display

* Press the “clear” key (BTNC) to set the result on the display to zero

Watch Result: https://youtube.com/shorts/Gyj_-WFfM5Q?feature=share

### [Modifications](https://github.com/janethamrani/dsd//tree/main/Lab-4/Modifications)

#### A) Edit the leddec16 module to perform leading zero suppression

* With the leading zeros suppressed, the number “0023” appears as “23” 

#### B) Expand the calculator to also do subtraction operations

* Use the button BTND (pin P18 on the Nexys A7-100T board) as the “–” key

Watch Result: https://youtube.com/shorts/3PuUlYVWnnc?feature=share
