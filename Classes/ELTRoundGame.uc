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
 * Manages everything regarding round-based gameplay.
 * - It ends the game if max rounds are hit
 * - Restarts all players and objects each new round
 * - Replicates timings for reset delays and match time
 * - Validates if a kill leads to an end of the current round
 * - Decides the scoring team and increases their score.
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 24/12/2012 5:05:23 PM$
 */
class ELTRoundGame extends ELTTeamGame;

var int CurrentRound;
var int RoundTimeLimit;
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

// ============================================================================
// Implementation
// ============================================================================

/**
 * InitGame()
 * Fill some custom properties with defaults.
 */
event InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);

    // Disable Time Limit.
    TimeLimit = 0;

    // Total remaining time is the amount of time needed for all rounds to run + delay
    RemainingTime = (NumRounds * RoundTimeLimit) + EndTimeDelay;
    if ( GameReplicationInfo != None )
        GameReplicationInfo.RemainingTime = RemainingTime;

    // We start in round 1 and thus we are in progress.
    CurrentRound = 1;
    bRoundInProgress = true;

    // ... bRoundInProgress is managed by EndRound/StartNewRound
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

    // sync
    ELTGameReplication(GameReplicationInfo).ElapsedTime = ElapsedTime;
    ELTGameReplication(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
}

/**
 * StartMatch()
 * Overwrite startmatch to also trigger our custom round start
 */
function StartMatch()
{
    super.StartMatch();

    Log("---------------------------------------------- StartMatch: ("$CurrentRound$"/"$NumRounds$")");
}

/**
 * StartNewRound()
 */
function StartNewRound()
{
    CurrentRound++;

    Log("---------------------------------------------- New Round: ("$CurrentRound$"/"$NumRounds$")");

    // Set Attacking and Defending teams
    if ( CurrentRound % 2 == 1 ) {
        CurrentAttackingTeam = FirstAttackingTeam;
    } else {
        CurrentAttackingTeam = 1 - FirstAttackingTeam;
    }

    SelectNextAttacker();

    bRoundInProgress = true;
    ElapsedTime = 0;
    ReplicateUpdatedGameInfo();
    ResetLevel();
    RestartAllPlayers();

    TriggerEvent('RoundStarted', Self, None);

    SetGameSpeed( GameSpeed );
}

event RoundStarted()
{
    Log("## round started ! ##");
}

/**
 * EndRound()
 *
 */
function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason)
{
    local Controller C;
    local PlayerReplicationInfo PRI;
    local int ScoringTeam;

    if ( !bRoundInProgress )
        return;

    // flag round as ended
    bRoundInProgress = false;

    // get PRI if intstigator is known
    if ( (Instigator != None) && (Instigator.Controller != None) ) {
        PRI = Instigator.Controller.PlayerReplicationInfo;
    }

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
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "won because all defenders are dead." );
    }
    else if ( RoundEndReason == ERER_AttackerDead )
    {
        ScoringTeam = 1 - CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "died."@ Teams[ScoringTeam].GetHumanReadableName() @"wins the round.");
    }
    else if ( RoundEndReason == ERER_RoundTime )
    {
        ScoringTeam = 1 - CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded]" @ GetAttackerName() @ "is out of time. The"@ Teams[ScoringTeam].GetHumanReadableName() @"team wins.");
    }
    else if ( RoundEndReason != ERER_NoOneLeft )
    {
        ScoringTeam = 1 - CurrentAttackingTeam;
        Level.Game.Broadcast(Self, "[RoundEnded] No one is left to win the round.");
    }

    // Increase Team Score
    // =========================================================
    Teams[ScoringTeam].Score += 1.0;
    Teams[ScoringTeam].NetUpdateTime = Level.TimeSeconds - 1;
    TeamScoreEvent(ScoringTeam, 1, "endround_scoring_team");
    AnnounceScore(ScoringTeam);

    // =========================================================
    ReplicateUpdatedGameInfo();

    Log("---------------------------------------------- EndRound");
    Log("  EndRound Reason: "@Reason);

    if ( Instigator != None )
        Log("  Scoring Instigator: "@Instigator.GetHumanReadableName()$", Team:"@Instigator.GetTeamNum());

    Log("  Scoring Team Index: "@ScoringTeam);
    Log("  Scoring IsAttackingTeam: "@IsAttackingTeam(ScoringTeam));
    Log("  Scoring Team Score: "@GameReplicationInfo.Teams[ScoringTeam].Score );

    // check if match is over
    // =========================================================
    if ( CurrentRound == NumRounds ) {
        Log("---------------------------------------------- EndMatch");
        EndGame(None,"teamscorelimit");
        return;
    }

    QueueAnnouncerSound(NewRoundSound, 1, 255);
    ResetCountDown = ResetTimeDelay + 4;
}


/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    local Pawn InsitigatedBy;
    local Controller C, NextC;

    if ( !bRoundInProgress )
        return;

    // find pawn by PRI
    if ( Scorer != None ) {
        C = Level.ControllerList;
        while ( C != None  ) {
            NextC = C.NextController;
            if ( C.PlayerReplicationInfo != None && C.PlayerReplicationInfo == Scorer )  {
                InsitigatedBy = C.Pawn;
                break;
            }
            C = NextC;
        }
    }

    // check living players
    if ( !ELTPlayerTeam(Teams[1-CurrentAttackingTeam]).HasOneAlive() )
    {
        Log("CheckScore ... bDefendersDead!");
        EndRound(ERER_DefendersDead,InsitigatedBy,"attacker_killed_all");
    }
    else if ( !ELTPlayerTeam(Teams[CurrentAttackingTeam]).HasOneAlive() )
    {
        Log("CheckScore ... bAttackersDead!");
        EndRound(ERER_AttackerDead,InsitigatedBy,"defenders_killed_attacker");
    }
}


function AnnounceScore( int ScoringTeam )
{
    local name ScoreSound;

    if ( IsAttackingTeam( ScoringTeam ) )
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

    QueueAnnouncerSound( ScoreSound, 1, 255 );
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
 *
 * Always return false.
 * CheckScore decides what is dead or not
 */
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    return false;
}

/**
 * Reset()
 * .. ignore default Reset. We handle that.
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

    Log("ResetLevel");

    // Force bTeamScoreRounds to avoid having TeamScores reset to 0
    bTeamScoreRounds = true;

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
function int CalculateRoundTime()
{
    return RoundTimeLimit + 1;
}

/**
 * GetRoundString()
 *
 * Tiny text helper that shows something like "(1/6)" depening on NumRounds and CurrentRound
 */
function string GetRoundString()
{
    return "("$CurrentRound$"/"$NumRounds$")";
}

/**
 * Match is in progress
 */
state MatchInProgress
{
    function Timer()
    {
        super.Timer();

        if ( ElapsedTime % 10 == 0 ) { // Force all players to re-synch time every 10 seconds
            GameReplicationInfo.ElapsedTime = ElapsedTime;
        }

        if ( ResetCountDown > 0 ) {
            ResetCountDown--;
            if ( (ResetCountDown > 0) && (ResetCountDown <= 5) )
                BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown);
            else if ( ResetCountDown == 0 )
                StartNewRound();
        }
        else
        {
            // round time limit
            if ( ElapsedTime >= ELTGameReplication(GameReplicationInfo).RoundTimeLimit )
                EndRound(ERER_RoundTime, None, "roundtimelimit");
        }
    }
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite Roundbased Game"
    bTeamScoreRounds=false

    RoundTimeLimit=60
    ResetTimeDelay=5
    NumRounds=6

    // sounds
    bSkipPlaySound=true
    DrawGameSound=Draw_Game
    NewRoundSound=New_assault_in
    AttackerWinRound(0)=Red_team_attacked
    AttackerWinRound(1)=Blue_team_attacked
    DefenderWinRound(0)=Red_team_defended
    DefenderWinRound(1)=Blue_team_defended
    TeamWinRound(0)=Red_team_round
    TeamWinRound(1)=Blue_team_round
}