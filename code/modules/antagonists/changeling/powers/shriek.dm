/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded. Costs 20 chemicals."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors. This ability is somewhat loud, and carries a small risk of our blood gaining violent sensitivity to heat."
	button_icon_state = "resonant_shriek"
	chemical_cost = 20
	dna_cost = 2
	loudness = 1
	req_human = TRUE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	for(var/mob/living/M in get_hearers_in_view(4, user))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.mind || !C.mind.has_antag_datum(/datum/antagonist/changeling))
				C.adjustEarDamage(0, 30)
				C.confused += 25
				C.Jitter(50)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			M.DefaultCombatKnockdown(rand(100,200))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, break_light_tube))

	playsound(get_turf(user), 'sound/effects/lingscreech.ogg', 75, TRUE, 5)
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics. Costs 20 chemicals."
	helptext = "Emits a high-frequency sound that overloads nearby electronics. This ability is somewhat loud, and carries a small risk of our blood gaining violent sensitivity to heat."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 20
	dna_cost = 2
	loudness = 1

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.break_light_tube()
	empulse_using_range(get_turf(user), 8, TRUE)
	playsound(get_turf(user), 'sound/effects/lingempscreech.ogg', 75, TRUE, 5)
	return TRUE
