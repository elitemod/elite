/**
 * This file is part of the "Elite" gametype modification for UT2004
 *
 * Copyright (C) 2012, m3nt0r <m3nt0r@elitemod.info>
 * http://elitemod.info
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * ELTPlayerReplication
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 22/12/2012 5:52:53 PM$
 */
class ELTPlayerReplication extends PlayerReplicationInfo;

var int TeamPosition;

replication
{
    reliable if( bNetDirty && (Role == ROLE_Authority) ) // Variables the server should send to the client.
        TeamPosition;
}

simulated function string GetLocationName()
{
    if(bOutOfLives && !bOnlySpectator)
        return default.StringDead;

    return Super.GetLocationName();
}



DefaultProperties
{

}
