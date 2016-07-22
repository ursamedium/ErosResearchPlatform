var/datum/species/shapeshifter/promethean/prometheans

// Species definition follows.
/datum/species/shapeshifter/promethean

	name =             "Promethean"
	name_plural =      "Prometheans"
	blurb =            "What has Science done? Prometheans are soft, shapeshifting slime-people. The ones that are older ages tend to be scientists that have experimented on themselves and turned into a Promethean. Younger ones were created by science."
	show_ssd =         "totally quiescent"
	death_message =    "rapidly loses cohesion, splattering across the ground..."
	knockout_message = "collapses inwards, forming a disordered puddle of goo."
	remains_type = /obj/effect/decal/cleanable/ash

	blood_color = "#05FF9B"
	flesh_color = "#05FFFB"

	hunger_factor =    DEFAULT_HUNGER_FACTOR //todo
	reagent_tag =      IS_SLIME
	mob_size =         MOB_SMALL
	bump_flag =        SLIME
	swap_flags =       MONKEY|SLIME|SIMPLE_ANIMAL
	push_flags =       MONKEY|SLIME|SIMPLE_ANIMAL
	flags =            NO_SCAN | NO_SLIP | NO_MINOR_CUT
	appearance_flags = HAS_SKIN_COLOR | HAS_EYE_COLOR | HAS_HAIR_COLOR | RADIATION_GLOWS | HAS_UNDERWEAR
	spawn_flags =      SPECIES_CAN_JOIN
	health_hud_intensity = 2

	breath_type = null
	poison_type = null

	gluttonous =            3
	virus_immune =          1
	blood_volume =          600
	min_age =               18
	max_age =               30
	brute_mod =             0.5
	burn_mod =              2
	oxy_mod =               0
	total_health =          120

	cold_level_1 =          260
	cold_level_2 =          200
	cold_level_3 =          120

	heat_level_1 =          360
	heat_level_2 =          400
	heat_level_3 =          1000

	body_temperature =      310.15

	siemens_coefficient =   -1
	rarity_value =          5

	unarmed_types = list(/datum/unarmed_attack/slime_glomp)
	has_organ =     list(O_BRAIN = /obj/item/organ/internal/brain/slime) // Slime core.
	has_limbs = list(
		BP_TORSO =  list("path" = /obj/item/organ/external/chest/unbreakable/slime),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/unbreakable/slime),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/unbreakable/slime),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/unbreakable/slime),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/unbreakable/slime),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/unbreakable/slime),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/unbreakable/slime),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable/slime),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable/slime),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable/slime),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable/slime)
		)
	heat_discomfort_strings = list("You feel too warm.")
	cold_discomfort_strings = list("You feel too cool.")

	inherent_verbs = list(
		/mob/living/carbon/human/proc/shapeshifter_select_shape,
		/mob/living/carbon/human/proc/shapeshifter_select_colour,
		/mob/living/carbon/human/proc/shapeshifter_select_hair,
		/mob/living/carbon/human/proc/shapeshifter_select_gender
		)

	valid_transform_species = list("Human", "Unathi", "Tajara", "Skrell", "Diona", "Teshari", "Akula")
	monochromatic = 1

	var/heal_rate = 5 // Temp. Regen per tick.

/datum/species/shapeshifter/promethean/New()
	..()
	prometheans = src

/datum/species/shapeshifter/promethean/equip_survival_gear(var/mob/living/carbon/human/H)
	var/boxtype = pick(typesof(/obj/item/weapon/storage/toolbox/lunchbox))
	var/obj/item/weapon/storage/toolbox/lunchbox/L = new boxtype(get_turf(H))
	var/mob/living/simple_animal/mouse/mouse = new (L)
	var/obj/item/weapon/holder/holder = new (L)
	mouse.forceMove(holder)
	holder.sync(mouse)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(L, slot_r_hand)
	else
		H.equip_to_slot_or_del(L, slot_in_backpack)

/datum/species/shapeshifter/promethean/hug(var/mob/living/carbon/human/H,var/mob/living/target)

	var/t_him = "them"
	switch(target.gender)
		if(MALE)
			t_him = "him"
		if(FEMALE)
			t_him = "her"

	H.visible_message("<span class='notice'>\The [H] glomps [target] to make [t_him] feel better!</span>", \
					"<span class='notice'>You glomps [target] to make [t_him] feel better!</span>")
	H.apply_stored_shock_to(target)

/datum/species/shapeshifter/promethean/handle_death(var/mob/living/carbon/human/H)
	spawn(1)
		if(H)
			H.gib()

/datum/species/shapeshifter/promethean/handle_environment_special(var/mob/living/carbon/human/H)

	var/turf/T = H.loc
	if(istype(T))
		var/obj/effect/decal/cleanable/C = locate() in T
		if(C)
			qdel(C)
			//TODO: gain nutriment

	// Regenerate limbs and heal damage if we have any. Copied from Bay xenos code.

	// Theoretically the only internal organ a slime will have
	// is the slime core. but we might as well be thorough.
	for(var/obj/item/organ/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				H << "<span class='notice'>You feel a soothing sensation within your [I.name]...</span>"
			return 1

	// Replace completely missing limbs.
	for(var/limb_type in has_limbs)
		var/obj/item/organ/external/E = H.organs_by_name[limb_type]
		if(E && (E.is_stump() || (E.status & (ORGAN_DESTROYED|ORGAN_DEAD|ORGAN_MUTATED))))
			E.removed()
			qdel(E)
			E = null
		if(!E)
			var/list/organ_data = has_limbs[limb_type]
			var/limb_path = organ_data["path"]
			var/obj/item/organ/O = new limb_path(H)
			organ_data["descriptor"] = O.name
			H << "<span class='notice'>You feel a slithering sensation as your [O.name] reforms.</span>"
			H.update_body()
			return 1

	// Heal remaining damage.
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		return 1

/datum/species/shapeshifter/promethean/get_blood_colour(var/mob/living/carbon/human/H)
	return (H ? rgb(H.r_skin, H.g_skin, H.b_skin) : ..())

/datum/species/shapeshifter/promethean/get_flesh_colour(var/mob/living/carbon/human/H)
	return (H ? rgb(H.r_skin, H.g_skin, H.b_skin) : ..())

/datum/species/shapeshifter/promethean/get_additional_examine_text(var/mob/living/carbon/human/H)

	if(!stored_shock_by_ref["\ref[H]"])
		return

	var/t_she = "She is"
	if(H.gender == MALE)
		t_she = "He is"
	else if(H.gender == PLURAL)
		t_she = "They are"
	else if(H.gender == NEUTER)
		t_she = "It is"

	switch(stored_shock_by_ref["\ref[H]"])
		if(1 to 10)
			return "[t_she] flickering gently with a little electrical activity."
		if(11 to 20)
			return "[t_she] glowing gently with moderate levels of electrical activity.\n"
		if(21 to 35)
			return "<span class='warning'>[t_she] glowing brightly with high levels of electrical activity.</span>"
		if(35 to INFINITY)
			return "<span class='danger'>[t_she] radiating massive levels of electrical activity!</span>"
