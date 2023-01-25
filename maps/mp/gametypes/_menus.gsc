#include maps\mp\_utility;
#include scripts\game\utility;

init()
{
	if ( !isDefined( game["gamestarted"] ) )
	{
		game["menu_team"] = "team_marinesopfor";
		game["menu_customize"] = "customization";
		game["menu_primary"] = "primary";
		game["menu_primary2"] = "primary2";
		game["menu_secondary"] = "secondary";
		game["menu_secondary2"] = "secondary2";

		if ( !level.console )
		{
			game["menu_muteplayer"] = "muteplayer";
			precacheMenu( game["menu_muteplayer"] );
		}
		else
		{
			game["menu_leavegame"] = "popup_leavegame";
			precacheMenu( game["menu_leavegame"] );
		}

		precacheMenu( "scoreboard" );
		precacheMenu( game["menu_team"] );
		precacheMenu( game["menu_customize"] );
		precacheMenu( game["menu_primary"] );
		precacheMenu( game["menu_primary2"] );
		precacheMenu( game["menu_secondary"] );
		precacheMenu( game["menu_secondary2"] );

		precacheString( &"MP_HOST_ENDED_GAME" );
		precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	}

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread onMenuResponse();
	}
}

isOptionsMenu( menu )
{
	if ( menu == game["menu_changeclass"] )
		return true;

	if ( menu == game["menu_team"] )
		return true;

	if ( menu == game["menu_controls"] )
		return true;

	if ( isSubStr( menu, "pc_options" ) )
		return true;

	return false;
}


onMenuResponse()
{
	self endon( "disconnect" );

	for (;;)
	{
		self waittill( "menuresponse", menu, response );

		if ( response == "back" )
		{
			self closepopupMenu();
			self closeInGameMenu();

			if ( isOptionsMenu( menu ) )
			{
				if ( self.pers["team"] == "allies" )
					self openpopupMenu( game["menu_class_allies"] );
				if ( self.pers["team"] == "axis" )
					self openpopupMenu( game["menu_class_axis"] );
			}
			continue;
		}

		if ( response == "changeteam" )
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu( game["menu_team"] );
		}

		if ( response == "changeclass_marines" )
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu( game["menu_changeclass_allies"] );
			continue;
		}

		if ( response == "changeclass_opfor" )
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu( game["menu_changeclass_axis"] );
			continue;
		}

		if ( response == "changeclass_marines_splitscreen" )
			self openpopupMenu( "changeclass_marines_splitscreen" );

		if ( response == "changeclass_opfor_splitscreen" )
			self openpopupMenu( "changeclass_opfor_splitscreen" );

		if ( response == "endgame" )
		{
			if ( level.splitscreen )
			{
				endparty();

				if ( !level.gameEnded )
				{
					level thread maps\mp\gametypes\_gamelogic::forceEnd();
				}
			}

			continue;
		}

		if ( response == "endround" )
		{
			if ( !level.gameEnded )
			{
				level thread maps\mp\gametypes\_gamelogic::forceEnd();
			}
			else
			{
				self closepopupMenu();
				self closeInGameMenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}
			continue;
		}

		if ( menu == game["menu_team"] )
		{
			switch ( response )
			{
				case "allies":
					self [[level.allies]] ();
					break;

				case "axis":
					self [[level.axis]] ();
					break;

				case "autoassign":
					self [[level.autoassign]] ();
					break;

				case "spectator":
					self [[level.spectator]] ();
					break;
			}
		}	// the only responses remain are change class events
		else if ( menu == game["menu_primary"] || menu == game["menu_primary2"] )
		{
			id = int( response ) - 1;
			primary = level.snipers[id]["item"];
			self setStats( "primary", id );

			if ( isAlive( self ) )
			{
				self takeWeapon( self.pers["sniper_primary"] );
				self giveWeapon( primary );
				self giveMaxAmmo( primary );
				self switchToWeapon( primary );
				self.pers["sniper_primary"] = primary;
			}
		}
		else if ( menu == game["menu_secondary"] || menu == game["menu_secondary2"] )
		{
			id = int( response ) - 1;
			secondary = level.snipers[id]["item"];
			self setStats( "secondary", id );

			if ( isAlive( self ) )
			{
				self takeWeapon( self.pers["sniper_secondary"] );
				self giveWeapon( secondary );
				self giveMaxAmmo( secondary );
				self switchToWeapon( secondary );
				self.pers["sniper_secondary"] = secondary;
			}
		}
		else if ( !level.console )
		{
			if ( menu == game["menu_quickcommands"] )
				maps\mp\gametypes\_quickmessages::quickcommands( response );
			else if ( menu == game["menu_quickstatements"] )
				maps\mp\gametypes\_quickmessages::quickstatements( response );
			else if ( menu == game["menu_quickresponses"] )
				maps\mp\gametypes\_quickmessages::quickresponses( response );
		}
	}
}


getTeamAssignment()
{
	teams[0] = "allies";
	teams[1] = "axis";

	if ( !level.teamBased )
		return teams[randomInt( 2 )];

	if ( self.sessionteam != "none" && self.sessionteam != "spectator" && self.sessionstate != "playing" && self.sessionstate != "dead" )
	{
		assignment = self.sessionteam;
	}
	else
	{
		playerCounts = self maps\mp\gametypes\_teams::CountPlayers();

		// if teams are equal return the team with the lowest score
		if ( playerCounts["allies"] == playerCounts["axis"] )
		{
			if ( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
				assignment = teams[randomInt( 2 )];
			else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
				assignment = "allies";
			else
				assignment = "axis";
		}
		else if ( playerCounts["allies"] < playerCounts["axis"] )
		{
			assignment = "allies";
		}
		else
		{
			assignment = "axis";
		}
	}

	return assignment;
}


menuAutoAssign()
{
	self closeMenus();

	assignment = getTeamAssignment();

	if ( isDefined( self.pers["team"] ) && ( self.sessionstate == "playing" || self.sessionstate == "dead" ) )
	{
		if ( assignment == self.pers["team"] )
		{
			self beginClassChoice();
			return;
		}
		else
		{
			self.switching_teams = true;
			self.joining_team = assignment;
			self.leaving_team = self.pers["team"];
			self suicide();
		}
	}

	self addToTeam( assignment );
	self.pers["class"] = undefined;
	self.class = undefined;

	if ( !isAlive( self ) )
		self.statusicon = "hud_status_dead";

	self notify( "end_respawn" );

	self beginClassChoice();
}


beginClassChoice( forceNewChoice )
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];

	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.

	//	if game mode allows class choice
	// if ( allowClassChoice() )
		// self openpopupMenu( game["menu_changeclass_" + team] );
	// else
		self thread bypassClassChoice();

	if ( !isAlive( self ) )
		self thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( 0.1 );
}


//	JDS TODO: this will become a level.onClassChoice so private matches can override class selection
bypassClassChoice()
{
	self.selectedClass = true;
	self [[level.class]] ( "class0" );
}

beginTeamChoice()
{
	self openpopupMenu( game["menu_team"] );
}

showMainMenuForTeam()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];

	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.	
	self openpopupMenu( game["menu_class_" + team] );
}

menuAllies()
{
	self closeMenus();

	if ( self.pers["team"] != "allies" )
	{
		if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
		{
			self openpopupMenu( game["menu_team"] );
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && !self.hasDoneCombat )
			self.hasSpawned = false;

		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		self addToTeam( "allies" );
		self.pers["class"] = undefined;
		self.class = undefined;

		self notify( "end_respawn" );
	}

	self beginClassChoice();
}


menuAxis()
{
	self closeMenus();

	if ( self.pers["team"] != "axis" )
	{
		if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "axis" ) )
		{
			self openpopupMenu( game["menu_team"] );
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && !self.hasDoneCombat )
			self.hasSpawned = false;

		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		self addToTeam( "axis" );
		self.pers["class"] = undefined;
		self.class = undefined;

		self notify( "end_respawn" );
	}

	self beginClassChoice();
}


menuSpectator()
{
	self closeMenus();

	if ( isDefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
		return;

	if ( isAlive( self ) )
	{
		assert( isDefined( self.pers["team"] ) );
		self.switching_teams = true;
		self.joining_team = "spectator";
		self.leaving_team = self.pers["team"];
		self suicide();
	}

	self addToTeam( "spectator" );
	self.pers["class"] = undefined;
	self.class = undefined;

	self thread maps\mp\gametypes\_playerlogic::spawnSpectator();
}


menuClass( response )
{
	self closeMenus();

	// clear new status of unlocked classes
	if ( response == "demolitions_mp,0" && self getPlayerData( "featureNew", "demolitions" ) )
	{
		self setPlayerData( "featureNew", "demolitions", false );
	}
	if ( response == "sniper_mp,0" && self getPlayerData( "featureNew", "sniper" ) )
	{
		self setPlayerData( "featureNew", "sniper", false );
	}

	// this should probably be an assert
	if ( !isDefined( self.pers["team"] ) || ( self.pers["team"] != "allies" && self.pers["team"] != "axis" ) )
		return;

	class = self maps\mp\gametypes\_class::getClassChoice( response );
	primary = self maps\mp\gametypes\_class::getWeaponChoice( response );

	if ( class == "restricted" )
	{
		self beginClassChoice();
		return;
	}

	if ( ( isDefined( self.pers["class"] ) && self.pers["class"] == class ) &&
		( isDefined( self.pers["primary"] ) && self.pers["primary"] == primary ) )
		return;

	if ( self.sessionstate == "playing" )
	{
		// if last class is already set then we don't want an undefined class to replace it
		if ( IsDefined( self.pers["lastClass"] ) && IsDefined( self.pers["class"] ) )
		{
			self.pers["lastClass"] = self.pers["class"];
			self.lastClass = self.pers["lastClass"];
		}

		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( level.inGracePeriod && !self.hasDoneCombat ) // used weapons check?
		{
			self maps\mp\gametypes\_class::setClass( self.pers["class"] );
			self.tag_stowed_back = undefined;
			self.tag_stowed_hip = undefined;
			self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
		}
		else
		{
			self iPrintLnBold( game["strings"]["change_class"] );
		}
	}
	else
	{
		// if last class is already set then we don't want an undefined class to replace it
		if ( IsDefined( self.pers["lastClass"] ) && IsDefined( self.pers["class"] ) )
		{
			self.pers["lastClass"] = self.pers["class"];
			self.lastClass = self.pers["lastClass"];
		}

		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" && !isInKillcam() )
			self thread maps\mp\gametypes\_playerlogic::spawnClient();
	}

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}



addToTeam( team, firstConnect )
{
	// UTS update playerCount remove from team
	if ( isDefined( self.team ) )
		self maps\mp\gametypes\_playerlogic::removeFromTeamCount();

	self.pers["team"] = team;
	// this is the only place self.team should ever be set
	self.team = team;

	// session team is readonly in ranked matches on console
	if ( !matchMakingGame() || isDefined( self.pers["isBot"] ) || !allowTeamChoice() )
	{
		if ( level.teamBased )
		{
			self.sessionteam = team;
		}
		else
		{
			if ( team == "spectator" )
				self.sessionteam = "spectator";
			else
				self.sessionteam = "none";
		}
	}

	// UTS update playerCount add to team
	if ( game["state"] != "postgame" )
		self maps\mp\gametypes\_playerlogic::addToTeamCount();

	self updateObjectiveText();

	// give "joined_team" and "joined_spectators" handlers a chance to start
	// these are generally triggered from the "connected" notify, which can happen on the same
	// frame as these notifies
	if ( isDefined( firstConnect ) && firstConnect )
		waittillframeend;

	// self updateMainMenu();
	self setClientDvar( "g_scriptMainMenu", game["menu_team"] );

	if ( team == "spectator" )
	{
		self notify( "joined_spectators" );
		level notify( "joined_team" );
	}
	else
	{
		self notify( "joined_team" );
		level notify( "joined_team" );
	}
}
