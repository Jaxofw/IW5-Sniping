#include maps\mp\_utility;
#include scripts\game\utility;

init()
{
    setDvar( "player_sprintUnlimited", true );

    level.motd = "Welcome to Arcane Sniping ^2IW5!             ^7Join our ^5Discord ^7at ^5discord.gg/ArcaneNW ^7Have Fun and Enjoy your Stay!";

    thread buildSniperTable();
    level thread onPlayerConnect();

    level waittill( "game over" );
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
        self giveWeapons();
        self givePerks();
        self thread watchClipSize();
    }
}

buildSniperTable()
{
    level.snipers = [];
    table = "mp/sniperTable.csv";

    for ( idx = 1; isDefined( tableLookup( table, 0, idx, 0 ) ) && tableLookup( table, 0, idx, 0 ) != ""; idx++ )
    {
        id = int( tableLookup( table, 0, idx, 1 ) );
        level.snipers[id]["item"] = "iw5_" + tableLookup( table, 0, idx, 2 );
        level.snipers[id]["name"] = tableLookup( table, 0, idx, 3 );
        preCacheItem( level.snipers[id]["item"] );
    }
}

giveWeapons()
{
    primary = self getStats( "primary" );
    secondary = self getStats( "secondary" );

    self.pers["sniper_primary"] = level.snipers[primary]["item"];
    self.pers["sniper_secondary"] = level.snipers[secondary]["item"];

    self takeAllWeapons();
    wait .05;
    self giveWeapon( self.pers["sniper_primary"] );
    self giveMaxAmmo( self.pers["sniper_primary"] );
    self giveWeapon( self.pers["sniper_secondary"] );
    self giveMaxAmmo( self.pers["sniper_secondary"] );
    self switchToWeapon( self.pers["sniper_primary"] );
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

saveAllStats()
{
    logPrint( "\n===== BEGIN STATS =====\n" +
        "set an_stats " + "\"" + getDvar( "an_stats" ) + "\"" +
        "set an_primary " + "\"" + getDvar( "an_primary" ) + "\"" +
        "set an_secondary " + "\"" + getDvar( "an_secondary" ) + "\"" +
        "\n===== END STATS =====\n" );
}