# gvmv
Will you rid Yorkshire of botulism, or will you hasten its fermented demise?

## Links
[Gvmv design doc](https://docs.google.com/document/d/1J1nLxCJTjI24HxY2GwyzELv96lzCIoY0JhEIKRb66_c/edit?usp=drivesdk)

[Lvrvbvvk](https://docs.google.com/spreadsheets/d/1Q_KiFPjkbmJ8in2J6eISNbw6fuzqvNwAHTYsKeYfkIQ/edit?usp=drivesdk)

[Vvsvvn bvvrd](https://docs.google.com/presentation/d/1-gpM2aBmNoO8I_ijRu4uSzDOuXCfIwV9oML1c0HSD5E/edit?usp=drivesdk)

## TVDV
- [ ] discussion RE combat!!!!
	- [ ] should there be diff magic spells or just a "cast magick" with the magick type being set from the lantern pentangle bits??
	- [ ] how can we use items in battle?
	- [ ] how to deal with placeholders (e.g. background)
	- [ ] how do we want to manage levelling (maybe just a percentage increase in stats??)
	- [ ] how do we want to manage movesets? how do people get new moves? or maybe they don't?
	- [x] how can we implement party mechanics?
	- [ ] use of global data to persist e.g. current health, xp
	- [ ] what do we want to do about loot?
	- [ ] how do we actually want type matchups to work
	- [ ] how should the AI work?
	- [ ] what battle effects do we want other than damage/heal (buffs/debuff/poison etc)

Persistent stats notes
- PartyMember class which initialises from character_data when character joins party
- This holds various stats which are updated in memory etc
- [ ] Update combatcharacter to read/load from partymember rather than character data
- [ ] Update PartyMember to contain all relevant stats
- [ ] Add movesets to partymember?
- [ ] Load partymembers on player_data global??? (need some sort of "join party" routine)
