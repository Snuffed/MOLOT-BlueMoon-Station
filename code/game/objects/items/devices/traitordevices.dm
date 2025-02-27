/*

Miscellaneous traitor devices

BATTERER

RADIOACTIVE MICROLASER

*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) 	return
	if(times_used >= max_uses)
		to_chat(user, "<span class='danger'>The mind batterer has been burnt out!</span>")
		return

	log_combat(user, null, "knocked down people in the area", src)

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		if(prob(50))

			M.DefaultCombatKnockdown(rand(200,400))
			to_chat(M, "<span class='userdanger'>You feel a tremendous, paralyzing wave flood your mind.</span>")

		else
			to_chat(M, "<span class='userdanger'>You feel a sudden, electric jolt travel through your head.</span>")

	playsound(src.loc, 'sound/misc/interference.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You trigger [src].</span>")
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"

/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/healthanalyzer/rad_laser
	var/irradiate = TRUE
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?
	var/stealth = FALSE

	var/ui_x = 320
	var/ui_y = 335

/obj/item/healthanalyzer/rad_laser/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/identification/syndicate, ID_COMPONENT_DEL_ON_IDENTIFY, ID_COMPONENT_EFFECT_NO_ACTIONS, ID_COMPONENT_IDENTIFY_WITH_DECONSTRUCTOR)

/obj/item/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	if(!stealth || !irradiate)
		return ..()
	var/knowledge = SEND_SIGNAL(src, COMSIG_IDENTIFICATION_KNOWLEDGE_CHECK, user) == ID_COMPONENT_KNOWLEDGE_FULL
	if(!irradiate)
		return
	if(!used)
		log_combat(user, M, "[knowledge? "" : "unknowingly "]irradiated", src)
		var/cooldown = get_cooldown()
		used = TRUE
		icon_state = "health1"
		addtimer(VARSET_CALLBACK(src, used, FALSE), cooldown)
		addtimer(VARSET_CALLBACK(src, icon_state, "health"), cooldown)
		if(knowledge)
			to_chat(user, "<span class='warning'>Successfully irradiated [M].</span>")
		addtimer(CALLBACK(src, .proc/radiation_aftereffect, M, intensity), (wavelength+(intensity*4))*5)
	else
		if(knowledge)
			to_chat(user, "<span class='warning'>The radioactive microlaser is still recharging.</span>")

/obj/item/healthanalyzer/rad_laser/proc/radiation_aftereffect(mob/living/M, passed_intensity)
	if(QDELETED(M) || !ishuman(M) || HAS_TRAIT(M, TRAIT_RADIMMUNE))
		return
	if(passed_intensity >= 5)
		M.apply_effect(round(passed_intensity/0.075), EFFECT_UNCONSCIOUS) //to save you some math, this is a round(intensity * (4/3)) second long knockout
	M.rad_act(passed_intensity*10)

/obj/item/healthanalyzer/rad_laser/proc/get_cooldown()
	return round(max(10, (stealth*30 + intensity*5 - wavelength/4)))

/obj/item/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/healthanalyzer/rad_laser/interact(mob/user)
	var/knowledge = SEND_SIGNAL(src, COMSIG_IDENTIFICATION_KNOWLEDGE_CHECK, user) == ID_COMPONENT_KNOWLEDGE_FULL
	if(knowledge)
		ui_interact(user)

/obj/item/healthanalyzer/rad_laser/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/healthanalyzer/rad_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RadioactiveMicrolaser")
		ui.open()

/obj/item/healthanalyzer/rad_laser/ui_data(mob/user)
	var/list/data = list()
	data["irradiate"] = irradiate
	data["stealth"] = stealth
	data["scanmode"] = scanmode
	data["intensity"] = intensity
	data["wavelength"] = wavelength
	data["on_cooldown"] = used
	data["cooldown"] = DisplayTimeText(get_cooldown())
	return data

/obj/item/healthanalyzer/rad_laser/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("irradiate")
			irradiate = !irradiate
			. = TRUE
		if("stealth")
			stealth = !stealth
			. = TRUE
		if("scanmode")
			scanmode = !scanmode
			. = TRUE
		if("radintensity")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 1
				. = TRUE
			else if(target == "max")
				target = 20
				. = TRUE
			else if(adjust)
				target = intensity + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target = round(target)
				intensity = clamp(target, 1, 20)
		if("radwavelength")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = 120
				. = TRUE
			else if(adjust)
				target = wavelength + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target = round(target)
				wavelength = clamp(target, 0, 120)

/obj/item/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")

	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = FALSE
	var/old_alpha = 0
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/shadowcloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		if(!on)
			Activate(usr)
		else
			Deactivate()
	return

/obj/item/shadowcloak/item_action_slot_check(slot, mob/user, datum/action/A)
	if(slot == ITEM_SLOT_BELT)
		return 1

/obj/item/shadowcloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	src.user = user
	START_PROCESSING(SSobj, src)
	old_alpha = user.alpha
	on = TRUE

/obj/item/shadowcloak/proc/Deactivate()
	to_chat(user, "<span class='notice'>You deactivate [src].</span>")
	STOP_PROCESSING(SSobj, src)
	if(user)
		user.alpha = old_alpha
	on = FALSE
	user = null

/obj/item/shadowcloak/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()

/obj/item/shadowcloak/process()
	if(user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()
		return
	var/turf/T = get_turf(src)
	if(on)
		var/lumcount = T.get_lumcount()
		if(lumcount > 0.3)
			charge = max(0,charge - 25)//Quick decrease in light
		else
			charge = min(max_charge,charge + 50) //Charge in the dark
		animate(user,alpha = clamp(255 - charge,0,255),time = 10)


/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	var/active = FALSE
	var/range = 12

/obj/item/jammer/attack_self(mob/user)
	to_chat(user,"<span class='notice'>You [active ? "deactivate" : "activate"] [src].</span>")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	update_icon()

/*portable turret*/
/obj/item/storage/toolbox/emergency/turret
	desc = "You feel a strange urge to hit this with a wrench."

/obj/item/storage/toolbox/emergency/turret/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/emergency/turret/attackby(obj/item/I, mob/living/user, params)
    if(I.tool_behaviour == TOOL_WRENCH && user.a_intent == INTENT_HARM)
        user.visible_message("<span class='danger'>[user] bashes [src] with [I]!</span>", \
            "<span class='danger'>You bash [src] with [I]!</span>", null, COMBAT_MESSAGE_RANGE)
        playsound(src, "sound/items/drill_use.ogg", 80, TRUE, -1)
        var/obj/machinery/porta_turret/syndicate/pod/toolbox/turret = new(get_turf(loc))
        turret.faction = list("[REF(user)]")
        qdel(src)
        return

    ..()

/obj/item/headsetupgrader
	name = "headset upgrader"
	desc = "A tool that can be used to upgrade a normal headset to be able to protect from flashbangs."
	icon = 'icons/obj/device.dmi'
	icon_state = "headset_upgrade"

/obj/item/teleporter
	name = "Syndicate teleporter"
	desc = "A strange syndicate version of a cult veil shifter. Warranty voided if exposed to EMP."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-tele"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	flags_1 = CONDUCT_1
	item_state = "electronic"
	var/tp_range = 8
	var/inner_tp_range = 3
	var/charges = 4
	var/max_charges = 4
	var/saving_throw_distance = 3
	var/flawless = FALSE

/obj/item/teleporter/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/teleporter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/teleporter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has [charges] out of [max_charges] charges left.</span>"

/obj/item/teleporter/attack_self(mob/user)
	attempt_teleport(user, FALSE)

/obj/item/teleporter/process()
	if(prob(10) && charges < max_charges)
		charges++

/obj/item/teleporter/emp_act(severity)
	if(prob(50 / severity))
		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='danger'>The [src] buzzes and activates!</span>")
			attempt_teleport(user, TRUE)
		else
			visible_message("<span class='warning'> The [src] activates and blinks out of existence!</span>")
			do_sparks(2, 1, src)
			qdel(src)

/obj/item/teleporter/proc/attempt_teleport(mob/user, EMP_D = FALSE)
	dir_correction(user)
	if(!charges)
		to_chat(user, "<span class='warning'>The [src] is recharging still.</span>")
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = new/list()
	var/found_turf = FALSE
	var/list/bagholding = typecacheof(/obj/item/storage/backpack/holding)
	for(var/turf/T in range(user, tp_range))
		if(!(length(bagholding) && !flawless)) //Chaos if you have a bag of holding
			if(get_dir(C, T) != C.dir)
				continue
		if(T in range(user, inner_tp_range))
			continue
		if(T.x > world.maxx-tp_range || T.x < tp_range)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-tp_range || T.y < tp_range)
			continue

		turfs += T
		found_turf = TRUE

	if(found_turf)
		if(user.loc != mobloc) // No locker / mech / sleeper teleporting, that breaks stuff
			to_chat(C, "<span class='danger'>The [src] will not work here!</span>")
		charges--
		var/turf/destination = pick(turfs)
		if(tile_check(destination) || flawless) // Why is there so many bloody floor types
			var/turf/fragging_location = destination
			telefrag(fragging_location, user)
			C.forceMove(destination)
			playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
			playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		else if (EMP_D == FALSE && !(bagholding.len && !flawless)) // This is where the fun begins
			var/direction = get_dir(user, destination)
			panic_teleport(user, destination, direction)
		else // Emp activated? Bag of holding? No saving throw for you
			get_fragged(user, destination)
	else
		to_chat(C, "<span class='danger'>The [src] will not work here!</span>")

/obj/item/teleporter/proc/tile_check(turf/T)
	if(istype(T, /turf/open/space) || istype(T, /turf/open/space/basic) || istype(T, /turf/open/floor/holofloor))
		return TRUE

/obj/item/teleporter/proc/dir_correction(mob/user) //Direction movement, screws with teleport distance and saving throw, and thus must be removed first
	var/temp_direction = user.dir
	switch(temp_direction)
		if(NORTHEAST, SOUTHEAST)
			user.dir = EAST
		if(NORTHWEST, SOUTHWEST)
			user.dir = WEST

/obj/item/teleporter/proc/panic_teleport(mob/user, turf/destination, direction = NORTH)
	var/saving_throw
	switch(direction)
		if(NORTH, SOUTH)
			if(prob(50))
				saving_throw = EAST
			else
				saving_throw = WEST
		if(EAST, WEST)
			if(prob(50))
				saving_throw = NORTH
			else
				saving_throw = SOUTH
		else
			saving_throw = NORTH // just in case

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = list()
	var/found_turf = FALSE
	for(var/turf/T in range(destination, saving_throw_distance))
		if(get_dir(destination, T) != saving_throw)
			continue
		if(T.x > world.maxx-saving_throw_distance || T.x < saving_throw_distance)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-saving_throw_distance || T.y < saving_throw_distance)
			continue
		if(!tile_check(T))
			continue // We are only looking for safe tiles on the saving throw, since we are nice
		turfs += T
		found_turf = TRUE

	if(found_turf)
		var/turf/new_destination = pick(turfs)
		var/turf/fragging_location = new_destination
		telefrag(fragging_location, user)
		C.forceMove(new_destination)
		playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(new_destination)
		playsound(new_destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else //We tried to save. We failed. Death time.
		get_fragged(user, destination)


/obj/item/teleporter/proc/get_fragged(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	user.forceMove(destination)
	playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE)
	destination.ex_act(rand(1,2))
	for(var/obj/item/W in user)
		if(istype(W, /obj/item/organ)|| istype(W, /obj/item/implant))
			continue
		if(!user.dropItemToGround(W))
			qdel(W)
	to_chat(user, "<span class='biggerdanger'>You teleport into the wall, the teleporter tries to save you, but--</span>")
	user.gib()

/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/M in fragging_location)//Hit everything in the turf
		M.apply_damage(20, BRUTE)
		M.Knockdown(6 SECONDS)
		to_chat(M, "<span_class='warning'>[user] телепортируется в вас, откидывая блюспейс-потоком!</span>")

/obj/item/paper/teleporter
	name = "Teleporter Guide"
	default_raw_text = {"<b>Инструкции по работе с новым прототипом телепорта Синдиката</b><br>
	<br>
	Этот телепортатор перемещает пользователя на 4-8 метров в том направлении, куда он смотрит. В отличии от подобного Искажателя Реальности Кровавых Культистов, вы не можете тащить за собой людей.<br>
	<br>
	У него 4 заряда и он будет перезаряжаться с течением времени. Нет, если засунуть телепортатор в теслу, БТР, микроволновку или наэлектризованную дверь, он не будет заряжаться быстрее.<br>
	<br>
	<b>ВНИМАНИЕ:</b> Телепортация в стены активирует безотказную телепортацию параллельно на расстояние до 3 метров, однако в редком случае пользователь будет разорван на части и впечатан в стену.<br>
	<br>
	Не подвергайте телепортатор воздействию электромагнитных импульсов и не пытайтесь использовать его с Блюспейс-Сумками, возможны нежелательные сбои в работе.
"}
/obj/item/storage/box/syndie_kit/teleporter
	name = "Syndicate Teleporter Kit"

/obj/item/storage/box/syndie_kit/teleporter/PopulateContents()
	new /obj/item/teleporter(src)
	new /obj/item/paper/teleporter(src)

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5

/obj/item/teleporter/admin
	desc = "A strange syndicate version of a cult veil shifter. \n This one seems EMP proof, and with much better saftey protocols."
	charges = 8
	max_charges = 8
	flawless = TRUE
