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

watchClipSize()
{
    for (;;)
    {
        self waittill( "weapon_fired" );
        weapon = self GetCurrentWeapon();
        clip = self getWeaponAmmoClip( weapon );

        if ( clip == 0 )
            self giveMaxAmmo( weapon );
    }
}