frc_can_protocol = Proto("frc_can",  "FRC CAN Protocol")

--       |Device Type|Manufacturer|API Class|API Index|Device ID|
--  Bits  28       24 23        16 15     10 9       6 5       0
-- 
--  Device Type  (5 bits) - Type of CAN device (Motor, Relay, PDP, Pneumatics, etc...)
--  Manufacturer (8 bits) - Manufacturer of the CAN device (NI, Rev, CTRE, etc...)
--  API Class    (6 bits) - Varies by vendor (Ex. Jaguar: Status, Ack, Voltage Mode, Position Mode, etc...)
--  API Index    (4 bits) - Varies by vendor (Ex. Jaguar: Enable, Disable, Set Setpoint, P Const, etc...)
--  Device ID    (6 bits) - The ID of the CAN device of the particular type/manufacturer

device_type = ProtoField.uint8("frc_can.device", "Device Type", base.DEC)
device_mfr = ProtoField.uint8("frc_can.mfr", "Manufacturer", base.DEC)
api_class = ProtoField.uint8("frc_can.api_class", "API Class", base.DEC)
api_index = ProtoField.uint8("frc_can.api_index", "API Index", base.DEC)
device_id = ProtoField.uint8("frc_can.id", "Device ID", base.DEC)

frc_can_protocol.fields = {device_type,mfr,api_class,api_index,device_id}

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

function frc_can_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = frc_can_protocol.name

    local subtree = tree:add(frc_can_protocol, buffer(), "FRC CAN Protocol Data")

    subtree:add_le(message_length, buffer(0,4))
    subtree:add_le(request_id,     buffer(4,4))
    -- subtree:add_le(response_to,    buffer(8,4))

    -- local opcode_number = buffer(12,4):le_uint()
    -- local opcode_name = get_opcode_name(opcode_number)
    -- subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")
  end

local can_dissector = DissectorTable.get("can.subdissector")
can_dissector:add_for_decode_as(frc_can_protocol)