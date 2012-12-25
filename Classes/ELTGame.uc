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
 * ELTGame
 *
 * The final blend.
 * - Manages the availablilty of the GameObjective.
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 25/12/2012 2:46:10 AM$
 */
class ELTGame extends ELTRoundGame
    config;

var int GoalActivationTime; // if you set this to 5 the objective will
                            // become "controllable" in the LAST 5 SECONDS
                            // of the current round. ya dig? :)


// ============================================================================
// Implementation
// ============================================================================

/**
 * ReplicateUpdatedGameInfo()
 * Assign all current game related info to our GRI
 */
function ReplicateUpdatedGameInfo()
{
    super.ReplicateUpdatedGameInfo();
    ELTGameReplication(GameReplicationInfo).GoalActivationTime = GoalActivationTime;
}

/**
 * Timer()
 * Match is in progress
 */
state MatchInProgress
{
    function Timer()
    {
        local GameObjective GO;
        Super.Timer();

        if ( bRoundInProgress )
            if ( GetRemainingRoundTime() == GoalActivationTime )
                for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
                    if ( ELTObjective(GO) != None )
                        ELTObjective(GO).MakeControllable( CurrentAttackingTeam );
    }
}

/**
 * CanDisableObjective()
 * Is objective allowed to be disabled ?
 */
function bool CanDisableObjective( GameObjective GO )
{
    if ( !bRoundInProgress )
        return false;

    if ( GO.bBotOnlyObjective )
        return true;

    if ( ELTObjective(GO) == None )
        return false;

    return ELTObjective(GO).IsControllable();
}

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite Game"
    MinNetPlayers=2

    GoalActivationTime=55
}
