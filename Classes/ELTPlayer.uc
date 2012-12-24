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
 * ELTPlayer
 *
 * Custom PlayerController to provide correct PRI
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 8:30:52 PM$
 */
class ELTPlayer extends xPlayer;

/**
 * Suicide()
 * End round if the Player is the current attacker.
 */
exec function Suicide() {
    super.Suicide();

    if ( ELTGame(Level.Game) == None )
        return;

    if ( ELTGame(Level.Game).GetCurrentAttacker() == self ) {
        ELTGame(Level.Game).EndRound(ERER_AttackerDead, Pawn, "attacker_suicided");
    }
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
     PlayerReplicationInfoClass=Class'EliteMod.ELTPlayerReplication'
}
