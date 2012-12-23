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
 * @version $wotgreal_dt: 23/12/2012 1:22:12 PM$
 */
class ELTPlayerTeam extends xTeamRoster;

// ============================================================================
// Variables
// ============================================================================

var Controller Players[32];
var int NextAttackerNum;

// ============================================================================
// Replication
// ============================================================================

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        Players, NextAttackerNum;
}

// ============================================================================
// Implementation
// ============================================================================

function bool IsEmpty()
{
    return (Size == 0);
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
    local int i;

    if ( super.AddToTeam(Other) ) {
        for (i = 0; i < Size; i++) {
            if ( Players[i] == none ) {
                Log("## EliteTeam"@GetHumanReadableName()@", Player Position"@i@", TeamSize:"@Size);
                Log("   - adding"@ Other.PlayerReplicationInfo.PlayerName);
                Players[i] = Other;

                if ( ELTPlayerReplication(Other.PlayerReplicationInfo) != None ) {
                    ELTPlayerReplication(Other.PlayerReplicationInfo).TeamPosition = i;
                    ELTPlayerReplication(Other.PlayerReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
                }
                return true;
            }
        }
    }

    // should never reach this.
    Warn("## EliteTeam: AddToTeam reached end");
    return false;
}

function RemoveFromTeam(Controller Other)
{
    local int i;

    // find controller in our players array
    for (i = 0; i < Size; i++) {
        if ( Players[i] == Other ) {
            Log("## EliteTeam"@GetHumanReadableName()@", Player Position"@i@", TeamSize:"@Size);
            Log("   - removing"@ Other.PlayerReplicationInfo.PlayerName);

            Players[i] = None;
            super.RemoveFromTeam(Other);
            return;
        }
    }

    // should never reach this, but should also never stop working.
    Warn("## EliteTeam: RemoveFromTeam reached end because Other was not found");
    super.RemoveFromTeam(Other);
}

function int GetNextAttacker()
{
    local int i;
    local Controller NextAttacker;

    if ( IsEmpty() ) {
        Warn("## EliteTeam: GetNextAttacker() while team is empty");
    } else {

        if (NextAttackerNum == Size)
            NextAttackerNum = 0; // reset

        // find next attacker index in our players array
        for (i = 0; i < Size; i++) {
            if (Players[i] != None) {
                if (i == NextAttackerNum) {
                    NextAttacker = Players[i];
                    NextAttackerNum++;
                    break;
                }
            }
        }

        // final sanity check
        if ( NextAttacker == none ) {
            Warn("## EliteTeam: GetNextAttacker() finished but NextAttacker was empty");
        }
    }

    return NextAttackerNum;
}

defaultProperties
{
    NetUpdateFrequency=1
}
