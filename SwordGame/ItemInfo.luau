local ItemInfo = {} -- DO NOT CHANGE ALREADY MADE ITEMS'S VALUE OR RARITY AFTER RELEASE

ItemInfo.SwordInfo = {}
ItemInfo.AugmentInfo = {}

ItemInfo.SwordInfo[1] = {
	SwordName = "Stick", -- Name Of The Sword
	SwordStyle = "LongBlade", -- Affects CoolDown and Swing Length
	ExperiencePerLevel = { -- the amount of TOTAL xp required to obtain a certian level
		[1] = 100,
		[2] = 120,
		[3] = 140,
		[4] = 160,
		[5] = 180,
		[6] = 200,
		[7] = 220,
		[8] = 240,
		[9] = 260,
		[10] = 300
	},
	DamageValues = { -- Damage Array Per Level
		[1] = 10,
		[2] = 12,
		[3] = 14,
		[4] = 16,
		[5] = 18,
		[6] = 20,
		[7] = 22,
		[8] = 24,
		[9] = 26,
		[10] = 30
	},
	Value = 0, -- Value for Trading
	Rarity = 0 -- 0 Means Starter Rarity
}

ItemInfo.AugmentInfo[1] = {
	AugmentName = "AttackSpeed",
	ExperiencePerLevel = { -- the amount of TOTAL xp required to obtain a certian level
		[1] = 100,
		[2] = 120,
		[3] = 140,
		[4] = 160,
		[5] = 180,
		[6] = 200,
		[7] = 220,
		[8] = 240,
		[9] = 260,
		[10] = 300
	},
	AugmentEffectPerLevel = {
		[1] = 1.1,
		[2] = 1.2,
		[3] = 1.3,
		[4] = 1.4,
		[5] = 1.5,
		[6] = 1.6,
		[7] = 1.7,
		[8] = 1.8,
		[9] = 1.9,
		[10] = 2.4,
	},
	AugmentEffectMultiplierPerRarity = {
		[1] = 1,
		[2] = 1.5,
		[3] = 2,
		[4] = 3,
		[5] = 4.2,
		[6] = 8,
	}
}

return ItemInfo
