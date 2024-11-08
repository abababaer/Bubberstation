#define NO_ANIMAL 0
#define ANIMAL_ALIVE 1
#define ANIMAL_DEAD 2

#define MEOW_NORMAL 'sound/creatures/cat/cat_meow1.ogg'
#define MEOW_SAD 'modular_zubbers/code/modules/nyamagotchi/sound/cat_sad.ogg'
#define MEOW_CRITICAL 'modular_zubbers/code/modules/nyamagotchi/sound/cat_alert.ogg'
#define EAT_FOOD 'modular_zubbers/code/modules/nyamagotchi/sound/cat_eat.ogg'
#define PURR_PLAY 'sound/creatures/cat/cat_purr1.ogg'
#define PURR_SLEEP 'sound/creatures/cat/cat_purr3.ogg'

/obj/item/toy/nyamagotchi
	name = "nyamagotchi"
	icon = 'modular_zubbers/code/modules/nyamagotchi/sprites/nyamagotchi.dmi'
	desc = "A small electronic 'pet' that requires care and attention. An ancient relic sure to evoke nostalgic feelings."
	icon_state = "default"
	base_icon_state = "default"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throwforce = 2
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	inhand_icon_state = "electronic"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT, /datum/material/plastic = SMALL_MATERIAL_AMOUNT)
	// interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION | INTERACT_ATOM_IGNORE_MOBILITY
	var/list/icons_available = list()
	var/radial_icon_file = 'modular_zubbers/code/modules/nyamagotchi/sprites/radial_nyamagotchi.dmi'

	/// Hunger level (0 = full, 100 = starving)
	var/hunger = 0
	/// Happiness level (0 = sad, 100 = very happy)
	var/happiness = 100
	/// Energy level (0 = tired, 100 = full of energy)
	var/energy = 0
	/// Age in "days" or some unit of time
	var/age = 0
	/// How often a 'life' cycle of the pet runs
	var/update_rate = 15 SECONDS

	var/alive = NO_ANIMAL
	var/static/list/rest_messages = list(
		"Zzz... Zzz... Zzz...",
		"Honk, shew! Hooonk, shewww...!",
		"Snoozin' time, nya...",
		"Honk shoo!",
		"I'm feeling so energized!",
		"I'm feeling so well-rested!",
		"Zzz... Zzz... Zzz... Zzz... Zzz...",
	)
	var/static/list/play_messages = list(
		"Wowzers meowzers, that was fun!",
		"That was so much fun, nya!",
		"YAY!!!",
		"I had a great time playing with you!",
		"YIPPEEE!!!", "That was a blast!",
		"Wowzers meowzers, that was a blast!",
	)
	var/static/list/feed_messages = list(
		"NOM NOM NOM. Ice cream, yum!",
		"Mmm, that was tasty!",
		"So yummy!",
		"Oooh! Delicious!",
		"MONCH MONCH MONCH.",
		"MUNCH MUNCH, that was so heckin' tasty, nya!",
		"Yum, that was delicious!",
		"What a PURRFECT meal, nya!",
	)
	var/static/list/hunger_warning = list(
		"Wowzers meowzers, I'm hungry, nya!",
		"Excuse me! I'm feeling a bit peckish, nya!",
		"I could eat the world right now, nya!",
		"Soooo hongry!",
		"I'm feeling a bit hungry, nya!",
		"I needs the food, mrow!",
	)
	var/static/list/hunger_critical = list(
		"HELLO! Food, pwease?...",
		"HEY!!! I'm starving...",
		"HONNNNGRYYY!!!",
		"so so hungry...",
	)
	var/static/list/happiness_warning = list(
		"Some fun would be purrfect, nya...",
		"I'm feeling a bit down, nya...",
		"Playtime! Now!",
		"This is no fun...",
		"I'm BORED, nya!",
		"So sad! So bored! Need to play!",
		"Wah... So sad, nya...",
		"I'm feeling a bit blue, nya...",
		"I'm sad...",
		"Play with meeee! PLEASE.",
		"My fun levels are low, nya...",
	)
	var/static/list/energy_warning = list(
		"I'm feeling a bit sleepy, nya...",
		"Sleempy...",
		"I be needin' a naps, nya!",
		"Need to do the big sleeps, please!",
		"I'm feeling a bit exhausted, nya...",
		"I could go for a nap...",
	)
	var/static/list/energy_critical = list(
		"SO, SO EEPY, NYA...",
		"Please, I need to rest...",
		"I'm gonna pass out and DIE!",
		"EEPY. EEPY. eepy...",
	)
	COOLDOWN_DECLARE(mute_pet)

/obj/item/toy/nyamagotchi/Initialize(mapload)
	. = ..()
	update_available_icons()

/obj/item/toy/nyamagotchi/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += "[readout()]"
		if(!COOLDOWN_FINISHED(src, mute_pet))
			. += span_notice("<b>Alt-click</b> to disable mute feature.")
		else
			. += span_notice("<b>Alt-click</b> to temporarily mute notifications.")

/obj/item/toy/nyamagotchi/proc/readout()
	switch(alive)
		if(NO_ANIMAL)
			return span_notice("The Nyamagotchi is ready to be started!")
		if(ANIMAL_ALIVE)
			return span_notice("The Nyamagotchi is alive, its reached age [age]! Use the 'Check Status button to see its stats!")
		if(ANIMAL_DEAD)
			return span_purple("The Nyamagotchi is DEAD. You're a terrible person.")

/obj/item/toy/nyamagotchi/proc/update_available_icons()
	icons_available = list()
	if(alive == ANIMAL_ALIVE)
		icons_available += list(
			"Feed" = image(radial_icon_file, "feed"),
			"Play" = image(radial_icon_file, "play"),
			"Rest" = image(radial_icon_file, "rest"),
			"Check Status" = image(radial_icon_file, "status",
		))
	else
		icons_available += list("Start!" = image(radial_icon_file, "start"))

/obj/item/toy/nyamagotchi/attack_self(mob/user)
	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Start!")
				start()
			if("Feed")
				feed()
			if("Play")
				play()
			if("Rest")
				rest()
			if("Check Status")
				check_status()

/obj/item/toy/nyamagotchi/click_alt(mob/living/user)
	if(user != loc)
		return

	if(COOLDOWN_FINISHED(src, mute_pet))
		COOLDOWN_START(src, mute_pet, 3 MINUTES)
		user.balloon_alert(user, "muted!")

	else
		COOLDOWN_RESET(src, mute_pet)
		user.balloon_alert(user, "unmuted!")

/obj/item/toy/nyamagotchi/proc/start()
	alive = ANIMAL_ALIVE
	// give a slightly random start
	hunger = rand(30, 60)
	happiness = rand(80, 100)
	energy = rand(60, 90)
	be_known(sfx = 'sound/misc/bloop.ogg', speech = "I'm alive, nya!")
	addtimer(CALLBACK(src, PROC_REF(be_known), MEOW_NORMAL), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(update)), update_rate)

// status update loop
/obj/item/toy/nyamagotchi/proc/update()
	if(!alive)
		return

	if(happiness < 16) // unhappy pets get hungry and tired faster
		hunger += rand(1, 3)
		energy -= rand(1, 3)

	age += 1	// Increase age over time
	hunger += rand(1, 3)	// Increase hunger over time
	happiness -= rand(1,3)	// Decrease happiness over time
	energy -= rand(1,3)	// Decrease energy over time

	// check if the nyamagotchi is still alive
	if(hunger >= 100 || energy <= 0)
		die()
		return

	// schedule our next check
	addtimer(CALLBACK(src, PROC_REF(update)), update_rate)

	// make the nyamagotchi say things if attention is needed, otherwise just a small chance of a reminder meow
	var/list/tama_alerts = list()
	var/selected_alert
	if(hunger > 93)
		tama_alerts += "vhungry"
	if(energy < 7)
		tama_alerts += "vtired"
	if(tama_alerts.len)
		selected_alert = pick(tama_alerts)
		switch(selected_alert)
			if("vhungry")
				be_known(sfx = MEOW_CRITICAL, speech = pick(hunger_critical))
				return
			if("vtired")
				be_known(sfx = MEOW_CRITICAL, speech = pick(energy_critical))
				return

	if(hunger > 84)
		tama_alerts += "hungry"
	if(happiness < 11)
		tama_alerts += "sad"
	if(energy < 16)
		tama_alerts += "tired"
	if(tama_alerts.len)
		selected_alert = pick(tama_alerts)
		switch(selected_alert)
			if("hungry")
				be_known(sfx = MEOW_SAD, speech = pick(hunger_warning))
			if("sad")
				be_known(sfx = MEOW_SAD, speech = pick(happiness_warning))
			if("tired")
				be_known(sfx = MEOW_SAD, speech = pick(energy_warning))
	else if(prob(15))
		be_known(sfx = MEOW_NORMAL)

/obj/item/toy/nyamagotchi/proc/be_known(sfx, speech, visible)
	if(!COOLDOWN_FINISHED(src, mute_pet))
		return

	if(!isnull(sfx))
		playsound(source = src, soundin = sfx, vol = 40, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)

	if(!isnull(speech))
		say(speech, message_range = 2)

	if(!isnull(visible))
		balloon_alert_to_viewers(message = visible, vision_distance = COMBAT_MESSAGE_RANGE + 2)

// Interactions
/obj/item/toy/nyamagotchi/proc/feed()
	if(hunger > 20)
		hunger -= min(rand(30, 40), hunger)
		to_chat(usr, span_purple("You fed [src]! Its hunger is now at [hunger]."))
		be_known(sfx = EAT_FOOD, speech = pick(feed_messages))
	else
		usr.balloon_alert(usr, "not hungry!")

/obj/item/toy/nyamagotchi/proc/play()
	if(happiness < 80)
		happiness += min(rand(30, 40), 100 - happiness)
		to_chat(usr, span_purple("You play with [src]! Its happiness is now [happiness]."))
		be_known(sfx = PURR_PLAY, speech = pick(play_messages))
	else
		usr.balloon_alert(usr, "not bored!")

/obj/item/toy/nyamagotchi/proc/rest()
	if(energy < 80)
		energy += min(rand(30, 40), 100 - energy)
		to_chat(usr, span_purple("Your [src] rests and regains energy. Its energy is now [energy]."))
		be_known(sfx = PURR_SLEEP, speech = pick(rest_messages))
	else
		usr.balloon_alert(usr, "not tired!")

// Function for when the nyamagotchi dies
/obj/item/toy/nyamagotchi/proc/die()
	alive = ANIMAL_DEAD
	audible_message(span_warning("[src] makes a weak, sad noise and then goes silent... Rest in peace."), hearing_distance = COMBAT_MESSAGE_RANGE)
	if(ishuman(loc))
		to_chat(loc, span_warning("[src] shows an x3 on its display. It's dead. You're a terrible person."))
	//src.icon_state = "dead"
	be_known(sfx = 'sound/misc/sadtrombone.ogg', visible = "nyamagotchi died!")
	update_available_icons()

/obj/item/toy/nyamagotchi/proc/check_status()
	balloon_alert(usr, "hunger: [hunger] happiness: [happiness] energy: [energy]")

#undef NO_ANIMAL
#undef ANIMAL_ALIVE
#undef ANIMAL_DEAD

#undef MEOW_NORMAL
#undef MEOW_SAD
#undef MEOW_CRITICAL
#undef EAT_FOOD
#undef PURR_PLAY
#undef PURR_SLEEP
