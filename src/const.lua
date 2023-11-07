local _, Silk = ...

Silk.Constants = {
    nbstunicons = 3,   -- suppose 3 stuns maximum, i.e. no D.R. reset

    healthHeight = 20,
    healthInset = 1,

    halionHeight = 32,
    halionInset = 2,

    windowname = {
        valkyr = "Val'kyrs",
        aaa = "AAA",
        corpo = "Corporeality",
        spitecaller = "Spitecaller",
        adherent = "Corrupting Adherent",
        sk = "Spirit Kings",
    },

    stunspells = {
        100,    -- warrior - Charge
        107570, -- warrior - Storm Bolt
        46968,  -- warrior - Shockwave

        5211,   -- druid - Bash (Bear stun)
        9005,   -- druid - Pounce (Cat stun) (stealth)
        22570,  -- druid - Maim (Cat stun)

        853,    -- paladin - Hammer of Justice
        2812,   -- paladin - Holy Wrath
        105593, -- paladin - Fist of Justice

        408,    -- rogue - Kidney Shot
        1833,   -- rogue - Cheap Shot (stealth)

        19577,  -- hunter - Beast Mastery (pet stun)
        50519,  -- hunter - Sonic Blast (Bat stun)
        56626,  -- hunter - Sting (Wasp stun)

        44572,  -- mage - Deep Freeze
        11129,  -- mage - Combustion

        30283,  -- warlock - Shadow fury
        89766,  -- warlock - Axe Toss (Felguard stun)

        58861,  -- shaman - Wolf stun

        47481,  -- death knight - Gnaw (Ghoul stun)

        113656, -- monk - Fists of Fury
        122057, -- monk - Clash
        119392, -- monk - Charging Ox Wave
        119381, -- monk - Leg Sweep

        20549,  -- Tauren - War Stomp
    },
}
