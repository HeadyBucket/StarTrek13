SUBSYSTEM_DEF(faction)
	name = "Faction"
	wait = 10

	flags = SS_KEEP_TIMING

	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	var/datum/faction/factions = list() //All factions that are currently in the game
	var/jumpgates_forbidden = TRUE //Lock jumpgates to prevent instarushes.
	var/timing_jumpgates = FALSE //Jumpgate countdown begun?
	var/mob/living/vips = list() //People involved in vip objectives
	var/mob/living/lovers = list() //people involved in VIP objectives as the VIPs lover
	var/datum/borg_hivemind/borg_hivemind


/datum/controller/subsystem/faction/Initialize(timeofday)
	borg_hivemind = new
	if(!factions)
		WARNING("No factions have been created!")
	for(var/F in subtypesof(/datum/faction))
		var/datum/faction/thefaction = F
		var/datum/faction/instance = new thefaction
		factions += instance
		message_admins("DEBUG: [instance] was created")
	. = ..()

/datum/controller/subsystem/faction/fire()
	if(SSticker.current_state > GAME_STATE_PREGAME) //Round started. Now begin the countdown to allow jumpgates.
		if(!timing_jumpgates)
			addtimer(CALLBACK(src, .proc/announce_jumpgates), 200)
			timing_jumpgates = TRUE
	if(factions)
		return
	else
		WARNING("There are no factions in the game!")

/datum/controller/subsystem/faction/proc/addToFaction(mob/living/M)
	var/datum/faction/thefaction = M.client.prefs.player_faction
	if(!M.client.prefs.player_faction)
		thefaction = pick(factions)
	thefaction.addMember(M)


/datum/controller/subsystem/faction/proc/announce_jumpgates()
	priority_announce("Severe subspace distortions detected, we expect them to pass in 5 minutes.", "Incoming Priority Message", 'StarTrek13/sound/trek/ship_effects/bosun.ogg')
	addtimer(CALLBACK(src, .proc/announce_jumpgates_soon), 2000)


/datum/controller/subsystem/faction/proc/announce_jumpgates_soon()
	priority_announce("The subspace distortions have decreased, all pilots should prepare for cross system travel.", "Incoming Priority Message", 'StarTrek13/sound/trek/ship_effects/bosun.ogg')
	addtimer(CALLBACK(src, .proc/allow_jumpgates), 1000)

/datum/controller/subsystem/faction/proc/allow_jumpgates()
	priority_announce("Subspace distortions have passed, you may now warp safely.", "Incoming Priority Message", 'StarTrek13/sound/trek/ship_effects/bosun.ogg')
	jumpgates_forbidden = FALSE
	flags |= SS_NO_FIRE //we no longer need to fire, and this may(?) prevent a bug
	can_fire = FALSE