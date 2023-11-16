local _, Silk = ...

Silk.Constants = {
    nbstunicons = 3,   -- suppose 3 stuns maximum, i.e. no D.R. reset

    buttonSize = 16,
    titleHeight = 11,
    titleBarInset = 2,

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
        [47481] = true,  -- Death Knight - Gnaw (Ghoul stun)

        [5211] = true,   -- Druid - Bash (Bear stun) - rank 1
        [6798] = true,   -- Druid - Bash (Bear stun) - rank 2
        [8983] = true,   -- Druid - Bash (Bear stun) - rank 3
        [9005] = true,   -- Druid - Pounce (Cat stun, stealth) - rank 1
        [9823] = true,   -- Druid - Pounce (Cat stun, stealth) - rank 2
        [9827] = true,   -- Druid - Pounce (Cat stun, stealth) - rank 3
        [27006] = true,  -- Druid - Pounce (Cat stun, stealth) - rank 4
        [49803] = true,  -- Druid - Pounce (Cat stun, stealth) - rank 5
        [22570] = true,  -- Druid - Maim (Cat stun) - rank 1
        [49802] = true,  -- Druid - Maim (Cat stun) - rank 2

        [19577] = true,  -- Hunter - Intimidation (generic pet stun, BM)
        [50519] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 1
        [53564] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 2
        [53565] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 3
        [53566] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 4
        [53567] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 5
        [53568] = true,  -- Hunter - Sonic Blast (Bat stun) - rank 6
        [56626] = true,  -- Hunter - Sting (Wasp stun) - rank 1
        [56627] = true,  -- Hunter - Sting (Wasp stun) - rank 2
        [56628] = true,  -- Hunter - Sting (Wasp stun) - rank 3
        [56629] = true,  -- Hunter - Sting (Wasp stun) - rank 4
        [56630] = true,  -- Hunter - Sting (Wasp stun) - rank 5
        [56631] = true,  -- Hunter - Sting (Wasp stun) - rank 6

        [44572] = true,  -- Mage - Deep Freeze
        [12355] = true,  -- Mage - Impact

        [853] = true,    -- Paladin - Hammer of Justice - rank 1
        [5588] = true,   -- Paladin - Hammer of Justice - rank 2
        [5589] = true,   -- Paladin - Hammer of Justice - rank 3
        [10308] = true,  -- Paladin - Hammer of Justice - rank 4
        [2812] = true,   -- Paladin - Holy Wrath - rank 1
        [10318] = true,  -- Paladin - Holy Wrath - rank 2
        [27139] = true,  -- Paladin - Holy Wrath - rank 3
        [48816] = true,  -- Paladin - Holy Wrath - rank 4
        [48817] = true,  -- Paladin - Holy Wrath - rank 5

        [1833] = true,   -- Rogue - Cheap Shot (stealth)
        [408] = true,    -- Rogue - Kidney Shot - rank 1
        [8643] = true,   -- Rogue - Kidney Shot - rank 2

        [58861] = true,  -- Shaman - Bash (Wolf stun)

        [30283] = true,  -- Warlock - Shadow fury - rank 1
        [30413] = true,  -- Warlock - Shadow fury - rank 2
        [30414] = true,  -- Warlock - Shadow fury - rank 3
        [47846] = true,  -- Warlock - Shadow fury - rank 4
        [47847] = true,  -- Warlock - Shadow fury - rank 5

        [100] = true,    -- Warrior - Charge - rank 1
        [6178] = true,   -- Warrior - Charge - rank 2
        [11578] = true,  -- Warrior - Charge - rank 3
        [12809] = true,  -- Warrior - Concussion Blow
        [107570] = true, -- Warrior - Storm Bolt
        [46968] = true,  -- Warrior - Shockwave

        [20549] = true,  -- Tauren - War Stomp

        -- Former list, from pre-Classic expansions
        -- [100] = true,    -- warrior - Charge
        -- [107570] = true, -- warrior - Storm Bolt
        -- [46968] = true,  -- warrior - Shockwave

        -- [5211] = true,   -- druid - Bash (Bear stun)
        -- [9005] = true,   -- druid - Pounce (Cat stun) (stealth)
        -- [22570] = true,  -- druid - Maim (Cat stun)

        -- [853] = true,    -- paladin - Hammer of Justice
        -- [2812] = true,   -- paladin - Holy Wrath
        -- [105593] = true, -- paladin - Fist of Justice

        -- [408] = true,    -- rogue - Kidney Shot
        -- [1833] = true,   -- rogue - Cheap Shot (stealth)

        -- [19577] = true,  -- hunter - Beast Mastery (pet stun)
        -- [50519] = true,  -- hunter - Sonic Blast (Bat stun)
        -- [56626] = true,  -- hunter - Sting (Wasp stun)

        -- [44572] = true,  -- mage - Deep Freeze
        -- [11129] = true,  -- mage - Combustion

        -- [30283] = true,  -- warlock - Shadow fury
        -- [89766] = true,  -- warlock - Axe Toss (Felguard stun)

        -- [58861] = true,  -- shaman - Wolf stun

        -- [47481] = true,  -- death knight - Gnaw (Ghoul stun)

        -- [113656] = true, -- monk - Fists of Fury
        -- [122057] = true, -- monk - Clash
        -- [119392] = true, -- monk - Charging Ox Wave
        -- [119381] = true, -- monk - Leg Sweep

        -- [20549] = true,  -- Tauren - War Stomp
    },
}
