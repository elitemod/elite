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
 * ELTPlayerSpawnManager
 * Placeable Actor
 *
 * Although mappers could use this item directly, it is recommened to not
 * place it into their levels, as they would bind themselve to this package.
 *
 * Mappers should use the dummy actor provided in dummy package that does
 * not undergo default versioning (in other words: the filename will not change).
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 1:44:20 AM$
 */
class ELTPlayerSpawnManager extends PlayerSpawnManager;

/**
 * ApprovePlayerStart()
 *
 * Is the PlayerStart for the correct Player's Team ?
 */
singular function bool ApprovePlayerStart(PlayerStart P, byte Team, Controller Player)
{
    local bool bIsAttacker;

    // Are we dealing with the right PlayerSpawnManger?
    if ( P.TeamNumber != PlayerStartTeam )
        return false;

    if ( Level.Game.IsA('ELTTeamGame') )
    {
        bIsAttacker = ELTTeamGame(Level.Game).IsAttackingTeam(Team);

        if ( AssaultTeam == EPSM_Attackers ) {
            if ( !bIsAttacker )
                return false;
        }
        if ( AssaultTeam == EPSM_Defenders ) {
            if ( bIsAttacker )
                return false;
        }
    }

    return true;
}

DefaultProperties
{
    bNoDelete=false
}
