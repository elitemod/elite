/**
 * This file is part of the "Elite" gametype modification for UT2004
 *
 * Copyright (C) 2012-2014, m3nt0r <m3nt0r.de@gmail.com>
 * http://elite2k4.wordpress.com/
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
 *
 * Checks if the player start is appropiate for the controller, given the
 * state of CurrentAttackingTeam in GRI and his team affiliation.
 *
 * ==== MAPPER WARNING ====
 * Although mappers could use this item directly, it is recommened to not
 * place it into their levels, as they would bind themselve to this package.
 * Please use "PlayerSpawnManager" available in "Actors -> Info". The mod
 * will figure out what to do.
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 5:05:57 PM$
 */
class ELTPlayerSpawnManager extends PlayerSpawnManager;

// ============================================================================
// Implementation
// ============================================================================

/**
 * ApprovePlayerStart()
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

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    bNoDelete=false
}
