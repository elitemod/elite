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
 * ELTRoundGame
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 24/12/2012 5:43:19 AM$
 */
class ELTRoundGame extends ELTTeamGame;

var int CurrentRound;
var int RoundTimeLimit;
var int GoalActivationTime;
var bool bRoundInProgress;

enum ERER_Reason
{
    ERER_PoleTapped,    // attacker wins
    ERER_DefendersDead, // attacker wins
    ERER_AttackerDead,  // defender win,
    ERER_RoundTime,     // defender win,
    ERER_NoOneLeft,     // attacker wins
};

// sounds
var name  NewRoundSound;
var name  DrawGameSound;
var name  AttackerWinRound[2];
var name  DefenderWinRound[2];
var name  TeamWinRound[2];

/**
 * InitGame()
 * Fill some custom properties with defaults.
 */
event InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);

    bRoundInProgress = false;

    CurrentRound  = 1;
    TimeLimit     = 0;
    RemainingTime = CalculateRoundTime();

    if ( GameReplicationInfo != None )
        GameReplicationInfo.RemainingTime = RemainingTime;
}

/**
 * InitGameReplicationInfo()
 * After setting up GameReplication, copy some properties to GRI
 */
function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();
    if (ELTGameReplication(GameReplicationInfo) == None)
        return;

    ReplicateUpdatedGameInfo();
}

/**
 * ReplicateUpdatedGameInfo()
 * Assign all current game related info to our GRI
 */
function ReplicateUpdatedGameInfo()
{
    // round info
    ELTGameReplication(GameReplicationInfo).bRoundInProgress = bRoundInProgress;
    ELTGameReplication(GameReplicationInfo).CurrentRound = CurrentRound;
    ELTGameReplication(GameReplicationInfo).CurrentAttackingTeam = CurrentAttackingTeam;
    ELTGameReplication(GameReplicationInfo).AttackingPlayerNum = AttackingPlayerNum;

    // time settings
    ELTGameReplication(GameReplicationInfo).RoundTimeLimit = RoundTimeLimit;
    ELTGameReplication(GameReplicationInfo).GoalActivationTime = GoalActivationTime;

    // remaining
    ELTGameReplication(GameReplicationInfo).RemainingTime = RemainingTime;

    // resync
    ELTGameReplication(GameReplicationInfo).RemainingMinute = RemainingTime;
    ELTGameReplication(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
}

/**
 * StartMatch()
 * Overwrite startmatch to also trigger our custom round start
 */
function StartMatch()
{
    super.StartMatch();

    bRoundInProgress = true;
}

/**
 * StartNewRound()
 */
function StartNewRound()
{
    CurrentRound++;

    // Set Attacking and Defending teams
    if ( CurrentRound % 2 == 1 ) {
        CurrentAttackingTeam = FirstAttackingTeam;
    } else {
        CurrentAttackingTeam = 1 - FirstAttackingTeam;
    }

    SelectNextAttacker();

    bRoundInProgress = true;

    // Determine Attacker for this round
    Log("---------------------------------------------- BeginRound: GAME");

    // Reset Remaining Time
    RemainingTime = CalculateRoundTime();

    // Update the GameReplicationInfo
    ReplicateUpdatedGameInfo();

    ResetLevel();

    RestartAllPlayers();


    SetGameSpeed( GameSpeed );
}

/**
 * EndRound()
 *
 */
function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason)
{
    local Controller C;
    local int ScoringTeam;

    if ( !bRoundInProgress )
        return;

    Log("---------------------------------------------- EndRound: GAME");
    Log("  Reason: "@Reason);

    bRoundInProgress = false;

    // fix player state
    for ( C=Level.ControllerList; C!=None; C=C.NextController ) {
        if ( C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator ) {
            C.GotoState('RoundEnded');
        }
    }

    if ( RoundEndReason == ERER_PoleTapped )
    {
        ScoringTeam = CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "won by tapping the game objective." );
    }
    else if ( RoundEndReason == ERER_DefendersDead )
    {
        ScoringTeam = CurrentAttackingTeam;

        if (Reason == "defenders_killz") {
            Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "won because all defenders are dead." );
        } else {
            Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "won by eliminating all defenders." );
        }
    }
    else if ( RoundEndReason == ERER_AttackerDead )
    {
        ScoringTeam = 1 - CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "is dead."@ Teams[ScoringTeam].GetHumanReadableName() @"wins the round.");
    }
    else if ( RoundEndReason == ERER_RoundTime )
    {
        ScoringTeam = 1 - CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "is out of time. The"@ Teams[ScoringTeam].GetHumanReadableName() @"team wins.");
    }
    else if ( RoundEndReason != ERER_NoOneLeft )
    {
        Level.Game.Broadcast(Self, "[RoundEnded] No one is left to win the round.");
    }

    // Increase Team Score for this round
    // =========================================================
    Teams[ScoringTeam].Score += 1.0;
    Teams[ScoringTeam].NetUpdateTime = Level.TimeSeconds - 1;

    // Announce round winner, replicate and restart
    // =========================================================
    AnnounceScore(ScoringTeam);
    ReplicateUpdatedGameInfo();
    QueueAnnouncerSound(NewRoundSound, 1, 255);
    ResetCountDown = ResetTimeDelay + 4;
}


/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    local bool bDefendersDead, bAttackersDead;
    Super.CheckScore( Scorer );

    bAttackersDead = !ELTPlayerTeam(Teams[CurrentAttackingTeam]).HasOneAlive();
    bDefendersDead = !ELTPlayerTeam(Teams[1-CurrentAttackingTeam]).HasOneAlive();

    if ( bDefendersDead )
        EndRound(ERER_DefendersDead,None,"attacker_killed_all");
    else if ( bAttackersDead )
        EndRound(ERER_AttackerDead,None,"defenders_killed_attacker");
    else
        Log("# KEEP GOING ...");
}

/**
 * ScoreKill()
 *
 * Since this is a roundbased variant of the TDM version,
 * we use the ELTTeamGame parent "TeamGame" version and skip
 * the manual Attacker restart.
 */
function ScoreKill(Controller Killer, Controller Other)
{
    super(TeamGame).ScoreKill(Killer, Other); // ignore ELTTeamGame.
}

/**
 * CheckMaxLives()
 * Always return false. CheckScore decides what is dead or not
 */
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    return false; // ignore MaxLives = 1 check in parent ScoreKill
}

/**
 * Reset()
 * .. ignore default Reset. We handle that ourselves.
 */
function Reset() { }

/**
 * RestartAllPlayers()
 *
 * Respawn all active players
 */
function RestartAllPlayers()
{
    local Controller C, NextC;

    C = Level.ControllerList;
    while ( C != none ) {
        NextC = C.NextController;
        if ( C.PlayerReplicationInfo == None || !C.PlayerReplicationInfo.bOnlySpectator ) {
            RestartPlayer(C);
        }
        C = NextC;
    }
}

/**
 * ResetLevel()
 *
 * Reset actors, controllers and objectives
 */
function ResetLevel()
{
    local Actor A;
    local Controller C, NextC;
    local GameObjective GO;

    // Reset ALL controllers first
    C = Level.ControllerList;
    while ( C != none ) {
        NextC = C.NextController;
        if ( C.PlayerReplicationInfo == None || !C.PlayerReplicationInfo.bOnlySpectator ) {
            if ( PlayerController(C) != None )
                PlayerController(C).ClientReset();
            C.Reset();
        }
        C = NextC;
    }

    // Reset ALL actors (except controllers)
    foreach AllActors(class'Actor', A)
        if ( !A.IsA('Controller') )
            A.Reset();

    // Force defender team index
    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        GO.DefenderTeamIndex = 1 - CurrentAttackingTeam;
        GO.NetUpdateTime = Level.TimeSeconds - 1;
    }
}


/**
 * CalculateRoundTime()
 * Sum of configured round time and reset time and 1 second delay margin.
 */
function int CalculateElapsedTime()
{
    return (CalculateRoundTime() - RemainingTime);
}

/**
 * CalculateRoundTime()
 * Sum of configured round time and reset time and 1 second delay margin.
 */
function int CalculateRoundTime()
{
    if ( CurrentRound == 0 ) {
        return RoundTimeLimit + 1;
    }
    return (RoundTimeLimit + ResetTimeDelay) + 1;
}

/**
 * MakeObjectiveControllable()
 *
 * Go through all ELTObjective in the map and call "MakeControllable"
 */
function MakeObjectiveControllable()
{
    local GameObjective GO;

    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        ELTObjective(GO).MakeControllable( CurrentAttackingTeam );
    }
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

        Log("Elapsed:"@CalculateElapsedTime()@", Remaining:"@RemainingTime@", Limit:"@ELTGameReplication(GameReplicationInfo).RoundTimeLimit);

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
            if ( CalculateElapsedTime() == GoalActivationTime )
            {
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

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite Roundbased Game"

    RoundTimeLimit=60
    ResetTimeDelay=5
    NumRounds=6


    // sounds
    DrawGameSound=Draw_Game
    NewRoundSound=New_assault_in
    bSkipPlaySound=true
    AttackerWinRound(0)=Red_team_attacked
    AttackerWinRound(1)=Blue_team_attacked
    DefenderWinRound(0)=Red_team_defended
    DefenderWinRound(1)=Blue_team_defended
    TeamWinRound(0)=Red_team_round
    TeamWinRound(1)=Blue_team_round
}
