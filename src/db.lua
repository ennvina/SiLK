local _, Silk = ...

function Silk:LoadDB()
    local currentversion = 100
    local db = SilkDB
    if not db or not db.version or (db.version < 040) then
        db = {}

        -- activation
        db.enabled = true

        -- frame geometry
        db.dimensions = {}
        db.scales = {}
        db.positions = {}
        db.visible = {}
        db.version = 040
    end

--  check version here, and import older db if possible
    if (db.version < 042) then
        db.stun = {}
        db.stun.showraid = false
        db.version = 042
    end
    if (db.version < 051) then
        db.timeout = 10
        db.version = 051
    end
    if (db.version < 060) then
        db.channel = "default"
        db.version = 060
    end
    if (db.version < 080) then
        db.records = {}
    end

    -- ultimate checks for corrupted addons
    if not db.enabled then
        db.enabled = true
    end
    if not db.dimensions then
        db.dimensions = {}
    end
    if not db.scales then
        db.scales = {}
    end
    if not db.positions then
        db.positions = {}
    end
    if not db.visible then
        db.visible = {}
    end
    if not db.stun then
        db.stun = {}
    end
    if not db.stun.showraid then
        db.stun.showraid = false
    end
    if not db.timeout then
        db.timeout = 10
    end
    if not db.channel then
        db.channel = "default"
    end
    if not db.records then
        db.records = {}
    end

    db.version = currentversion
    SilkDB = db
    self.db = db
end
