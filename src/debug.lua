local _, Silk = ...

-- Functions for debugging purposes

function Silk_GUID()
    Silk_Message(tonumber("0x"..UnitGUID("target"):sub(7,10)))
end

function Silk_NBR()
    Silk_Message("Number of records: "..#Silk.Records)
end
