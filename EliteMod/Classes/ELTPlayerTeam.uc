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
 * ELTPlayerTeam
 *
 * Extension of the usual TeamInfo that manages a Players array
 * which holds a list of all Controllers currently in the Team.
 *
 * This information allows us to extract any player by index number.
 * We make use of it in "GetNextAttacker()"
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 02.02.2014 4:37:09 $
 */
class ELTPlayerTeam extends xTeamRoster;

// ============================================================================
// Variables
// ============================================================================

var Array<Controller> Players;
var int NextAttackerNum, NumPlayers;

// ============================================================================
// Replication
// ============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        Players, NextAttackerNum, NumPlayers;
}

// ============================================================================
// Implementation
// ============================================================================

/**
 * Convenience method: Check if NumPlayers is zero
 */
function bool IsEmpty()
{
    return (NumPlayers == 0);
}

/**
 * Check if at least one PRI of this team IS NOT out-of-lives.
 * Also returns false if the team is empty.
 */
function bool HasOneAlive()
{
    local int i;

    if ( IsEmpty() )
        return false;

    for (i = 0; i < Players.Length; i++) {
        if (Players[i] != none ) {
            if ( Players[i].PlayerReplicationInfo != none ) {
                if ( !Players[i].PlayerReplicationInfo.bOutOfLives ) {
                    return true;
                } // not outoflives
            } // has PRI
        } // has value
    } // end loop

    return false;
}

/**
 * AddToTeam(Other)
 *
 * Call parent method, and if successful, increase NumPlayers by 1 and
 * add Controller to our Players array.
 */
function bool AddToTeam( Controller Other )
{
    if ( super.AddToTeam(Other) ) {
        Players[Players.Length] = Other;
        NumPlayers++;
        return true;
    }
    return false;
}

/**
 * RemoveFromTeam(Other)
 *
 * Search the Players array for Controller.
 * Remove if found, call parent method and decrease NumPlayers by 1
 */
function RemoveFromTeam( Controller Other )
{
    local int i;

    for (i = 0; i < Players.Length; i++) {
        if ( Players[i] == Other ) {
            super.RemoveFromTeam(Other);
            Players.Remove(i, 1);
            NumPlayers--;
            break;
        }
    }
}

/**
 * Advance the internal attacker index by one, or reset
 * if end of array has been reached.
 */
function int GetNextAttacker()
{
    local int CurrentAttackerNum;

    if ( IsEmpty() ) {
        NextAttackerNum = 0;
        return -1;
    }

    if (NextAttackerNum >= Players.Length){
        NextAttackerNum = 0;
    }

    if ( Players[NextAttackerNum] != None ) {
        CurrentAttackerNum = NextAttackerNum;
        NextAttackerNum++;
    }

    return CurrentAttackerNum;
}

// ============================================================================
// Properties
// ============================================================================

defaultProperties
{
    NetUpdateFrequency=1
    DefaultPlayerClass=class'EliteMod.ELTPawn'
}
