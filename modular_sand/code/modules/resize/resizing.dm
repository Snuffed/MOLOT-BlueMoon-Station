//handle the big steppy, except nice
/mob/living/proc/handle_micro_bump_helping(mob/living/target)
	if(ishuman(src))
		var/mob/living/carbon/human/user = src

		if(target.pulledby == user)
			return FALSE

		//Micro is on a table.
		var/turf/steppyspot = target.loc
		for(var/thing in steppyspot.contents)
			if(istype(thing, /obj/structure/table))
				return TRUE

		//Both small.
		if(get_size(user) <= RESIZE_A_TINYMICRO && get_size(target) <= RESIZE_A_TINYMICRO)
			now_pushing = 0
			user.forceMove(target.loc)
			return TRUE

		//Doing messages
		if(COMPARE_SIZES(user, target) >= 2) //if the initiator is twice the size of the micro
			now_pushing = 0
			user.forceMove(target.loc)

			//Smaller person being stepped on
			if(iscarbon(src))
				if(istype(user) && user.dna.features["taur"] == "Naga" || user.dna.features["taur"] == "Tentacle")
					target.visible_message("<span class='notice'>[src] carefully slithers around [target].</span>", "<span class='notice'>[src]'s huge tail slithers besides you.</span>")
				else
					target.visible_message("<span class='notice'>[src] carefully steps over [target].</span>", "<span class='notice'>[src] steps over you carefully.</span>")
				return TRUE

		//Smaller person stepping under a larger person
		if(COMPARE_SIZES(target, user) >= 2)
			user.forceMove(target.loc)
			now_pushing = 0
			micro_step_under(target)
			return TRUE

//Stepping on disarm intent -- TO DO, OPTIMIZE ALL OF THIS SHIT
/mob/living/proc/handle_micro_bump_other(mob/living/target)
	ASSERT(isliving(target))
	if(ishuman(src))
		var/mob/living/carbon/human/user = src

		if(target.pulledby == user)
			return FALSE

	//If on a table, don't
		var/turf/steppyspot = target.loc
		for(var/thing in steppyspot.contents)
			if(istype(thing, /obj/structure/table))
				return TRUE

	//Both small
		if(get_size(user) <= RESIZE_A_TINYMICRO && get_size(target) <= RESIZE_A_TINYMICRO)
			now_pushing = 0
			user.forceMove(target.loc)
			return TRUE

		if(COMPARE_SIZES(user, target) >= 1.6) // BLUEMOON CHANGES
			log_combat(user, target, "stepped on", addition="[user.a_intent] trample")
			if(user.a_intent == "disarm" && CHECK_MOBILITY(user, MOBILITY_MOVE) && !user.buckled)
				now_pushing = 0
				user.forceMove(target.loc)
				user.sizediffStamLoss(target)
				user.add_movespeed_modifier(/datum/movespeed_modifier/stomp, TRUE) //Full stop
				addtimer(CALLBACK(user, /mob/.proc/remove_movespeed_modifier, MOVESPEED_ID_STOMP, TRUE), 3) //0.3 seconds
				if(iscarbon(user))
					if(istype(user) && user.dna.features["taur"] == "Naga" || user.dna.features["taur"] == "Tentacle")
						target.visible_message("<span class='danger'>[src] carefully rolls their tail over [target]!</span>", "<span class='danger'>[src]'s huge tail rolls over you!</span>")
					else
						target.visible_message("<span class='danger'>[src] carefully steps on [target]!</span>", "<span class='danger'>[src] steps onto you with force!</span>")
					return TRUE

			if(user.a_intent == "harm" && CHECK_MOBILITY(user, MOBILITY_MOVE) && !user.buckled)
				now_pushing = 0
				user.forceMove(target.loc)
				user.sizediffStamLoss(target)
				user.sizediffBruteloss(target)
				playsound(loc, 'sound/misc/splort.ogg', 50, 1)
				user.add_movespeed_modifier(/datum/movespeed_modifier/stomp, TRUE)
				addtimer(CALLBACK(user, /mob/.proc/remove_movespeed_modifier, MOVESPEED_ID_STOMP, TRUE), 10) //1 second
				//user.Stun(20)
				// BLUEMOON ADDITION START - персонажи с тяжёлыми квирками наносят больше урона и на дольше станят, но сами получают стан
				if(HAS_TRAIT(user, TRAIT_BLUEMOON_HEAVY))
					user.Stun(0.5 SECONDS)
				else if(HAS_TRAIT(user, TRAIT_BLUEMOON_HEAVY_SUPER))
					user.Stun(1 SECONDS)
				// BLUEMOON ADDITION END
				if(iscarbon(user))
					if(istype(user) && (user.dna.features["taur"] == "Naga" || user.dna.features["taur"] == "Tentacle"))
						target.visible_message("<span class='danger'>[src] mows down [target] under their tail!</span>", "<span class='userdanger'>[src] plows their tail over you mercilessly!</span>")
					else
						target.visible_message("<span class='danger'>[src] slams their foot down on [target], crushing them!</span>", "<span class='userdanger'>[src] crushes you under their foot!</span>")
					return TRUE

			if(user.a_intent == "grab" && CHECK_MOBILITY(user, MOBILITY_MOVE) && !user.buckled)
				now_pushing = 0
				user.forceMove(target.loc)
				user.sizediffStamLoss(target)
				user.sizediffStun(target)
				user.add_movespeed_modifier(/datum/movespeed_modifier/stomp, TRUE)
				addtimer(CALLBACK(user, /mob/.proc/remove_movespeed_modifier, MOVESPEED_ID_STOMP, TRUE), 7)//About 3/4th a second
				if(iscarbon(user))
					var/feetCover = (user.wear_suit && (user.wear_suit.body_parts_covered & FEET)) || (user.w_uniform && (user.w_uniform.body_parts_covered & FEET) || (user.shoes && (user.shoes.body_parts_covered & FEET)))
					if(feetCover)
						if(user?.dna?.features["taur"] == "Naga" || user?.dna?.features["taur"] == "Tentacle")
							target.visible_message("<span class='danger'>[src] pins [target] under their tail!</span>", "<span class='danger'>[src] pins you beneath their tail!</span>")
						else
							target.visible_message("<span class='danger'>[src] pins [target] helplessly underfoot!</span>", "<span class='danger'>[src] pins you underfoot!</span>")
						return TRUE
					else
						if(user?.dna?.features["taur"] == "Naga" || user?.dna?.features["taur"] == "Tentacle")
							target.visible_message("<span class='danger'>[user] snatches up [target] underneath their tail!</span>", "<span class='userdanger'>[src]'s tail winds around you and snatches you in its coils!</span>")
							//target.mob_pickup_micro_feet(user)
							SEND_SIGNAL(target, COMSIG_MICRO_PICKUP_FEET, user)
						else
							target.visible_message("<span class='danger'>[user] stomps down on [target], curling their toes and picking them up!</span>", "<span class='userdanger'>[src]'s toes pin you down and curl around you, picking you up!</span>")
							//target.mob_pickup_micro_feet(user)
							SEND_SIGNAL(target, COMSIG_MICRO_PICKUP_FEET, user)
						return TRUE

		if(COMPARE_SIZES(target, user) >= 2)
			user.forceMove(target.loc)
			now_pushing = 0
			micro_step_under(target)
			return TRUE

/mob/living/proc/macro_step_around(mob/living/target)
	if(ishuman(src))
		var/mob/living/carbon/human/validmob = src
		if(validmob?.dna?.features["taur"] == "Naga" || validmob?.dna?.features["taur"] == "Tentacle")
			visible_message("<span class='notice'>[validmob] carefully slithers around [target].</span>", "<span class='notice'>You carefully slither around [target].</span>")
		else
			visible_message("<span class='notice'>[validmob] carefully steps around [target].</span>", "<span class='notice'>You carefully steps around [target].</span>")

//smaller person stepping under another person... TO DO, fix and allow special interactions with naga legs to be seen
/mob/living/proc/micro_step_under(mob/living/target)
	if(ishuman(src))
		var/mob/living/carbon/human/validmob = src
		if(validmob?.dna?.features["taur"] == "Naga" || validmob?.dna?.features["taur"] == "Tentacle")
			visible_message("<span class='notice'>[validmob] bounds over [target]'s tail.</span>", "<span class='notice'>You jump over [target]'s thick tail.</span>")
		else
			visible_message("<span class='notice'>[validmob] runs between [target]'s legs.</span>", "<span class='notice'>You run between [target]'s legs.</span>")

//Proc for scaling stamina damage on size difference
/mob/living/carbon/proc/sizediffStamLoss(mob/living/carbon/target)
	var/S = COMPARE_SIZES(src, target) * 5 //macro divided by micro, times 25 // BLUEMOON CHANGES - было 25, стало 5
	// BLUEMOON ADDITION AHEAD - усиление конечно результата за наличие квирка на тяжесть или сверхтяжесть
	if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY))
		S *= 1.5 // Если 100% наступает на 50% или 200% наступает на 100%, то наносится 15
	else if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY_SUPER))
		S *= 2 // Если 100% наступает на 50% или 200% наступает на 100%, то наносится 20 (у станбатона 35)
	target.apply_damage(S, STAMINA, BODY_ZONE_CHEST) // дополнительный урон по стамине за нерф опрокидывания на пол, т.к. чрезвычайно сильное в оригинале
	target.Dizzy(5)
	// BLUEMOON ADDITION END
	target.Knockdown(S/2) //final result in stamina knockdown // BLUEMOON CHANGES


//Proc for scaling stuns on size difference (for grab intent)
/mob/living/carbon/proc/sizediffStun(mob/living/carbon/target)
	var/T = COMPARE_SIZES(src, target) * 2 //Macro divided by micro, times 2
	// BLUEMOON ADDITION AHEAD - усиление конечно результата за наличие квирка на тяжесть или сверхтяжесть
	if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY))
		T *= 1.5
	else if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY_SUPER))
		T *= 2
	// BLUEMOON ADDITION END
	target.Stun(T)

//Proc for scaling brute damage on size difference
/mob/living/carbon/proc/sizediffBruteloss(mob/living/carbon/target)
	var/B = COMPARE_SIZES(src, target) * 3 //macro divided by micro, times 3
	to_chat(src, "[B]")
	// BLUEMOON ADDITION AHEAD - усиление конечно результата за наличие квирка на тяжесть или сверхтяжесть
	if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY))
		B *= 2
	else if(HAS_TRAIT(src, TRAIT_BLUEMOON_HEAVY_SUPER))
		B *= 3
	to_chat(src, "Конечная [B]")
	// BLUEMOON ADDITION END
	target.adjustBruteLoss(B) //final result in brute loss

//Proc for instantly grabbing valid size difference. Code optimizations soon(TM)
/*
/mob/living/proc/sizeinteractioncheck(mob/living/target)
	if(abs(get_effective_size()/target.get_effective_size())>=2.0 && get_effective_size()>target.get_effective_size())
		return 0
	else
		return 1
*/
//Clothes coming off at different sizes, and health/speed/stam changes as well
