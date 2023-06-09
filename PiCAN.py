import can
import time
import platform
import frc
import csv

def main():
	frc_msg = frc.Message()
	if platform.system() != 'Linux':
		print('Get clowned on fool')
		return
		
	with can.Bus(interface='socketcan', channel='can1') as bus:
		# Create a listener
		buffered_reader = can.BufferedReader()
		# Add the listener to a new notifier looking at the bus
		can.Notifier(bus, [buffered_reader]) 
		
		# Example of how to send a CAN message
		#bus.send(can.Message(arbitration_id=0x00000001, is_extended_id=True, data=[0x00,0x11,0x22,0x33]))
		with open('test.csv','w',encoding='UTF8') as f:
			writer = csv.writer(f)

			# Read in messages with a 2 second looping timeout
			while True:
				can_msg = buffered_reader.get_message(2.0);
				if can_msg == None:
					print('no message rxed')
				else:
					frc_msg = frc.Message()
					frc_msg.can_msg = can_msg
					print(frc_msg)
					writer.writerow(frc_msg.csv_row())
		

if __name__ == '__main__':
	main()
