//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "Bio Hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological contaminants."
	dynamic_hair_suffix = ""
	permeability_coefficient = 0.01
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 60, FIRE = 30, ACID = 100)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	resistance_flags = ACID_PROOF
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/suit/bio_suit
	name = "Bio Suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
	tail_state = "syndicate-winter"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 1
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/pen, /obj/item/flashlight/pen, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 60, FIRE = 30, ACID = 100)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAUR
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = ACID_PROOF
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_SNEK_TAURIC|STYLE_PAW_TAURIC

//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_virology"
	tail_state = "syndicate-winter"

//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"
	tail_state = "syndicate-winter"

//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 80, FIRE = 30, ACID = 100)
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 80, FIRE = 30, ACID = 100)
	icon_state = "bio_security"
	tail_state = "syndicate-winter"

//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"
	tail_state = "syndicate-winter"

//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"
	tail_state = "syndicate-winter"

//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"
	tail_state = "syndicate-winter"

//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	tail_state = "ert-alert"
	strip_delay = 40
	equip_delay_other = 20
	slowdown = 0
