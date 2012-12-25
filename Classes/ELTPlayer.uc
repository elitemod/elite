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
 * @author m3nt0r
 * @package Elite
 * @subpackage Controllers
 * @version $wotgreal_dt: 25/12/2012 1:13:34 PM$
 */
class ELTPlayer extends xPlayer;

// ============================================================================
// Implementation
// ============================================================================

/**
 * Suicide()
 * End round if the Player is the current attacker.
 */
function SetPawnClass(string inClass, string inCharacter)
{
    if ( inClass != "" ) {
        inClass = "EliteMod.ELTPawn";
    }
    super.SetPawnClass(inClass, inCharacter);
}

/**
 * Suicide()
 *
 * While testing i noticed suicides aren't picked up properly if i am attacking.
 * So here we go an end the round if one feels suicidal
 */
exec function Suicide() {
    super.Suicide();

    if ( ELTGame(Level.Game) == None )
        return;

    if ( ELTGame(Level.Game).GetCurrentAttacker() == self )
        ELTGame(Level.Game).EndRound(ERER_AttackerDead, Pawn, "attacker_suicided");
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    PlayerReplicationInfoClass=class'EliteMod.ELTPlayerReplication'
    PawnClass=class'EliteMod.ELTPawn'
    bAdrenalineEnabled=False
}
