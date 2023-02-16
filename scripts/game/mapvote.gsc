#include scripts\game\utility;

init()
{
    level.maps = [];
    level.mapsVotable = [];
    level.mapsInVote = 10;
    level.voteDuration = 15;

    level.maps[level.maps.size] = "mp_dome";
    level.maps[level.maps.size] = "mp_geometric";
    level.maps[level.maps.size] = "mp_nuked";
    level.maps[level.maps.size] = "mp_showdown_sh";
    level.maps[level.maps.size] = "mp_vacant";

    if ( getDvar( "g_gametype" ) == "dm" )
    {
        level.maps[level.maps.size] = "mp_courtyard_ss";
        level.maps[level.maps.size] = "mp_rust";
        level.maps[level.maps.size] = "mp_shipment";
        level.maps[level.maps.size] = "mp_killhouse";
        level.maps[level.maps.size] = "mp_poolday";
        level.maps[level.maps.size] = "mp_poolparty";
    }
    else
    {
        level.maps[level.maps.size] = "mp_bo2frost";
        level.maps[level.maps.size] = "mp_bo2grind";
        level.maps[level.maps.size] = "mp_bo2paintball";
        level.maps[level.maps.size] = "mp_bog";
        level.maps[level.maps.size] = "mp_cargoship";
        level.maps[level.maps.size] = "mp_countdown";
        level.maps[level.maps.size] = "mp_crash";
        level.maps[level.maps.size] = "mp_crossfire";
        level.maps[level.maps.size] = "mp_firingrange";
        level.maps[level.maps.size] = "mp_raid";
    }
}

mapVoteLogic()
{
    for ( i = 0; i < level.mapsInVote; i++ )
        getRandomMap();

    players = getAllPlayers();
    for ( i = level.voteDuration; i >= 0; i-- )
    {
        for ( j = 0; j < players.size; j++ )
            players[j] setClientDvar( "ui_mapvote_countdown", i + " Seconds" );

        wait 1;
    } 

    changeToWinningMap();
}

playerLogic()
{
    self endon( "disconnect" );

    self openpopupMenu( game["menu_mapvote"] );

    self.vote = -1;

    for (;;)
    {
        self waittill( "menuresponse", menu, response );

        if ( menu == game["menu_mapvote"] )
        {
            mapId = int( response );

            if ( mapId == self.vote )
                continue;

            players = getAllPlayers();

            if ( self.vote != -1 )
            {
                level.mapsVotable[self.vote]["votes"]--;
                self setClientDvar( "mapvote_option_" + self.vote + "_selected", false );

                for ( i = 0; i < players.size; i++ )
                    players[i] setClientDvar( "mapvote_option_" + self.vote + "_votes", level.mapsVotable[self.vote]["votes"] );
            }

            self.vote = mapId;
            level.mapsVotable[mapId]["votes"]++;
            self setClientDvar( "mapvote_option_" + self.vote + "_selected", true );

            for ( i = 0; i < players.size; i++ )
                players[i] setClientDvar( "mapvote_option_" + mapId + "_votes", level.mapsVotable[mapId]["votes"] );
        }
    }
}

isMapinVotes( mapName )
{
    for ( i = 0; i < level.mapsVotable.size; i++ )
        if ( mapName == level.mapsVotable[i]["name"] )
            return true;

    return false;
}

changeToWinningMap()
{
    topVote = level.mapsVotable[0];
    players = getAllPlayers();

    for ( i = 0; i < level.mapsVotable.size; i++ )
    {
        if ( level.mapsVotable[i]["votes"] > topVote["votes"] )
        {
            topVote = level.mapsVotable[i];
            for ( j = 0; j < players.size; j++ )
                players[j] setClientDvar( "mapvote_option_" + i + "_winner", true );
        }
    }

    wait 2;

    for ( i = 0; i < players.size; i++ )
    {
        players[i] closeMenu( game["menu_mapvote"] );
        players[i] closeInGameMenu( game["menu_mapvote"] );
    }

    iPrintLnBold( "Changing map to ^5" + formatMapName( topVote["name"] ) );

    wait 4;

    setDvar( "sv_maprotationcurrent", "map " + topVote["name"] );
    exitLevel( false );
}

getRandomMap()
{
    id = level.mapsVotable.size;
    randomMap = "";

    if ( ( id + 1 ) == level.mapsInVote )
        randomMap = level.script;
    else
    {
        while ( randomMap == "" || randomMap == level.script || isMapinVotes( randomMap ) )
            randomMap = level.maps[randomInt( level.maps.size )];
    }

    level.mapsVotable[id]["name"] = randomMap;
    level.mapsVotable[id]["votes"] = 0;

    players = getAllPlayers();
    for ( i = 0; i < players.size; i++ )
    {
        players[i] setClientDvars(
            "mapvote_option_" + id, randomMap,
            "mapvote_option_" + id + "_label", formatMapName( level.mapsVotable[id]["name"] ),
            "mapvote_option_" + id + "_votes", level.mapsVotable[id]["votes"],
            "mapvote_option_" + id + "_selected", false,
            "mapvote_option_" + id + "_winner", false
        );
    }
}