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
 * ELTPlayer
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Controllers
 * @version $wotgreal_dt: 02.02.2014 7:09:22 $
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

/**
 * Overwrite spectator behavior
 *
 * if this is an elite game (should be) and this PC is in the attacking team,
 * force him to watch the current-attacking controller and nothing else!
 *
 */
function ServerViewNextPlayer()
{
    local Controller Attacker;
	local ELTTeamGame Elite;

    Elite = ELTTeamGame(Level.Game);
    if ((Elite != None) && Elite.IsAttackingTeam(PlayerReplicationInfo.Team.TeamIndex))
    {
        // view current attack only!!
        Attacker = Elite.GetCurrentAttacker();
        if (Attacker != None) {
            SetViewTarget(Attacker);
            ClientSetViewTarget(Attacker);
            return;
        }
    }

    super.ServerViewNextPlayer();
}

/**
 * Do not allow to view from self (free cam over the entire map) in spec.
 */
function ServerViewSelf()
{
    if ( (ELTTeamGame(Level.Game) != None) && bIsPlayer ) {
        ServerViewNextPlayer();
    }
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
