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
 * ELTGameInfo
 *
 * The actual team game
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 23/12/2012 1:35:23 PM$
 */
class ELTGameInfo extends xTeamGame;

const TEAM_RED = 0;
const TEAM_BLUE = 1;

var int AttackingPlayerNum;
var int CurrentAttackingTeam, FirstAttackingTeam, CurrentRound;
var int RoundStartTime, RoundTimeLimit, GoalActivationTime;

// sounds
var name  NewRoundSound;
var name  DrawGameSound;
var name  AttackerWinRound[2];
var name  DefenderWinRound[2];
var name  TeamWinRound[2];

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
    Super.PrecacheGameStaticMeshes(myLevel);
    myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomRing');
    myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomAMesh');
    myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomBMesh');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
    Super.PrecacheGameAnnouncements(V,bRewardSounds);
    V.PrecacheSound('Denied');
}

/**
 * InitGame()
 * Fill some custom properties with defaults.
 */
event InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);
    CurrentAttackingTeam = TEAM_RED;
    CurrentRound = 0;
    AttackingPlayerNum = 0;
    RemainingTime = CalculateRoundTime();
    FirstAttackingTeam = Rand(1);
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

    UpdateGRI();
}

/**
 * PostBeginPlay()
 * load our game rules before the match starts.
 */
event PostBeginPlay()
{
    local GameRules EliteRules;
    super.PostBeginPlay();

    EliteRules = Spawn(class'EliteMod.ELTGameRules');
    if ( Level.Game.GameRulesModifiers == None ) {
        Level.Game.GameRulesModifiers = EliteRules;
    } else {
        Level.Game.GameRulesModifiers.AddGameRules(EliteRules);
    }
}

/**
 * kill
 */
function RestartPlayer(Controller C)
{
    local int Team;

    Super.RestartPlayer(C);

    if (C == None)
        return;

    Team = C.GetTeamNum();
    if (Team == 255)
        return;
}

/**
 * AddGameSpecificInventory()
 *
 * Give the PRI weapons and health based on his role.
 * We ask the GRI to tell us if his pawns controller team is on defense.
 */
function AddGameSpecificInventory(Pawn P)
{
    Super.AddGameSpecificInventory(P);

    if (P == none || P.Controller == none )
        return;

    if ( CurrentAttackingTeam == P.Controller.GetTeamNum() ) {
        P.CreateInventory("EliteMod.ELTShockRifle");
        P.Health = 4;
        P.HealthMax = 4;
    } else {
        P.CreateInventory("EliteMod.ELTRocketLauncher");
        P.Health = 1;
        P.HealthMax = 1;
    }

    P.NextWeapon();
}

// ============================================================================
// Round Based Stuff
// ============================================================================

function ResetLevel(String Reason)
{
    local Actor A;
    local Controller C, NextC;

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

    /*
    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        EliteObjective(GO).ResetPoint(Reason);
        GO.DefenderTeamIndex = 1 - CurrentAttackingTeam;
        GO.NetUpdateTime = Level.TimeSeconds - 1;
    }*/

    Log("## ResetLevel:"@Reason);
}


function BeginRound()
{
    CurrentRound++;

    Log("## BeginRound:"@CurrentRound);

    // Set Attacking and Defending teams
    if ( CurrentRound % 2 == 1 ) {
        CurrentAttackingTeam = FirstAttackingTeam;
    } else {
        CurrentAttackingTeam = 1 - FirstAttackingTeam;
    }

    // Determine Attacker for this round
    SelectNextAttacker();

    // Reset Remaining Time
    RemainingTime = CalculateRoundTime();

    // Update the GameReplicationInfo
    UpdateGRI();

    // Reset actors and controllers
    ResetLevel("BeginRound");

    Log("  AttackingPlayer:"@GetAttackerName());

    // re-synch time
    ELTGameReplication(GameReplicationInfo).RemainingMinute = RemainingTime;
    ELTGameReplication(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
}

function EndRound(Pawn Instigator, String Reason)
{
    Log("## EndRound:"@Reason);


    QueueAnnouncerSound( NewRoundSound, 1, 255 );
    ResetCountDown = ResetTimeDelay + 4; // ("new round in" sound is 4seconds long);
}



/**
 * Match is in progress
 */
state MatchInProgress
{
    function Timer() {
        super.Timer();

        RemainingTime--;

        GameReplicationInfo.RemainingTime = RemainingTime;
        // SecondsSinceStart = (RoundTimeLimit - RemainingTime);

        if ( RemainingTime % 60 == 0 ) {
            // Force all players to re-synch time every 10 seconds
            GameReplicationInfo.RemainingMinute = RemainingTime;
        }


        Log("Elapsed:"@CalculateElapsedTime()@", Remaining:"@RemainingTime);
    }
}

// ============================================================================
// Helpers
// ============================================================================

function SelectNextAttacker() {
    local ELTPlayerTeam AttackingTeam;

    AttackingTeam = ELTPlayerTeam(Teams[CurrentAttackingTeam]);
    AttackingPlayerNum = AttackingTeam.GetNextAttacker();
}

function Controller GetCurrentAttacker() {
    local ELTPlayerTeam AttackingTeam;

    AttackingTeam = ELTPlayerTeam(Teams[CurrentAttackingTeam]);
    return AttackingTeam.Players[AttackingPlayerNum];
}

function string GetAttackerName()
{
    return GetCurrentAttacker().PlayerReplicationInfo.GetHumanReadableName();
}

/**
 * CalculateRoundTime()
 * Sum of configured round time and reset time and 1 second delay margin.
 */
function int CalculateElapsedTime()
{
    return (RoundTimeLimit - RemainingTime);
}

/**
 * CalculateRoundTime()
 * Sum of configured round time and reset time and 1 second delay margin.
 */
function int CalculateRoundTime()
{
    return (RoundTimeLimit + ResetTimeDelay) + 1;
}

/**
 * UpdateGRI();
 * Assign base variables to GRI
 */
function UpdateGRI()
{
    // round info
    ELTGameReplication(GameReplicationInfo).CurrentRound = CurrentRound;
    ELTGameReplication(GameReplicationInfo).CurrentAttackingTeam = CurrentAttackingTeam;
    ELTGameReplication(GameReplicationInfo).AttackingPlayerNum = AttackingPlayerNum;

    // time settings
    ELTGameReplication(GameReplicationInfo).RoundTimeLimit = RoundTimeLimit;
    ELTGameReplication(GameReplicationInfo).GoalActivationTime = GoalActivationTime;

    // remaining
    ELTGameReplication(GameReplicationInfo).RemainingTime = RemainingTime;
}

/**
 * QueueAnnouncerSound()
 * Wrapper for PC:QueueAnnouncement, taking team affiliation into account
 */
function QueueAnnouncerSound(name ASound, byte AnnouncementLevel, byte Team, optional AnnouncerQueueManager.EAPriority Priority, optional byte Switch )
{
    local Controller C;
    if ( (ASound != '') ) {
        for ( C=Level.ControllerList; C!=None; C=C.NextController ) {
            if ( C.IsA('PlayerController') && ((Team==255) || (C.GetTeamNum()==Team)) )
                PlayerController(C).QueueAnnouncement( ASound, AnnouncementLevel, Priority, switch );
        }
    }
}
// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    // elt variables
    RoundTimeLimit=60
    GoalActivationTime=15

    // epic variables
    MaxLives=1
    GoalScore=0
    MaxTeamSize=3
    MinPlayers=6
    NumBots=6
    NumRounds=6
    ResetTimeDelay=5

    // factors
    FriendlyFireScale=0.000000

    // epic flags
    bScoreTeamKills=false
    bSpawnInTeamArea=true
    bPlayersBalanceTeams=true
    bBalanceTeams=true
    bWeaponStay=true

    // game
    Acronym="ELT"
    GameName="Elite"
    MapPrefix="ELT"
    Description="3vs3 roundbased attacker-defender assault scenario with some elements of domination and deathmatch."

    // classes
    PlayerControllerClassName="EliteMod.ELTPlayer"
    GameReplicationInfoClass=class'EliteMod.ELTGameReplication'
    MutatorClass="EliteMod.ELTMutatorPickups"

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
