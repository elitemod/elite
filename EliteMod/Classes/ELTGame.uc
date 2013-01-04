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

// TODO: Play the "Denied" announcer if the attacker is killed while charging the GO! :)

/**
 * ELTGame
 *
 * The final blend.
 * - Manages the availablilty of the GameObjective.
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 04.01.2013 6:33:09 $
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
        local int RemainingRoundTime;

        Super.Timer();

        if ( bRoundInProgress ) {
            RemainingRoundTime = GetRemainingRoundTime();

            if ( RemainingRoundTime < (GoalActivationTime-1) && RemainingRoundTime > 0 )
                BroadcastLocalizedMessage(class'EliteMod.ELTMessageRoundTime', RemainingRoundTime);

            if ( RemainingRoundTime == GoalActivationTime )
                TryActivateGameObjectives();
        }
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


/**
 * BroadcastPoleBecameActive()
 *
 * Display "pole is active" at goal time, triggered by MatchInProgress.Timer()
 */
function bool TryActivateGameObjectives()
{
    local GameObjective GO;
    local Controller    C, NextC;
    local int           MessageStartIndex;
    local bool          bDidActivateSomething;

    if ( !GameReplicationInfo.bMatchHasBegun || bGameEnded || bWaitingToStartMatch || !bRoundInProgress )
        return false;

    // try activate any ELTObjectives in this map
    bDidActivateSomething = false;
    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        if ( ELTObjective(GO) != None ) {
            ELTObjective(GO).MakeControllable( CurrentAttackingTeam );
            bDidActivateSomething = true;
        }
    }

    // there is no point to announce something that did not happen.
    if ( !bDidActivateSomething )
        return false;

    // annouce to all players that the objective is now active and can be controlled
    MessageStartIndex = 0;
    C = Level.ControllerList;
    while ( C != None )
    {
        NextC = C.NextController;
        if ( C.PlayerReplicationInfo != None && PlayerController(C) != None )
        {
            if ( C.PlayerReplicationInfo.bOutOfLives || C.PlayerReplicationInfo.bOnlySpectator )
                MessageStartIndex = 2;

            if ( Super.IsAttackingTeam( C.GetTeamNum() ) )
                PlayerController(C).ReceiveLocalizedMessage( class'EliteMod.ELTMessageObjective', MessageStartIndex, C.PlayerReplicationInfo);
            else
                PlayerController(C).ReceiveLocalizedMessage( class'EliteMod.ELTMessageObjective', MessageStartIndex + 1, C.PlayerReplicationInfo);
        }
        C = NextC;
    }

    return true;
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite Game"
    GoalActivationTime=15
}
