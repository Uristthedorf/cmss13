/obj/item/reagent_container/food/snacks/breadslice/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W,/obj/item/shard) || istype(W,/obj/item/reagent_container/food/snacks))
		var/obj/item/reagent_container/food/snacks/csandwich/S = new(get_turf(src))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/reagent_container/food/snacks/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."
	icon_state = "breadslice"
	icon = 'icons/obj/items/food/bread.dmi'
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

/obj/item/reagent_container/food/snacks/csandwich/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/reagent_container/food/snacks/csandwich))
		//No sandwitch inception, it causes some bugs...
		to_chat(user, SPAN_NOTICE("You can't put \a [W] in [src]."))
		return

	var/sandwich_limit = 4
	for(var/obj/item/O in ingredients)
		if(istype(O,/obj/item/reagent_container/food/snacks/breadslice))
			sandwich_limit += 4

	if(length(src.contents) > sandwich_limit)
		to_chat(user, SPAN_DANGER("If you put anything else on \the [src] it's going to collapse."))
		return
	if(length(src.contents) >= 15)
		to_chat(user, SPAN_DANGER("\The [src] is already massive! You can't add more without ruining it."))
		return
	else if(istype(W,/obj/item/shard))
		to_chat(user, SPAN_NOTICE(" You hide [W] in \the [src]."))
		user.drop_inv_item_to_loc(W, src)
		update()
		return
	else if(istype(W,/obj/item/reagent_container/food/snacks))
		to_chat(user, SPAN_NOTICE(" You layer [W] over \the [src]."))
		var/obj/item/reagent_container/F = W
		if(F.reagents)
			F.reagents.trans_to(src, F.reagents.total_volume)
		user.drop_inv_item_to_loc(W, src)
		ingredients += W
		update()
		return
	..()

/obj/item/reagent_container/food/snacks/csandwich/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/reagent_container/food/snacks/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == length(ingredients))
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		var/image/I = new(src.icon, "sandwich_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		overlays += I

	var/image/T = new(src.icon, "sandwich_top")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (length(ingredients) * 2)+1
	overlays += T

	name = lowertext("[fullname] sandwich")
	if(length(name) > 80)
		name = "[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich"
	w_class = ceil(clamp((length(ingredients)/2),1,3))

/obj/item/reagent_container/food/snacks/csandwich/Destroy()
	QDEL_NULL_LIST(ingredients)
	. = ..()

/obj/item/reagent_container/food/snacks/csandwich/get_examine_text(mob/user)
	. = ..()
	if(LAZYLEN(contents))
		var/obj/item/O = pick(contents)
		. += SPAN_NOTICE("You think you can see [O.name] in there.")

/obj/item/reagent_container/food/snacks/csandwich/attack(mob/M as mob, mob/user as mob)

	var/obj/item/shard
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/shard))
			shard = O
			break

	var/mob/living/H
	if(istype(M,/mob/living))
		H = M

	if(H && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		to_chat(H, SPAN_DANGER("You lacerate your mouth on a [shard.name] in the sandwich!"))
		H.apply_damage(5, BRUTE)
	..()
