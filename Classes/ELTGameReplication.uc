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
 * @version $wotgreal_dt: 23/12/2012 4:49:19 PM$
 */
class ELTGameReplication extends GameReplicationInfo;

var int CurrentAttackingTeam, CurrentRound;
var int RoundTimeLimit, GoalActivationTime;
var int AttackingPlayerNum;
var bool bRoundInProgress;

enum ERoundWinner
{
    ERW_None,
    ERW_RedAttacked,
    ERW_BlueAttacked,
    ERW_RedDefended,
    ERW_BlueDefended,
    ERW_Draw,
};
var ERoundWinner RoundWinner;

replication
{
    reliable if( bNetDirty && (Role == ROLE_Authority) ) // Variables the server should send to the client.
        CurrentAttackingTeam, CurrentRound,
        RoundTimeLimit, GoalActivationTime,
        AttackingPlayerNum, RoundWinner,
        bRoundInProgress;
}


