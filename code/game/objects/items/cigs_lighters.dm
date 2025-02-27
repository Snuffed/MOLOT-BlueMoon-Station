//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO
ROLLING PAPER
VAPES
BONGS

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	grind_results = list(/datum/reagent/phosphorus = 2)

/obj/item/match/process()
	smoketime--
	if(smoketime < 1)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(exposed_temperature, exposed_volume)
	matchignite()

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		lit = TRUE
		icon_state = "match_lit"
		damtype = "fire"
		force = 3
		hitsound = 'sound/items/welder.ogg'
		item_state = "cigon"
		name = "lit match"
		desc = "A match. This one is lit."
		attack_verb = list("burnt","singed")
		START_PROCESSING(SSobj, src)
		update_icon()

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = "brute"
		force = initial(force)
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt match"
		desc = "A match. This one has seen better days."
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)

/obj/item/match/dropped(mob/user)
	matchburnout()
	. = ..()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.a_intent == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='notice'>[cig] is already lit.</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds [src] out for [M], and lights [cig].</span>")
	else
		..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/get_temperature()
	return lit * heat

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_EARS
	var/lit = FALSE
	var/starts_lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 30
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)
	heat = 1000

/obj/item/clothing/mask/cigarette/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src] as quickly as [user.ru_who()] can! It looks like [user.ru_who()] trying to give себя cancer.</span>")
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT, NO_REAGENTS_VALUE) // so it doesn't react until you light it
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff,90,list(BODY_ZONE_PRECISE_MOUTH),list(ITEM_SLOT_MASK))//90% to knock off when wearing a mask

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/DoRevenantThrowEffects(atom/target)
	if(lit)
		attackby()
	else
		light()

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user, params)
	if(!lit && smoketime > 0)
		var/lighting_text = W.ignition_effect(src, user)
		if(lighting_text)
			light(lighting_text)
	else
		return ..()

/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)
	. = ..()
	if(!proximity || lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		if(glass.reagents.trans_to(src, chem_volume, log = "cigar fill: dip cigarette"))	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")

/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		item_state = icon_on
		return

	lit = TRUE
	name = "lit [name]"
	attack_verb = list("burnt", "singed")
	hitsound = 'sound/items/welder.ogg'
	damtype = "fire"
	force = 4
	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	// allowing reagents to react after being lit
	reagents.reagents_holder_flags &= ~(NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	//can't think of any other way to update the overlays :<
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask()
		M.update_inv_hands()


/obj/item/clothing/mask/cigarette/proc/handle_reagents()
	if(reagents.total_volume)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1)
				reagents.reaction(C, INGEST, fraction)
				if(!reagents.trans_to(C, REAGENTS_METABOLISM))
					reagents.remove_any(REAGENTS_METABOLISM)
				return
		reagents.remove_any(REAGENTS_METABOLISM)


/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		new type_butt(location)
		if(ismob(loc))
			to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		qdel(src)
		return
	open_flame()
	if(reagents && reagents.total_volume)
		handle_reagents()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on \the [src], putting it out instantly.</span>")
		new type_butt(user.loc)
		new /obj/effect/decal/cleanable/ash(user.loc)
		qdel(src)
	. = ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()
	if(M.on_fire && !lit)
		light("<span class='notice'>[user] lights [src] with [M]'s burning body. What a cold-blooded badass.</span>")
		return
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.a_intent == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='notice'>The [cig.name] is already lit.</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights [M.ru_ego()] [cig.name].</span>")
	else
		return ..()

/obj/item/clothing/mask/cigarette/fire_act(exposed_temperature, exposed_volume)
	light()

/obj/item/clothing/mask/cigarette/get_temperature()
	return lit * heat

// Cigarette brands.

/obj/item/clothing/mask/cigarette/space_cigarette
	desc = "A Space Cigarette brand cigarette."

/obj/item/clothing/mask/cigarette/dromedary
	desc = "A DromedaryCo brand cigarette."

/obj/item/clothing/mask/cigarette/uplift
	desc = "An Uplift Smooth brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 7.5, /datum/reagent/consumable/menthol = 7.5)

/obj/item/clothing/mask/cigarette/robust
	desc = "A Robust brand cigarette."

/obj/item/clothing/mask/cigarette/robustgold
	desc = "A Robust Gold brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/gold = 1)

/obj/item/clothing/mask/cigarette/carp
	desc = "A Carp Classic brand cigarette."

/obj/item/clothing/mask/cigarette/syndicate
	desc = "An unknown brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/medicine/omnizine = 15)

/obj/item/clothing/mask/cigarette/shadyjims
	desc = "A Shady Jim's Super Slims cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/lipolicide = 4, /datum/reagent/ammonia = 2, /datum/reagent/toxin/plantbgone = 1, /datum/reagent/toxin = 1.5)

/obj/item/clothing/mask/cigarette/xeno
	desc = "A Xeno Filtered brand cigarette."
	list_reagents = list (/datum/reagent/drug/nicotine = 20, /datum/reagent/medicine/regen_jelly = 15, /datum/reagent/drug/krokodil = 4)

/obj/item/clothing/mask/cigarette/dart
	name = "fat dart"
	desc = "Chuff back this fat dart"
	icon_state = "bigoff"
	icon_on = "bigon"
	icon_off = "bigoff"
	w_class = WEIGHT_CLASS_BULKY
	smoketime = 10000
	chem_volume = 50
	list_reagents = list(/datum/reagent/drug/nicotine = 15)

// Rollies.

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"
	smoketime = 180
	chem_volume = 50
	list_reagents = null

/obj/item/clothing/mask/cigarette/rollie/New()
	..()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/space_drugs = 15, /datum/reagent/toxin/lipolicide = 35)

/obj/item/clothing/mask/cigarette/rollie/mindbreaker
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 35, /datum/reagent/toxin/lipolicide = 15)

/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/New()
	..()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)


////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 40

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 2000
	chem_volume = 80


/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 7200
	chem_volume = 50

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/trash)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 0
	chem_volume = 100
	list_reagents = null
	var/packeditem = 0

/obj/item/clothing/mask/cigarette/pipe/Initialize(mapload)
	. = ..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/cigarette/pipe/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask()
			packeditem = 0
			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/G = O
		if(!packeditem)
			if(G.dry == 1)
				to_chat(user, "<span class='notice'>You stuff [O] into [src].</span>")
				smoketime = 400
				packeditem = 1
				name = "[O.name]-packed [initial(name)]"
				if(O.reagents)
					O.reagents.trans_to(src, O.reagents.total_volume, log = "cigar fill: pipe pack")
				qdel(O)
			else
				to_chat(user, "<span class='warning'>It has to be dried first!</span>")
		else
			to_chat(user, "<span class='warning'>It is already packed!</span>")
	else
		var/lighting_text = O.ignition_effect(src,user)
		if(lighting_text)
			if(smoketime > 0)
				light(lighting_text)
			else
				to_chat(user, "<span class='warning'>There is nothing to smoke!</span>")
		else
			return ..()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(!lit && smoketime > 0)
		to_chat(user, "<span class='notice'>You empty [src] onto [location].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		packeditem = 0
		smoketime = 0
		reagents.clear_reagents()
		name = "empty [initial(name)]"
	return

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters. Can be loaded with objects."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 0


/////////
//ZIPPO//
/////////
/obj/item/lighter
	name = "\improper Zippo Lighter"
	desc = "The zippo."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/lit = 0
	var/fancy = TRUE
	var/overlay_state
	var/apply_damage
	var/overlay_list = list(
		"plain",
		"dame",
		"thirteen",
		"snake"
		)
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/oil = 5)
	custom_price = PRICE_ALMOST_CHEAP

/obj/item/lighter/Initialize(mapload)
	. = ..()
	if(!overlay_state)
		overlay_state = pick(overlay_list)
	update_icon()

/obj/item/lighter/DoRevenantThrowEffects(atom/target)
	set_lit()

/obj/item/lighter/suicide_act(mob/living/carbon/user)
	if (lit)
		user.visible_message("<span class='suicide'>[user] begins holding \the [src]'s flame up to [user.ru_ego()] face! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/items/welder.ogg', 50, 1)
		return FIRELOSS
	else
		user.visible_message("<span class='suicide'>[user] begins whacking themself with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return BRUTELOSS

/obj/item/lighter/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"

/obj/item/lighter/update_overlays()
	. = ..()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	. += lighter_overlay

/obj/item/lighter/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='rose'>Одним плавным движением [user] поджигает [A]. Блин, а ты крутой!</span>"

/obj/item/lighter/proc/set_lit(new_lit)
	lit = new_lit
	if(lit)
		force = 5
		damtype = "fire"
		hitsound = 'sound/items/welder.ogg'
		attack_verb = list("burnt", "singed")
		set_light(2, 0.6, LIGHT_COLOR_FIRE)
		START_PROCESSING(SSobj, src)
	else
		hitsound = "swing_hit"
		force = 0
		attack_verb = null //human_defense.dm takes care of it
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/lighter/attack_self(mob/living/user)
	user.DelayNextAction(CLICK_CD_MELEE)
	if(user.is_holding(src))
		if(!lit)
			set_lit(TRUE)
			if(fancy)
				user.visible_message("Одним плавным движением <b>[user]</b> открывает и зажигает '[src]'!", "<span class='notice'><b>Вы одним плавным движением открываете и зажигаете '[src]'!</b>.</span>")
				playsound(src, 'sound/weapons/zippolight.ogg', 40, TRUE)
			else
				var/prot = FALSE
				var/mob/living/carbon/human/H = user

				if(istype(H) && H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(G.max_heat_protection_temperature)
						prot = (G.max_heat_protection_temperature > 360)
				else
					prot = TRUE

				if(prob(75) && prot)
					user.visible_message("Спустя несколько утруждающих попыток <b>[user]</b> наконец-то зажигает '[src]'.", "<span class='notice'><b>Спустя несколько попыток ты наконец-то зажигаешь '[src]'!</b></span>")
					playsound(src, pick('sound/weapons/lighter1.ogg', 'sound/weapons/lighter2.ogg', 'sound/weapons/lighter3.ogg'), 75, 1)
				else
					var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
					user.apply_damage(5, BURN, hitzone)
					user.visible_message("<span class='warning'>После нескольких попыток <b>[user]</b> удается зажечь '[src]', ценой чего становятся обожжённые пальцы!</span>", "<span class='warning'><b>Вы обжигаетесь об зажигалку!</b></span>")
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "burnt_thumb", /datum/mood_event/burnt_thumb)
					playsound(src, pick('sound/weapons/lighter1.ogg', 'sound/weapons/lighter2.ogg', 'sound/weapons/lighter3.ogg'), 75, 1)

		else
			set_lit(FALSE)
			if(fancy)
				user.visible_message("Вы слышите тихий щелчок со стороны <b>[user]</b>.", "<span class='notice'><b>Вы практически бесшумно закрыли '[src]'.</b></span>")
				playsound(src, 'sound/weapons/zippoclose.ogg', 40, TRUE)
			else
				user.visible_message("<b>[user]</b> закрыли '[src]' одним плавным движением.", "<span class='notice'><b>Вы закрыли '[src]' одним плавным движением.</b></span>")
	else
		. = ..()

/obj/item/lighter/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.a_intent == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='notice'>The [cig.name] is already lit.</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			if(fancy)
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M]. [user.ru_ego(TRUE)] arm is as steady as the unflickering flame [user.ru_who()] light[user.p_s()] \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights [M.ru_ego()] [cig.name].</span>")
	else
		..()

/obj/item/lighter/process()
	open_flame()

/obj/item/lighter/get_temperature()
	return lit * heat


/obj/item/lighter/greyscale
	name = "Cheap Lighter"
	desc = "A cheap-as-free lighter."
	icon_state = "lighter"
	fancy = FALSE
	custom_price = PRICE_CHEAP_AS_FREE
	overlay_list = list(
		"transp",
		"tall",
		"matte",
		"zoppo" //u cant stoppo th zoppo
		)
	var/lighter_color
	var/list/color_list = list( //Same 16 color selection as electronic assemblies
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/lighter/greyscale/Initialize(mapload)
	. = ..()
	if(!lighter_color)
		lighter_color = pick(color_list)
	update_icon()

/obj/item/lighter/greyscale/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"

/obj/item/lighter/greyscale/update_overlays()
	. = ..()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	lighter_overlay.color = lighter_color
	. += lighter_overlay

/obj/item/lighter/greyscale/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='notice'>After some fiddling, [user] manages to light [A] with [src].</span>"


/obj/item/lighter/slime
	name = "Slime Zippo"
	desc = "A specialty zippo made from slimes and industry. Has a much hotter flame than normal."
	icon_state = "slighter"
	heat = 3000 //Blue flame!
	light_color = LIGHT_COLOR_CYAN
	overlay_state = "slime"
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/medicine/pyroxadone = 5)

//EXTRA LIGHTERS
/obj/item/lighter/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon_state = "zippo_nt_off"
	item_state = "ntzippo"

/obj/item/lighter/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "bluezippo"
	item_state = "bluezippo"

/obj/item/lighter/purple
	name = "Purple Engraved Zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon_state = "purple_zippo_off"
	item_state = "rubysfluffzippo"

/obj/item/lighter/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "blackzippo"
	item_state = "chapzippo"

/obj/item/lighter/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "engravedzippo"
	item_state = "engravedzippo"

/obj/item/lighter/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "gonzozippo"
	item_state = "gonzozippo"

/obj/item/lighter/cap
	name = "Captain's zippo"
	desc = "A limited edition gold Zippo espesially for NT Captains. Looks extremely expensive."
	icon_state = "zippo_cap"
	item_state = "capzippo"

/obj/item/lighter/hop
	name = "Head of personnel zippo"
	desc = "A limited edition Zippo for NT Heads. Tries it best to look like captain's."
	icon_state = "zippo_hop"
	item_state = "hopzippo"

/obj/item/lighter/hos
	name = "Head of Security zippo"
	desc = "A limited edition Zippo for NT Heads. Fuel it with clown's tears."
	icon_state = "zippo_hos"
	item_state = "hoszippo"

/obj/item/lighter/cmo
	name = "Chief Medical Officer zippo"
	desc = "A limited edition Zippo for NT Heads. Made of hypoallergenic steel."
	icon_state = "zippo_cmo"
	item_state = "bluezippo"

/obj/item/lighter/ce
	name = "Chief Engineer zippo"
	desc = "A limited edition Zippo for NT Heads. Somebody've tried to repair cover with blue tape."
	icon_state = "zippo_ce"
	item_state = "cezippo"

/obj/item/lighter/rd
	name = "Research Director zippo"
	desc = "A limited edition Zippo for NT Heads. Uses advanced tech to make fire from plasma."
	icon_state = "zippo_rd"
	item_state = "rdzippo"

//Ninja-Zippo//
/obj/item/lighter/ninja
	name = "\"Shinobi on a rice field\" zippo"
	desc = "A custom made Zippo. It looks almost like a bag of noodles. There is a blood stain on it, and it smells like burnt rice..."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "zippo_ninja"
	item_state = "zippo_ninja"

/obj/item/lighter/gold
	name = "\improper Engraved Zippo"
	desc = "A shiny and relatively expensive zippo lighter. There's a small etched in verse on the bottom that reads, 'No Gods, No Masters, Only Man.'"
	icon = 'icons/obj/custom.dmi'
	icon_state = "gold_zippo"
	item_state = "gold_zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE

/obj/item/lighter/contractor
	name = "contractor zippo lighter"
	desc = "An unique black and gold zippo commonly carried by elite Syndicate agents."
	icon_state = "contractorzippo"
	item_state = "contractorzippo"

///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "Rolling Paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/O = target
		if(O.dry)
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume, log = "cigar fill: rolling paper afterattack")
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a rolling paper.</span>")
			R.desc = "Dried [target.name] rolled up in a thin piece of paper."
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")

///////////////
//VAPE NATION//
///////////////
/obj/item/clothing/mask/vape
	name = "\improper E-Cigarette"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\""//<<< i'd vape to that.
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "black_vape"
	item_state = "black_vape"
	w_class = WEIGHT_CLASS_TINY
	var/chem_volume = 100
	var/vapetime = FALSE //this so it won't puff out clouds every tick
	var/screw = FALSE // kinky
	var/super = FALSE //for the fattest vapes dude.

/obj/item/clothing/mask/vape/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is puffin hard on dat vape, [user.ru_who()] trying to join the vape life on a whole notha plane!</span>")//it doesn't give you cancer, it is cancer
	return (TOXLOSS|OXYLOSS)


/obj/item/clothing/mask/vape/Initialize(mapload, param_color)
	. = ..()
	create_reagents(chem_volume, NO_REACT, NO_REAGENTS_VALUE) // so it doesn't react until you light it
	reagents.add_reagent(/datum/reagent/drug/nicotine, 50)
	if(!param_color)
		param_color = pick("red","blue","black","white","green","purple","yellow","orange")
	icon_state = "[param_color]_vape"
	item_state = "[param_color]_vape"

/obj/item/clothing/mask/vape/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER)
		if(!screw)
			screw = TRUE
			to_chat(user, "<span class='notice'>You open the cap on [src].</span>")
			reagents.reagents_holder_flags |= OPENCONTAINER
			if(obj_flags & EMAGGED)
				add_overlay("vapeopen_high")
			else if(super)
				add_overlay("vapeopen_med")
			else
				add_overlay("vapeopen_low")
		else
			screw = FALSE
			to_chat(user, "<span class='notice'>You close the cap on [src].</span>")
			reagents.reagents_holder_flags &= ~(OPENCONTAINER)
			cut_overlays()

	if(O.tool_behaviour == TOOL_MULTITOOL)
		if(screw && !(obj_flags & EMAGGED))//also kinky
			if(!super)
				cut_overlays()
				super = TRUE
				to_chat(user, "<span class='notice'>You increase the voltage of [src].</span>")
				add_overlay("vapeopen_med")
			else
				cut_overlays()
				super = FALSE
				to_chat(user, "<span class='notice'>You decrease the voltage of [src].</span>")
				add_overlay("vapeopen_low")

		if(screw && (obj_flags & EMAGGED))
			to_chat(user, "<span class='notice'>[src] can't be modified!</span>")

		else
			..()

/obj/item/clothing/mask/vape/emag_act(mob/user)// I WON'T REGRET WRITTING THIS, SURLY.
	. = ..()
	if(!screw)
		to_chat(user, "<span class='notice'>You need to open the cap to do that.</span>")
		return
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>[src] is already emagged!</span>")
		return
	cut_overlays()
	obj_flags |= EMAGGED
	super = FALSE
	to_chat(user, "<span class='warning'>You maximize the voltage of [src].</span>")
	add_overlay("vapeopen_high")
	log_admin("[key_name(usr)] emagged [src] at [AREACOORD(src)]")
	var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread //for effect
	sp.set_up(5, 1, src)
	sp.start()
	return TRUE

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(reagents.total_volume > 0)
		to_chat(user, "<span class='notice'>You empty [src] of all reagents.</span>")
		reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK)
		if(!screw)
			to_chat(user, "<span class='notice'>You start puffing on the vape.</span>")
			reagents.reagents_holder_flags &= ~(NO_REACT)
			START_PROCESSING(SSobj, src)
		else //it will not start if the vape is opened.
			to_chat(user, "<span class='warning'>You need to close the cap first!</span>")

/obj/item/clothing/mask/vape/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/C = user
	if(C.get_item_by_slot(ITEM_SLOT_MASK) == src)
		reagents.reagents_holder_flags |= NO_REACT
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/proc/hand_reagents()//had to rename to avoid duplicate error
	if(reagents.total_volume)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1) //this will react instantly, making them a little more dangerous than cigarettes
				reagents.reaction(C, INGEST, fraction)
				if(!reagents.trans_to(C, REAGENTS_METABOLISM))
					reagents.remove_any(REAGENTS_METABOLISM)
				if(reagents.get_reagent_amount(/datum/reagent/fuel))
					//HOT STUFF
					C.fire_stacks = 2
					C.IgniteMob()

				if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
					var/datum/effect_system/reagents_explosion/e = new()
					e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
					e.start()
					qdel(src)
				return
		reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/vape/process()
	var/mob/living/M = loc

	if(isliving(loc))
		M.IgniteMob()

	vapetime++

	if(!reagents.total_volume)
		if(ismob(loc))
			to_chat(M, "<span class='notice'>[src] is empty!</span>")
			STOP_PROCESSING(SSobj, src)
			//it's reusable so it won't unequip when empty
		return
	//open flame removed because vapes are a closed system, they wont light anything on fire

	if(super && vapetime > 3)//Time to start puffing those fat vapes, yo.
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 1, 24, loc)
		s.start()
		vapetime = 0

	if((obj_flags & EMAGGED) && vapetime > 3)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 4, 24, loc)
		s.start()
		vapetime = 0
		if(prob(5))//small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/effects/pop_expl.ogg', 50, 0)
			M.apply_damage(20, BURN, BODY_ZONE_HEAD)
			M.DefaultCombatKnockdown(300, 1, 0)
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, "<span class='userdanger'>[src] suddenly explodes in your mouth!</span>")
			qdel(src)
			return

	if(reagents && reagents.total_volume)
		hand_reagents()

///////////////
/////BONGS/////
///////////////

/obj/item/bong
	name = "Bong"
	desc = "A water bong used for smoking dried plants."
	icon = 'icons/obj/bongs.dmi'
	icon_state = null
	item_state = "bongoff"
	w_class = WEIGHT_CLASS_NORMAL
	light_color = "#FFCC66"
	var/icon_off = "bongoff"
	var/icon_on = "bongon"
	var/chem_volume = 100
	var/last_used_time //for cooldown
	var/firecharges = 0 //used for counting how many hits can be taken before the flame goes out
	var/list/list_reagents = list() //For the base reagents bongs could get


/obj/item/bong/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, NO_REACT) // so it doesn't react until you light it
	reagents.add_reagent_list(list_reagents)
	icon_state = icon_off

/obj/item/bong/attackby(obj/item/O, mob/user, params)
	. = ..()
	//If we're using a dried plant..
	if(istype(O,/obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/DP = O
		if (DP.dry)
			//Nothing if our bong is full
			if (reagents.holder_full())
				user.show_message("<span class='notice'>The bowl is full!</span>", MSG_VISUAL)
				return

			//Transfer reagents and remove the plant
			user.show_message("<span class='notice'>You stuff the [DP] into the [src]'s bowl.</span>", MSG_VISUAL)
			DP.reagents.trans_to(src, 100, log = "cigar fill: bong")
			qdel(DP)
			return
		else
			user.show_message("<span class='warning'>[DP] must be dried first!</span>", MSG_VISUAL)
			return

	if (O.get_temperature() <= 500)
		return
	if (reagents && reagents.total_volume) //if there's stuff in the bong
		var/lighting_text = O.ignition_effect(src, user)
		if(lighting_text)
			//Logic regarding igniting it on
			if (firecharges == 0)
				user.show_message("<span class='notice'>You light the [src] with the [O]!</span>", MSG_VISUAL)
				bongturnon()
			else
				user.show_message("<span class='notice'>You rekindle [src]'s flame with the [O]!</span>", MSG_VISUAL)

			firecharges = 1
			return
	else
		user.show_message("<span warning='notice'>There's nothing to light up in the bowl.</span>", MSG_VISUAL)
		return

/obj/item/bong/CtrlShiftClick(mob/user) //empty reagents on alt click
	..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return

	if (reagents && reagents.total_volume)
		user.show_message("<span class='notice'>You empty the [src].</span>", MSG_VISUAL)
		reagents.clear_reagents()
		if(firecharges)
			firecharges = 0
			bongturnoff()
	else
		user.show_message("<span class='notice'>The [src] is already empty.</span>", MSG_VISUAL)

/obj/item/bong/AltClick(mob/user)
	..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return

	if(firecharges)
		firecharges = 0
		bongturnoff()
		user.show_message("<span class='notice'>You quench the flame.</span>", MSG_VISUAL)
		return TRUE

/obj/item/bong/examine(mob/user)
	. = ..()
	if(!reagents.total_volume)
		. += "<span class='notice'>The bowl is empty.</span>"
	else if (reagents.total_volume > 80)
		. += "<span class='notice'>The bowl is filled to the brim.</span>"
	else if (reagents.total_volume > 40)
		. += "<span class='notice'>The bowl has plenty weed in it.</span>"
	else
		. += "<span class='notice'>The bowl has some weed in it.</span>"

	. += "<span class='notice'>Ctrl+Shift-click to empty.</span>"
	. += "<span class='notice'>Alt-click to extinguish.</span>"

/obj/item/bong/ignition_effect(atom/A, mob/user)
	if(firecharges)
		. = "<span class='notice'>[user] lights [A] off of the [src].</span>"
	else
		. = ""

/obj/item/bong/attack(mob/living/carbon/M, mob/living/carbon/user, obj/target)
	//if it's lit up, some stuff in the bowl and the user is a target, and we're not on cooldown

	if (M != user)
		return ..()

	if(user.is_mouth_covered(head_only = 1))
		to_chat(user, "<span class='warning'>Remove your headgear first.</span>")
		return ..()

	if(user.is_mouth_covered(mask_only = 1))
		to_chat(user, "<span class='warning'>Remove your mask first.</span>")
		return ..()

	if (!reagents.total_volume)
		to_chat(user, "<span class='warning'>There's nothing in the bowl.</span>")
		return ..()

	if (!firecharges)
		to_chat(user, "<span class='warning'>You have to light it up first.</span>")
		return ..()

	if (last_used_time + 30 >= world.time)
		return ..()
	var/hit_strength
	var/noise
	var/hittext = ""
	//if the intent is help then you take a small hit, else a big one
	if (user.a_intent == INTENT_HARM)
		hit_strength = 2
		noise = 100
		hittext = "big hit"
	else
		hit_strength = 1
		noise = 70
		hittext = "hit"
	//bubbling sound
	playsound(user.loc,'sound/effects/bonghit.ogg', noise, 1)

	last_used_time = world.time

	//message
	user.visible_message("<span class='notice'>[user] begins to take a [hittext] from the [src]!</span>", \
								"<span class='notice'>You begin to take a [hittext] from [src].</span>")

	//we take a hit here, after an uninterrupted delay
	if(!do_after(user, 25, target = user))
		return
	if (!(reagents && reagents.total_volume))
		return

	var/fraction = 12 * hit_strength

	var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
	s.set_up(reagents, hit_strength, 18, user.loc)
	s.start()

	reagents.reaction(user, INGEST, fraction)
	if(!reagents.trans_to(user, fraction))
		reagents.remove_any(fraction)

	if (hit_strength == 2 && prob(15))
		user.emote("cough")
		user.adjustOxyLoss(15)

	user.visible_message("<span class='notice'>[user] takes a [hittext] from the [src]!</span>", \
							"<span class='notice'>You take a [hittext] from [src].</span>")

	firecharges = firecharges - 1
	if (!firecharges)
		bongturnoff()
	if (!reagents.total_volume)
		firecharges = 0
		bongturnoff()



/obj/item/bong/proc/bongturnon()
	icon_state = icon_on
	item_state = "bongon"
	set_light(3, 0.8)

/obj/item/bong/proc/bongturnoff()
	icon_state = icon_off
	item_state = "bongoff"
	set_light(0, 0.0)



/obj/item/bong/coconut
	name = "Coconut Bong"
	icon_off = "coconut_bong"
	icon_on = "coconut_bong_lit"
	desc = "A water bong used for smoking dried plants. This one's made out of a coconut and some bamboo."
