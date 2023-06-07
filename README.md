# PiCAN
Can a Raspberry Pi collect CAN control frames, conveniently classifying messages and categorizing corresponding communications into clusters?  I hope it can...

## Setup
This program was developed on a Raspberry Pi 3 with Python 3.9.2

To get started, clone this repo onto your Raspberry Pi and navigate to the repo in the terminal.

For best practices, its recomended to setup a python virtual environment to avoid conflicting with the packages which may or may not already be globally installed.
In the terminal, run the following to create a virtual environment called 'venv'
```bash
$ python -m venv venv
```
Next enter the virtual environment.
```bash
$ source ./venv/bin/activate
```
You should notice that your terminal now appends `(venv)` to the current line

The last order of business is installing all of the python packages required for this program. (These packages and their specific version number are stored in the `requirements.txt` file)
```bash
$ pip install -r requirements.txt
```

### VCAN linux interface
In the absence of a robot and real hardware, you are able to start up a virtual CAN interface using socketcan in the linux terminal:
```bash
$ sudo modprobe vcan

Create a vcan network interface with the specific name "vcan0"
$ sudo ip link add dev vcan0 type vcan
$ sudo ip link set vcan0 up
```

You can then send arbitrary CAN messages via the `can-utils` command line tools:
```bash
$ cansend vcan0 0FF#00112233
$ cansend vcan0 ABCD0123#010203040506
$ cangen vcan0 -v
```
