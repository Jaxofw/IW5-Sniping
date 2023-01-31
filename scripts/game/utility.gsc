setStats( what, value )
{
	_setClientDvar( self, what, value );
}

getStats( what, type )
{
	if ( !isDefined( type ) )
		type = "int";

	stat = _getClientDvar( self, what, type );
	if ( !isDefined( stat ) )
		stat = 0;

	return stat;
}

_setClientDvar( player, dvar, dvar_value )
{
	cvarstring = "";

	cvar = "cvar_" + player getGuid();

	if ( isDefined( getDvar( cvar ) ) )
		cvarstring = getDvar( cvar );

	valuearray = strTok( cvarstring, ";" );
	cvarstring = "";

	foreach( value in valuearray )
	{
		if ( !isSubStr( value, dvar ) )
			cvarstring += value + ";";
	}

	if ( isDefined( dvar_value ) )
		cvarstring += dvar + "=" + dvar_value + ";";

	valuearray = undefined;
	setDvar( cvar, cvarstring );
}

_getClientDvar( player, dvar, type )
{
	cvar = "cvar_" + player getGuid();

	if ( !isDefined( getDvar( cvar ) ) )
		return undefined;

	cvarvalue = getDvar( cvar );
	values = strTok( cvarvalue, ";" );

	foreach( value in values )
	{
		if ( isSubStr( value, dvar ) )
		{
			string_value = getSubStr( value, _getIndexOf( value, "=", 0 ) + 1, value.size );

			if ( type == "int" )
			{
				return int( string_value );
			}
			else if ( type == "string" )
			{
				return string_value;
			}
			else if ( type == "float" )
			{
				setDvar( "float", string_value );
				return getDvarFloat( "float" );
			}
		}
	}

	values = undefined;
	return undefined;
}

_getIndexOf( string, value, startingIndex )
{
	index = startingIndex;
	while ( index <= string.size - value.size - 1 )
	{
		if ( !isDefined( string[index + value.size - 1] ) )
			return -1;

		if ( getSubStr( string, index, index + value.size ) == value )
			return index;
		else
			index++;
	}

	return -1;
}

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

formatMapName( map )
{
	formattedName = "";
	index = 3;

	if ( map == "mp_courtyard_ss" )
		return "Erosion";
	else if ( map == "mp_nuked" )
		return "Nuketown";
	else if ( map == "mp_showdown_sh" )
		return "Showdown";

	for ( j = index; j < map.size; j++ )
	{
		if ( j == index )
			formattedName += toUpper( map[j] );
		else
		{
			if ( foundUnderscore( map[j] ) )
			{
				formattedName += " " + toUpper( map[j + 1] );
				j++;
			}
			else formattedName += map[j];
		}
	}

	return formattedName;
}

toUpper( letter )
{
	switch ( letter )
	{
		case "a":
			return "A";
		case "b":
			return "B";
		case "c":
			return "C";
		case "d":
			return "D";
		case "e":
			return "E";
		case "f":
			return "F";
		case "g":
			return "G";
		case "h":
			return "H";
		case "i":
			return "I";
		case "j":
			return "J";
		case "k":
			return "K";
		case "l":
			return "L";
		case "m":
			return "M";
		case "n":
			return "N";
		case "o":
			return "O";
		case "p":
			return "P";
		case "q":
			return "Q";
		case "r":
			return "R";
		case "s":
			return "S";
		case "t":
			return "T";
		case "u":
			return "U";
		case "v":
			return "V";
		case "w":
			return "W";
		case "x":
			return "X";
		case "y":
			return "Y";
		case "z":
			return "Z";
		default:
			return letter;
	}
}

foundUnderscore( letter )
{
	switch ( letter )
	{
		case "_":
			return true;
		default:
			return false;
	}
}

saveAllStats()
{
	level waittill( "game over" );

	logPrint( "\n===== BEGIN STATS =====\n" +
		"set an_stats " + "\"" + getDvar( "an_stats" ) + "\"" +
		"set an_primary " + "\"" + getDvar( "an_primary" ) + "\"" +
		"set an_secondary " + "\"" + getDvar( "an_secondary" ) + "\"" +
		"\n===== END STATS =====\n" );
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

getScoreInfoValue( type )
{
	switch ( type )
	{
		case "assist":
			if ( level.teambased )
				return 2;
		case "headshot":
		case "kill":
			if ( level.teambased )
				return 10;
			else
				return 5;
		default:
			return level.scoreInfo[type]["value"];
	}
}