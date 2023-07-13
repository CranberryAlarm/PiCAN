frc_can_protocol = Proto("frc_can",  "FRC CAN Protocol")

--       |Device Type|Manufacturer|API Class|API Index|Device ID|
--  Bits  28       24 23        16 15     10 9       6 5       0
-- 
--  Device Type  (5 bits) - Type of CAN device (Motor, Relay, PDP, Pneumatics, etc...)
--  Manufacturer (8 bits) - Manufacturer of the CAN device (NI, Rev, CTRE, etc...)
--  API Class    (6 bits) - Varies by vendor (Ex. Jaguar: Status, Ack, Voltage Mode, Position Mode, etc...)
--  API Index    (4 bits) - Varies by vendor (Ex. Jaguar: Enable, Disable, Set Setpoint, P Const, etc...)
--  Device ID    (6 bits) - The ID of the CAN device of the particular type/manufacturer

local device_types = {
    [0] = "BROADCAST",
    [1] = "ROBOT_CTRL",
    [2] = "MOTOR_CTRL",
    [3] = "RELAY_CTRL",
    [4] = "GYRO",
    [5] = "ACCELEROMETER",
    [6] = "ULTRASONIC",
    [7] = "GEAR_TOOTH",
    [8] = "PWR_DIST_MODULE",
    [9] = "PNEUMATICS_CTRL",
    [10] = "MISC",
    [11] = "IO_BREAKOUT",
    [31] = "FW_UPDATE",
    [12] = "RESERVED"
}

local mfr_types = {
    [0] = "BROADCAST",
    [1] = "NI",
    [2] = "LUMINARY_MICRO",
    [3] = "DEKA",
    [4] = "CTRE",
    [5] = "REV",
    [6] = "GRAPPLE",
    [7] = "MINDSENSORS",
    [8] = "TEAM_USE",
    [9] = "KAUAI_LABS",
    [10] = "COPPERFORGE",
    [11] = "PLAYING_WITH_FUSION",
    [12] = "STUDICA",
    [13] = "THRIFTY_BOT",
    [14] = "REDUX_ROBOTICS",
    [15] = "RESERVED"
}

local broadcast_api_indexes = {
  [0] = "Disable",
  [1] = "System Halt",
  [2] = "System Reset",
  [3] = "Device Assign",
  [4] = "Device Query",
  [5] = "Heartbeat",
  [6] = "Sync",
  [7] = "Update",
  [8] = "Firmware Version",
  [9] = "Enumerate",
  [10] = "System Resume"
}

device_type = ProtoField.uint32("frc_can.device",    "Device Type",  base.DEC, device_types, 0x1F000000)
device_mfr  = ProtoField.uint32("frc_can.mfr",       "Manufacturer", base.DEC, mfr_types,    0x00FF0000)
api_class   = ProtoField.uint32("frc_can.api_class", "API Class",    base.DEC, NULL,         0x0000FC00)
api_index   = ProtoField.uint32("frc_can.api_index", "API Index",    base.DEC, NULL,         0x000003C0)
device_id   = ProtoField.uint32("frc_can.id",        "Device ID",    base.DEC, NULL,         0x0000003F)



frc_can_protocol.fields = {device_type, device_mfr, api_class, api_index, device_id}

function get_device_type_str(device_type)
    local device_type_str = "RESERVED"

        if device_type == 0  then device_type_str = "BROADCAST"
    elseif device_type == 1  then device_type_str = "ROBOT_CTRL"
    elseif device_type == 2  then device_type_str = "MOTOR_CTRL"
    elseif device_type == 3  then device_type_str = "RELAY_CTRL"
    elseif device_type == 4  then device_type_str = "GYRO"
    elseif device_type == 5  then device_type_str = "ACCELEROMETER"
    elseif device_type == 6  then device_type_str = "ULTRASONIC"
    elseif device_type == 7  then device_type_str = "GEAR_TOOTH"
    elseif device_type == 8  then device_type_str = "PWR_DIST_MODULE"
    elseif device_type == 9  then device_type_str = "PNEUMATICS_CTRL"
    elseif device_type == 10 then device_type_str = "MISC"
    elseif device_type == 11 then device_type_str = "IO_BREAKOUT"
    elseif device_type == 31 then device_type_str = "FW_UPDATE" end

    return device_type_str
end

function get_manufacturer_str(mfr)
    local mfr_str = "RESERVED"

        if mfr == 0  then mfr_str = "BROADCAST"
    elseif mfr == 1  then mfr_str = "NI"
    elseif mfr == 2  then mfr_str = "LUMINARY_MICRO"
    elseif mfr == 3  then mfr_str = "DEKA"
    elseif mfr == 4  then mfr_str = "CTRE"
    elseif mfr == 5  then mfr_str = "REV"
    elseif mfr == 6  then mfr_str = "GRAPPLE"
    elseif mfr == 7  then mfr_str = "MINDSENSORS"
    elseif mfr == 8  then mfr_str = "TEAM_USE"
    elseif mfr == 9  then mfr_str = "KAUAI_LABS"
    elseif mfr == 10 then mfr_str = "COPPERFORGE"
    elseif mfr == 11 then mfr_str = "PLAYING_WITH_FUSION"
    elseif mfr == 12 then mfr_str = "STUDICA"
    elseif mfr == 13 then mfr_str = "THRIFTY_BOT"
    elseif mfr == 14 then mfr_str = "REDUX_ROBOTICS" end

    return mfr_str
end

local can_id_field = Field.new("can.id")

function frc_can_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = frc_can_protocol.name

    local subtree = tree:add(frc_can_protocol, buffer(), "FRC CAN Protocol Data")

    local can_id = can_id_field()
    
    subtree:add(device_type, can_id.value)
    subtree:add(device_mfr, can_id.value)
    subtree:add(api_class, can_id.value)
    subtree:add(api_index, can_id.value)
    subtree:add(device_id, can_id.value)
    -- subtree:add_le(message_length, buffer(0,4))
    -- subtree:add_le(request_id,     buffer(4,4))
    -- subtree:add_le(response_to,    buffer(8,4))

    -- local opcode_number = buffer(12,4):le_uint()
    -- local opcode_name = get_opcode_name(opcode_number)
    -- subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")
  end

local can_dissector = DissectorTable.get("can.subdissector")
can_dissector:add_for_decode_as(frc_can_protocol)
