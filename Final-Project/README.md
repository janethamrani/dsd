# Final Project: Car Parking System Using a Finite State Machine

![image](https://user-images.githubusercontent.com/26263012/168820971-7d5e2f19-2323-444a-98ee-178d70dd6ba8.png)

For this project, I used code for a Car Parking System from [FPGA4Student](https://www.fpga4student.com/2017/08/car-parking-system-in-vhdl-using-FSM.html). This code is originially designed to be operated on a testbench, but for my project, I altered it to operate on a Nexys A7-100T FPGA Trainer board

### Finite State Machine

![image](https://user-images.githubusercontent.com/26263012/168822005-ddfa7c1a-3315-4baf-9a2d-9269e24d11e8.png)

Initially, the FSM is in IDLE state. If there is a vehicle coming detected by the front sensor, FSM is switched to WAIT_PASSWORD state for 4 cycles. The car will input the password in this state; if the password is correct, the gate is opened to let the car get in the car park and FSM turns to RIGHT_PASS state; a Green LED will be blinking. Otherwise, FSM turns to WRONG_PASS state; a Red LED will be blinking and it requires the car to enter the password again until the password is correct. When the current car gets into the car park detected by the back sensor and there is the next car coming, the FSM is switched to STOP state and the Red LED will be blinking so that the next car will be noticed to stop and enter the password. After the car passes the gate and gets into the car park, the FSM returns to IDLE state.


## Modifications
Since this project is designed to be implemented on a testbench, there is no set password; there are just test cases for when the password is correct or incorrect. I changed the code so that a user can initially set a password using the slide switches and then the password can be guessed on a keypad

FSM States:
* The finite-state machine uses a number of states to keep track of where we are in the system
  * bt_clr triggers the SET_PASS state, which is when the user will set the password for the system
     * In this state, the display is set to the 2-bit input data (data2), which is set by changing the slide switches
     * Once a bit is inputted (data2 /= 0), the pass variable, which holds the set password, is set to data2.
     * This triggers the next state, PASS_RELEASE, which checks if the user pressed bt_eq. 
     * If it is clicked, the system moves to the IDLE stage and the password is set
  * During the IDLE stage, it checks if the front_sensor is true, which means there is a car approaching. This triggers the WAIT_PASSWORD stage, which would require the car to input the password to the gate, so that it can be allowed entry. If the front_sensor variable is 0, it goes back to the IDLE stage as it continues to wait for an incoming car
     *  In the WAIT_PASSWORD stage, the bt_submit variable checks if the user has submitted their guess. If this is false, it waits for the user to input it from the keypad which is displayed on the 7-Segment Display. After inputting the first bit (kp_hit = '1'), nx_guess stores this bit, and moves to the GUESS_RELEASE stage, which waits for the button to be released. Once it is released, it goes back to the WAIT_PASSWORD stage, where the user can submit if they're done (bt_submit = '1'). If not, the cycle repeats as they add another bit to the password
     *  Once the password is submitted, it checks if the inputted password matches the set password. If so, they are let in (RIGHT_PASS state), and if not, it goes back to the IDLE stage where they input a new password
  * In the RIGHT_PASS stage, it checks the front_sensor and back_sensor variable. If these are both '1', it means as the current car is coming, there is another one behind so it needs to require the password for the following car. This triggers the WAIT_PASSWORD stage where the user has to input the password. If only the back_sensor is '1', this means there is no car and the stage goes back to IDLE as it waits for an incoming car

### Reflection

I'm very glad I chose this project to work on as it helped me understand FSM which can be useful in the future. To complete this project, I mainly reviewed [Lab-4](https://github.com/janethamrani/dsd/tree/main/Lab-4) to understand to utilize the keypad. I initially had trouble understanding the connection between the physical keypad and the code and how they are connected, since my only experience with coding hardware is Arduino. However, after reviewing the code and reading other documentation I began to understand how it all works and how the constraint files relates to source files as well. I wasn't able to run this program on my FPGA board, however, because of how I couldn't figure out how to randomize the front and back sensor variables. Nevertheless, I feel accomplished with how this turned out and how much stronger my understanding of VHDL, FPGA boards, and FSM has become 



