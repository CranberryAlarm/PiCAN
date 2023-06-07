import can
import time
import platform

def main():
	if platform.system() != 'Linux':
		print('Get clowned on fool')
		return
		
	with can.Bus(interface='socketcan', channel='vcan0') as bus:
		# Create a listener
		buffered_reader = can.BufferedReader()
		# Add the listener to a new notifier looking at the bus
		can.Notifier(bus, [buffered_reader]) 
		
		# Example of how to send a CAN message
		#bus.send(can.Message(arbitration_id=0x00000001, is_extended_id=True, data=[0x00,0x11,0x22,0x33]))
		
		# Read in messages with a 2 second looping timeout
		while True:
			msg = buffered_reader.get_message(2.0);
			if msg == None:
				print('no message rxed')
			else:
				print(msg)
		

if __name__ == '__main__':
	main()
