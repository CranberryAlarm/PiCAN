import can
from enum import IntEnum


# Arbitration ID (aka CAN ID) deserialization/serialization
#
# docs.wpilib.org/en/stable/docs/software/can-devices/can-addressing.html
#
# FRC sub-divides the extended (29-bit) CAN ID into 5 different fields:
# 
#      |Device Type|Manufacturer|API Class|API Index|Device ID|
# Bits  28       24 23        16 15     10 9       6 5       0
#
# Device Type  (5 bits) - Type of CAN device (Motor, Relay, PDP, Pneumatics, etc...)
# Manufacturer (8 bits) - Manufacturer of the CAN device (NI, Rev, CTRE, etc...)
# API Class    (6 bits) - Varies by vendor (Ex. Jaguar: Status, Ack, Voltage Mode, Position Mode, etc...)
# API Index    (4 bits) - Varies by vendor (Ex. Jaguar: Enable, Disable, Set Setpoint, P Const, etc...)
# Device ID    (6 bits) - The ID of the CAN device of the particular type/manufacturer
#
# Example:
#
# CAN Message comes in with CAN ID 0x0804B543
#
# 0x0804B543
# 0b00001000000001001011010101000011
#
#  |000|01000|00000100|101101|0101|000011|
#    ^     ^      ^      ^      ^       ^
#    |     |      |      |      |       |
# Unused   |     CTRE    |    Index5    |
#    PWR_DIST_MODULE   Class45         ID3
#
# This CAN ID means that the 4th CrossTheRoadElectronics Power 
# Distribution Panel on the CAN bus sent a message with an API class of
# 45 and an API Index of 5.
#
# Obviously this isn't a realistic example, but this is the process


# Consts
DEVICE_TYPE_MASK  = 0x1F000000
MANUFACTURER_MASK = 0x00FF0000
API_CLASS_MASK    = 0x0000FC00
API_INDEX_MASK    = 0x000003C0
DEVICE_ID_MASK    = 0x0000003F

DEVICE_TYPE_SHIFT  = 24
MANUFACTURER_SHIFT = 16
API_CLASS_SHIFT    = 10
API_INDEX_SHIFT    = 6
DEVICE_ID_SHIFT    = 0


# Enums

class DeviceType(IntEnum):
	BROADCAST = 0
	ROBOT_CTRL = 1
	MOTOR_CTRL = 2
	RELAY_CTRL = 3
	GYRO = 4
	ACCELEROMETER = 5
	ULTRASONIC = 6
	GEAR_TOOTH = 7
	PWR_DIST_MODULE = 8
	PNEUMATICS_CTRL = 9
	MISC = 10
	IO_BREAKOUT = 11
	FW_UPDATE = 31
	RESERVED = 12
	default = RESERVED
	
	@classmethod
	def _missing_(cls, value):
		return cls.default
	
class Manufacturer(IntEnum):
	BROADCAST = 0
	NI = 1
	LUMINARY_MICRO = 2
	DEKA = 3
	CTRE = 4
	REV = 5
	GRAPPLE = 6
	MINDSENSORS = 7
	TEAM_USE = 8
	KAUAI_LABS = 9
	COPPERFORGE = 10
	PLAYING_WITH_FUSION = 11
	STUDICA = 12
	THRIFTY_BOT = 13
	REDUX_ROBOTICS = 14
	RESERVED = 15
	default = RESERVED
	
	@classmethod
	def _missing_(cls, value):
		return cls.default

class BroadcastApiIndex(IntEnum):
	DISABLE = 0
	SYSTEM_HALT = 1
	SYSTEM_RESET = 2
	DEVICE_ASSIGN = 3
	DEVICE_QUERY = 4
	HEARTBEAT = 5
	SYNC = 6
	UPDATE = 7
	FW_VER = 8
	ENUMERATE = 9
	SYSTEM_RESUME = 10
	RESERVED = 11
	default = RESERVED
		
	@classmethod
	def _missing_(cls, value):
		return cls.default

# Message class

class Message():
	def __init__(self, device_type=DeviceType.BROADCAST, manufacturer=Manufacturer.BROADCAST, api_class=0, api_index=0, device_id=0, data=None):
		# Protected
		self._can_msg = can.Message(is_extended_id=True, is_fd=False, is_remote_frame=False, is_error_frame=False)
		
		# Public
		self.device_type = device_type
		self.manufacturer = manufacturer
		self.api_class = api_class
		self.api_index = api_index
		self.device_id = device_id
		self.data = data

	@property
	def can_msg(self):
		self.serialize()
		return self._can_msg
		
	@can_msg.setter
	def can_msg(self, new_can_msg):
		self._can_msg = new_can_msg
		self.deserialize()
		
	def serialize(self):
		can_id  = 0
		can_id |= (self.device_type  << DEVICE_TYPE_SHIFT)  & DEVICE_TYPE_MASK
		can_id |= (self.manufacturer << MANUFACTURER_SHIFT) & MANUFACTURER_MASK 
		can_id |= (self.api_class    << API_CLASS_SHIFT)    & API_CLASS_MASK    
		can_id |= (self.api_index    << API_INDEX_SHIFT)    & API_INDEX_MASK    
		can_id |= (self.device_id    << DEVICE_ID_SHIFT)    & DEVICE_ID_MASK    
		self._can_msg.arbitration_id = can_id
		
		self._can_msg.data = self.data
		
	def deserialize(self):
		can_id = self._can_msg.arbitration_id
		self.device_type  = DeviceType(  (can_id & DEVICE_TYPE_MASK)  >> DEVICE_TYPE_SHIFT)
		self.manufacturer = Manufacturer((can_id & MANUFACTURER_MASK) >> MANUFACTURER_SHIFT)
		self.api_class = (can_id & API_CLASS_MASK) >> API_CLASS_SHIFT
		self.api_index = (can_id & API_INDEX_MASK) >> API_INDEX_SHIFT
		self.device_id = (can_id & DEVICE_ID_MASK) >> DEVICE_ID_SHIFT
		
		self.data = self._can_msg.data
		
	def is_broadcast(self):
		return self.device_type == DeviceType.BROADCAST or self.manufacturer == Manufacturer.BROADCAST
		
	def is_valid(self):
		if self.device_type == DeviceType.RESERVED:
			return False
		if self.manufacturer == Manufacturer.RESERVED:
			return False
		if self.is_broadcast():
			if self.device_type != DeviceType.BROADCAST:
				return False
			elif self.manufacturer != Manufacturer.BROADCAST:
				return False
			elif self.api_class != 0:
				return False
			elif BroadcastApiIndex(self.api_index) == BroadcastApiIndex.RESERVED:
				return False
				
		return True
		
	def csv_row(self):
		row = []
		row.append(self._can_msg.timestamp)
		row.append(hex(self._can_msg.arbitration_id))
		row.append(self.device_type.name)
		row.append(self.manufacturer.name)
		row.append(self.api_class)
		row.append(self.api_index)
		row.append(self.device_id)
		row.append(''.join('{:02X}'.format(x) for x in self.data))
		return row
		

	def __str__(self):
		#if not self.is_valid():
		#	return f"FRC Message INVALID"
		#if self.is_broadcast():
		#	return f"FRC Message: {self.device_type.name} [ID {self.device_id}] ApiIndex:{BroadcastApiIndex(self.api_index).name}  Data:0x{''.join('{:02X}'.format(x) for x in self.data)}"
		#else:
		return f"FRC Message: {self.manufacturer.name}-{self.device_type.name} [ID {self.device_id}] ApiClass:{self.api_class} ApiIndex:{self.api_index} Data:0x{''.join('{:02X}'.format(x) for x in self.data)}"
