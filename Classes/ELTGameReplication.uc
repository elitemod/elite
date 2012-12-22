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
 * ELTGameReplication
 *
 * Replication Game Settings and Progress.
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 22/12/2012 4:07:03 PM$
 */
class ELTGameReplication extends GameReplicationInfo;

var int CurrentAttackingTeam;

replication
{
    reliable if( bNetDirty && (Role == ROLE_Authority) ) // Variables the server should send to the client.
        CurrentAttackingTeam;
}

DefaultProperties
{

}
