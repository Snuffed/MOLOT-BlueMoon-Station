/datum/interaction/lewd/do_breastfeed
	description = "Грудь. Покормить грудью."
	require_user_breasts = REQUIRE_EXPOSED
	require_target_mouth = TRUE
	max_distance = 1
	write_log_user = "breastfed"
	write_log_target = "was breastfed by"
	interaction_sound = null

/datum/interaction/lewd/do_breastfeed/display_interaction(mob/living/user, mob/living/target)
	var/message
	var/obj/item/organ/genital/breasts/milkers = user.getorganslot(ORGAN_SLOT_BREASTS)
	var/milktype = milkers?.fluid_id
	var/modifier
	var/list/lines

	if(!milkers || !milktype)
		return

	var/datum/reagent/milk = find_reagent_object_from_type(milktype)

	var/milktext = milk.name

	lines = list(
		"прижимает свою грудь ко рту <b>[target]</b>, направляет свой сосок на язык и выплёскивает тёплое <b>'[lowertext(milktext)]'</b>",
		"наполняет рот \the <b>[target]</b> тёплым и довольно сладким на первовкусие <b>'[lowertext(milktext)]'</b>, когда в свою очередь сжимает сиськи и тяжело дышит",
		"позволяет большому количеству <b>'[lowertext(milktext)]'</b> орошить горло \the <b>[target]</b>!"
	)

	message = "<span class='lewd'>\The <b>[user]</b> [pick(lines)]</span>"
	user.visible_message(message, ignored_mobs = user.get_unconsenting())
	playlewdinteractionsound(get_turf(user), pick('modular_sand/sound/interactions/oral1.ogg',
						'modular_sand/sound/interactions/oral2.ogg'), 70, 1, -1)

	switch(milkers.size)
		if("c", "d", "e")
			modifier = 2
		if("f", "g", "h")
			modifier = 3
		else
			if(milkers.size in GLOB.breast_values)
				modifier = clamp(GLOB.breast_values[milkers.size] - 5, 0, INFINITY)
			else
				modifier = 1
	target.reagents.add_reagent(milktype, rand(1,3 * modifier))

/datum/interaction/lewd/titgrope
	description = "Грудь. Сжать в ладони."
	require_user_hands = TRUE
	require_target_breasts = REQUIRE_ANY
	write_log_user = "groped"
	write_log_target = "was groped by"
	interaction_sound = null
	max_distance = 1

	additional_details = list(
		list(
			"info" = "You can fill a container if you hold it in your hand or pull it",
			"icon" = "flask",
			"color" = "transparent"
			)
	)

/datum/interaction/lewd/titgrope/display_interaction(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/reagent_containers/liquid_container

	var/obj/item/cached_item = user.get_active_held_item()
	if(istype(cached_item, /obj/item/reagent_containers))
		liquid_container = cached_item
	else
		cached_item = user.pulling
		if(istype(cached_item, /obj/item/reagent_containers))
			liquid_container = cached_item

	if(liquid_container)
		var/obj/item/organ/genital/breasts/milkers = target.getorganslot(ORGAN_SLOT_BREASTS)
		var/milktype = milkers?.fluid_id

		if(milkers && milktype)
			var/modifier
			switch(milkers.size)
				if("c", "d", "e")
					modifier = 2
				if("f", "g", "h")
					modifier = 3
				else
					if(milkers.size in GLOB.breast_values) //SPLURT edit - global breast values
						modifier = clamp(GLOB.breast_values[milkers.size] - 5, 0, INFINITY)
					else
						modifier = 1
			liquid_container.reagents.add_reagent(milktype, rand(1,3 * modifier))

			user.visible_message(span_lewd("<b>\The [user]</b> выдавливает содержимое груди <b>[target]</b> в [liquid_container]."), ignored_mobs = user.get_unconsenting())
			playlewdinteractionsound(get_turf(user), 'modular_sand/sound/interactions/squelch1.ogg', 50, 1, -1)
	else
		if(user.a_intent == INTENT_HARM)
			user.visible_message(
					pick(span_lewd("\The <b>[user]</b> грубо лапает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> хватается за грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> сильно сжимает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> шлёпает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> грубо лапает сиськи <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> сильно сжимает сиськи <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> шлёпает сиськи <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> хватается за сиськи <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> дёргает сиськи <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> дёргает соски <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> грубо давит на соски <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> дёргает грудь <b>[target]</b>.")))
		else
			user.visible_message(
					pick(span_lewd("\The <b>[user]</b> аккуратно лапает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> обхватывает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> аккуратно сжимает грудь <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> обводит грудь <b>[target]</b> своими пальцами."),
						span_lewd("\The <b>[user]</b> бережно обжимает соски <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> деликатно сжимает сосок <b>[target]</b>."),
						span_lewd("\The <b>[user]</b> нежно ощупывает грудь <b>[target]</b>.")))
		if(prob(5 + target.get_lust()))
			if(target.a_intent == INTENT_HELP)
				user.visible_message(
					pick(span_lewd("\The <b>[target]</b> дрожит от возбуждения."),
						span_lewd("\The <b>[target]</b> тихо постанывает."),
						span_lewd("\The <b>[target]</b> выдыхает довольный стон."),
						span_lewd("\The <b>[target]</b> тихонько вздрагивает."),
						span_lewd("\The <b>[target]</b> задыхается от возбуждения."),
						span_lewd("\The <b>[target]</b> возбуждённо урчит."),
						span_lewd("\The <b>[target]</b> возбуждённо мурлычет.")))
				if(target.get_lust() < 5)
					target.set_lust(5)
			if(target.a_intent == INTENT_DISARM)
				if (target.restrained())
					user.visible_message(
						pick(span_lewd("\The <b>[target]</b> игриво извивается в попытке снять физические ограничения."),
							span_lewd("\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>."),
							span_lewd("\The <b>[target]</b> скользит в сторону от приближающегося <b>[user]</b>."),
							span_lewd("\The <b>[target]</b> с отсутствующим сопротивлением толкает обнажённую грудь вперёд в руки <b>[user]</b>.")))
				else
					user.visible_message(
						pick(span_lewd("\The <b>[target]</b> игриво извивается в попытке снять физические ограничения."),
							span_lewd("\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>."),
							span_lewd("\The <b>[target]</b> скользит в сторону от приближающегося <b>[user]</b>."),
							span_lewd("\The <b>[target]</b> с отсутствующим сопротивлением толкает обнажённую грудь вперёд в руки <b>[user]</b>.")))
				if(target.get_lust() < 10)
					target.add_lust(1)
		if(target.a_intent == INTENT_GRAB)
			user.visible_message(
					pick(span_lewd("\The <b>[target]</b> крепко сжимает запястье <b>[user]</b>."),
					span_lewd("\The <b>[target]</b> впивается ногтями в руку <b>[user]</b>."),
					span_lewd("\The <b>[target]</b> хватает <b>[user]</b> за запястье пальцами.")))
		if(target.a_intent == INTENT_HARM)
			user.adjustBruteLoss(5)
			user.visible_message(
					pick(span_lewd("\The <b>[target]</b> грубо отталкивает <b>[user]</b>."),
					span_lewd("\The <b>[target]</b> сердито впивается в руку <b>[user]</b>."),
					span_lewd("\The <b>[target]</b> яростно борется с <b>[user]</b>."),
					span_lewd("\The <b>[target]</b> впивается в предплечье <b>[user]</b> роговыми пластинками."),
					span_lewd("\The <b>[target]</b> шлёпает <b>[user]</b> по руке.")))
