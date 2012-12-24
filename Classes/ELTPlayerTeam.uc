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
 * @version $wotgreal_dt: 23/12/2012 2:42:22 PM$
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
    reliable if (bNetDirty && Role == ROLE_Authority)
        Players, NextAttackerNum, NumPlayers;
}

// ============================================================================
// Implementation
// ============================================================================

function bool IsEmpty()
{
    return (NumPlayers == 0);
}

function bool HasOneAlive()
{
    local int i;

    if ( IsEmpty() )
        return false;

    for (i = 0; i < Size; i++) {
        if (Players[i] != none ) {
            if ( Players[i].PlayerReplicationInfo != none ) {
                if ( !Players[i].PlayerReplicationInfo.bOutOfLives ) {
                    return true;
                }
            }
        }
    }
    return false;
}

function bool AddToTeam( Controller Other )
{
    if ( super.AddToTeam(Other) ) {

        Log("## EliteTeam"@TeamIndex@", Player"@Players.Length@", Size:"@Size@", NumPlayers:"@NumPlayers);
        Log("   - adding"@ Other.PlayerReplicationInfo.PlayerName);

        if ( ELTPlayerReplication(Other.PlayerReplicationInfo) != None ) {
            ELTPlayerReplication(Other.PlayerReplicationInfo).TeamPosition = Players.Length;
            ELTPlayerReplication(Other.PlayerReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
        }

        Players[Players.Length] = Other;
        NumPlayers++;

        return true;
    }
    return false;
}

function RemoveFromTeam(Controller Other)
{
    local int i;

    // find controller in our players array
    for (i = 0; i < Players.Length; i++) {
        if ( Players[i] == Other ) {
            Log("## EliteTeam"@TeamIndex@", Player"@i@", Size:"@Size@", NumPlayers:"@NumPlayers);
            Log("   - removing"@ Other.PlayerReplicationInfo.PlayerName);

            Players[i] = None;
            NumPlayers--;

            super.RemoveFromTeam(Other);
            return;
        }
    }

    // should never reach this, but should also never stop working.
    Warn("not found:"@Other);
    super.RemoveFromTeam(Other);
}

function int GetNextAttacker()
{
    local int i;
    local Controller NextAttacker;

    Log("## EliteTeam"@TeamIndex@" - get next attacker");

    if ( IsEmpty() ) {
        Warn("team is empty");
    } else {

        if (NextAttackerNum == Size)
            NextAttackerNum = 0; // reset

        Log("  - NextAttackerNum:"@NextAttackerNum);

        // find next attacker index in our players array
        for (i = 0; i < Players.Length; i++) {
            if (i == NextAttackerNum && Players[i] != None) {
                NextAttacker = Players[i];
                NextAttackerNum++;
                break;
            }
        }

        // final sanity check
        if ( NextAttacker == none ) {
            Warn("NextAttacker was empty");
        }
    }

    return NextAttackerNum;
}

defaultProperties
{
    NetUpdateFrequency=1
}
