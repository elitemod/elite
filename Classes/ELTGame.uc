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
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 24/12/2012 2:13:39 AM$
 */
class ELTGame extends ELTRoundGame
    config;

function MakeObjectiveControllable()
{
    local GameObjective GO;

    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        ELTObjective(GO).MakeControllable( CurrentAttackingTeam );
    }
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
    super.InitGame( Options, Error );
}


/**
 * PostBeginPlay()
 * load our game rules.
 */
event PostBeginPlay()
{
    local GameRules EliteRules;

    super.PostBeginPlay();

    // Load and add rules
    EliteRules = Spawn(class'EliteMod.ELTGameRules');
    if ( Level.Game.GameRulesModifiers == None ) {
        Level.Game.GameRulesModifiers = EliteRules;
    } else {
        Level.Game.GameRulesModifiers.AddGameRules(EliteRules);
    }
}


function bool IsPlaying()
{
    return false;
}

/**
 * Match is in progress
 */
state MatchInProgress
{
    function Timer()
    {
        super.Timer();

        // If TimeLimit is disabled, keep timing (but ignore TimeLimit criteria to end game)
        if ( TimeLimit < 1 )
        {
            GameReplicationInfo.bStopCountDown = false;
            RemainingTime--;
        }

        GameReplicationInfo.RemainingTime = RemainingTime;

        if ( RemainingTime % 60 == 0 ) {
            // Force all players to re-synch time every 10 seconds
            GameReplicationInfo.RemainingMinute = RemainingTime;
        }

        Log("Elapsed:"@CalculateElapsedTime()@", Remaining:"@RemainingTime);

        if ( ResetCountDown > 0 )
        {
            ResetCountDown--;

            if ( (ResetCountDown > 0) && (ResetCountDown <= 5) )
                BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown);
            else if ( ResetCountDown == 0 )
                StartNewRound();
        }
        else
        {
            // check if it's time to activate the pole
            if ( CalculateElapsedTime() == GoalActivationTime ) {
                MakeObjectiveControllable();
            }

            // check if the round time limit has been hit
            if ( CalculateElapsedTime() >= ELTGameReplication(GameReplicationInfo).RoundTimeLimit )
            {
                EndRound(ERER_RoundTime, None, "roundtimelimit");
            }
        }
    }

    function bool IsPlaying()
    {
        return ELTGameReplication(GameReplicationInfo).RoundWinner == ERW_None && ResetCountDown == 0;
    }
}


/**
 * Match is pending
 */
auto State PendingMatch
{
    function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason);

Begin:
    if ( bQuickStart )
        StartMatch();
}

/**
 * Match is over
 */
State MatchOver
{
    function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason) {}
}

/**
 * AnnounceScore()
 */
function AnnounceScore( int ScoringTeam )
{
    local name ScoreSound;

    if ( ScoringTeam == ELTGameReplication(GameReplicationInfo).CurrentAttackingTeam )
    {
        if ( ScoringTeam == 1 )
            ELTGameReplication(GameReplicationInfo).RoundWinner = ERW_BlueAttacked;
        else
            ELTGameReplication(GameReplicationInfo).RoundWinner = ERW_RedAttacked;

        ScoreSound = AttackerWinRound[ScoringTeam];
    }
    else
    {
        if ( ScoringTeam == 1 )
            ELTGameReplication(GameReplicationInfo).RoundWinner = ERW_BlueDefended;
        else
            ELTGameReplication(GameReplicationInfo).RoundWinner = ERW_RedDefended;

        ScoreSound = DefenderWinRound[ScoringTeam];
    }

    /*
    // team just won, not necessarly because the were defending or attacking.
    if ( !bWasRoleScore ) {
        ScoreSound = TeamWinRound[ScoringTeam];
    }*/

    QueueAnnouncerSound(ScoreSound, 1, 255);
}

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite Game"

    MaxLives=1
    GoalScore=0

    MinNetPlayers=2
}
