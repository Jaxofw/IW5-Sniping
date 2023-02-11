#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\game\utility;

init()
{
    replacefunc( maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone, ::finalKillcamHook );
    replaceFunc( maps\mp\gametypes\_rank::getScoreInfoValue, ::getScoreInfoValue );
    replaceFunc( maps\mp\gametypes\_rank::xpPointsPopup, ::xpPointsPopup );

    preCacheModel( "mp_body_ally_ghillie_desert_sniper" );
    preCacheModel( "head_opforce_russian_urban_sniper" );
    preCacheModel( "viewhands_iw5_ghillie_desert" );

    level.motd = "Welcome to Arcane Sniping ^2IW5!             ^7Join our ^5Discord ^7at ^5discord.gg/ArcaneNW ^7Have Fun and Enjoy your Stay!";

    setDvar( "player_sprintUnlimited", true );

    if ( getDvar( "g_gametype" ) == "dm" )
        setDvar( "scr_dm_scorelimit", 700 ); // 70
    else if ( getDvar( "g_gametype" ) == "war" )
        setDvar( "scr_war_scorelimit", 1000 ); // 100

    thread buildSniperTable();
    thread scripts\game\mapvote::init();
    level thread onPlayerConnect();

    saveAllStats();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player setClientDvars(
            "motd", level.motd,
            "ui_menu_playername", player.name
        );

        if ( player.name.size > 8 )
            player setClientDvar( "ui_menu_playername", getSubStr( player.name, 0, 7 ) + "..." );

        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    for (;;)
    {
        self waittill( "spawned_player" );
        self giveLoadout();
        self setAsGhillie();
        self thread watchClipSize();
    }
}

giveLoadout()
{
    primary = self getStats( "primary" );
    secondary = self getStats( "secondary" );

    self.pers["sniper_primary"] = level.snipers[primary]["item"];
    self.pers["sniper_secondary"] = level.snipers[secondary]["item"];

    self takeAllWeapons();
    self giveWeapon( self.pers["sniper_primary"] );
    self giveMaxAmmo( self.pers["sniper_primary"] );
    self giveWeapon( self.pers["sniper_secondary"] );
    self giveMaxAmmo( self.pers["sniper_secondary"] );
    self setSpawnWeapon( self.pers["sniper_primary"] );

    self givePerks();
}

givePerks()
{
    self clearPerks();
    self givePerk( "specialty_fastreload", false );
    self givePerk( "specialty_quickswap", true );
    self givePerk( "specialty_quickdraw", false );
    self givePerk( "specialty_fastoffhand", true );
    self givePerk( "specialty_bulletaccuracy", false );
    self givePerk( "specialty_fastsprintrecovery", true );
    self givePerk( "throwingknife_mp", true );
}

watchClipSize()
{
    for (;;)
    {
        self waittill_any( "reload" );
        self giveMaxAmmo( self getCurrentWeapon() );
    }
}

finalKillcamHook()
{
    players = getAllPlayers();

    if ( !isDefined( level.finalkillcam_winner ) )
    {
        for ( i = 0; i < players.size; i++ )
            players[i] thread scripts\game\mapvote::playerLogic();
    }
    else
    {
        level waittill( "final_killcam_done" );
        for ( i = 0; i < players.size; i++ )
            players[i] thread scripts\game\mapvote::playerLogic();
    }

    scripts\game\mapvote::mapVoteLogic();
}

setAsGhillie()
{
    self detachAll();
    [[ game[self.pers["team"] + "_model"]["GHILLIE"] ]]();
}

xpPointsPopup( amount, bonus, hudColor, glowAlpha )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
 
	if ( amount == 0 )
		return;
 
	self notify( "xpPointsPopup" );
	self endon( "xpPointsPopup" );
 
	self.xpUpdateTotal += amount;
	self.bonusUpdateTotal += bonus;
 
	wait ( 0.05 );
 
	if ( self.xpUpdateTotal < 0 )
		self.hud_xpPointsPopup.label = &"";
	else
		self.hud_xpPointsPopup.label = &"MP_PLUS";
 
	self.hud_xpPointsPopup.color = hudColor;
	self.hud_xpPointsPopup.glowColor = hudColor;
	self.hud_xpPointsPopup.glowAlpha = glowAlpha;
 
	self.hud_xpPointsPopup setValue(self.xpUpdateTotal);
	self.hud_xpPointsPopup.alpha = 0.85;
	self.hud_xpPointsPopup thread maps\mp\gametypes\_hud::fontPulse( self );
 
	increment = max( int( self.bonusUpdateTotal / 20 ), 1 );
 
	if ( self.bonusUpdateTotal )
	{
		while ( self.bonusUpdateTotal > 0 )
		{
			self.xpUpdateTotal += min( self.bonusUpdateTotal, increment );
			self.bonusUpdateTotal -= min( self.bonusUpdateTotal, increment );
 
			self.hud_xpPointsPopup setValue( self.xpUpdateTotal );
 
			wait ( 0.05 );
		}
	}	
	else
	{
		wait ( 1.5 );
	}
 
	self.hud_xpPointsPopup fadeOverTime( 0.75 );
	self.hud_xpPointsPopup.alpha = 0;
 
	self.xpUpdateTotal = 0;		
}