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
 * ELTTeamGame
 *
 * Builds on basic TDM rules, but enforces MaxLives and Health depending
 * on which team is currently attacking. It also reduces all relevant damage
 * to exactly 1 damage per hit and gives defenders the ability to rocketjump.
 *
 * It also provides valuable informations and helper methods regarding the
 * current attacker. SelectNextAttacker for example, is used in ELTRoundGame,
 * while IsAttackingTeam or GetCurrentAttacker is used throughout the entire mod.
 *
 * Furthermore, it decides where players get to spawn by querying the ELTPlayerSpawnManager.
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 24/12/2012 9:00:18 PM$
 */
class ELTTeamGame extends xTeamGame
    config;

var Array<ELTPlayerSpawnManager> SpawnManagers;
var int CurrentAttackingTeam, FirstAttackingTeam;
var int AttackingPlayerNum;

var config  string AttackerWeapon, DefenderWeapon;
var config  int AttackerHealth, DefenderHealth;
var config  int AttackerDamage, DefenderDamage;

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

    FirstAttackingTeam = Rand(1);
    CurrentAttackingTeam = FirstAttackingTeam;
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

    ELTGameReplication(GameReplicationInfo).CurrentAttackingTeam = FirstAttackingTeam;
}

/**
 * PrecacheGameStaticMeshes
 */
static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
    Super.PrecacheGameStaticMeshes(myLevel);
    myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomRing');
}

/**
 * PrecacheGameAnnouncements
 */
static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
    Super.PrecacheGameAnnouncements(V,bRewardSounds);
    V.PrecacheSound('Denied');
}

/**
 * PostBeginPlay()
 * load our game rules.
 */
event PostBeginPlay()
{
    local ELTPlayerSpawnManager PSM;
    local GameObjective GO;

    super.PostBeginPlay();

    // Caching PlayerSpawnManagers
    foreach AllActors(class'ELTPlayerSpawnManager', PSM)
        SpawnManagers[SpawnManagers.Length] = PSM;

    // Force objective DefenderTeamIndex
    for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective ) {
        GO.DefenderTeamIndex = 1 - CurrentAttackingTeam;
        GO.NetUpdateTime = Level.TimeSeconds - 1;
    }
}

function StartMatch()
{
    super.StartMatch();

    SelectNextAttacker();
}

/**
 * ScoreKill()
 *
 * this is the TDM version of Elite, so if attacker is dead, just spawn the next in line.
 */
function ScoreKill(Controller Killer, Controller Other)
{
    super.ScoreKill(Killer, Other);

    if ( CriticalPlayer(Other) )
    {
        SelectNextAttacker();
        RestartAttacker();
    }
}

/**
 * CriticalPlayer()
 *
 * Returns true if passed Controller is the current Attacker (= critical)
 */
function bool CriticalPlayer(Controller Other)
{
    return ((Other.PlayerReplicationInfo != None) && (Other == GetCurrentAttacker()));
}

/**
 * ReduceDamage()
 *
 * Reduce WeaponDamage to 1 damage
 * Amplify velocity if self-damage with rocket launcher = rocketjump
 */
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local int DistanceInMeters;
    local PlayerReplicationInfo InstigatedPRI;

    // as usual
    Damage = super.ReduceDamage(Damage,Injured,InstigatedBy,HitLocation,Momentum,DamageType);

    // attacker damage
    if (ClassIsChildOf(DamageType, class'DamTypeSniperShot')
      || ClassIsChildOf(DamageType, class'DamTypeSniperHeadShot')
      || ClassIsChildOf(DamageType, class'DamTypeShockBeam'))
    {
        if (Injured.Controller.GetTeamNum() != InstigatedBy.Controller.GetTeamNum()) {
            Damage = AttackerDamage;

            InstigatedPRI = InstigatedBy.Controller.PlayerReplicationInfo;

            // announce distance to player
            if ( PlayerController(InstigatedBy.Controller) != None ) {
                DistanceInMeters = int(VSize(Hitlocation-InstigatedBy.Location)*0.01875.f);
                PlayerController(InstigatedBy.Controller).ReceiveLocalizedMessage(class'EliteMod.ELTMessageDistance', DistanceInMeters, InstigatedPRI);
            }
        } else {
            Damage = 0;
        }
    }
    // defender damage
    else if (ClassIsChildOf(DamageType, class'DamTypeRocket'))
    {
        if ( InstigatedBy == None || Injured == None ) {
            Damage = 0;
        }
        else if (Injured == InstigatedBy) {
            // rocket launcher jump
            InstigatedBy.Velocity += (1.6*Momentum);
            InstigatedBy.Velocity.Z *= 1.2;
        }
        else if (Injured.Controller.GetTeamNum() != InstigatedBy.Controller.GetTeamNum()) {
            // rocket damage
            Damage = DefenderDamage;
        }
    }
    // disable default engine damage
    else if (ClassIsChildOf(DamageType, class'Crushed')) {
        if ( Damage < 10 ) // jump on head?
            Damage = 0;
    }
    else if (ClassIsChildOf(DamageType, class'Fell')) {
        // falling damage
        Damage = 0;
    }

    return Damage;
}

/**
 * RestartPlayer
 */
function RestartPlayer(Controller C)
{
    if ( IsAttackingTeam ( C.GetTeamNum() ) ) {
        if ( C != GetCurrentAttacker() ) {
            C.PlayerReplicationInfo.NumLives = 0;
            C.PlayerReplicationInfo.bOutOfLives = true;
        }
    } else {
        C.PlayerReplicationInfo.NumLives = 1;
        C.PlayerReplicationInfo.bOutOfLives = false;
    }

    Super.RestartPlayer(C);
}

/**
 * RestartAttacker()
 *
 * Resurrect the current Attacker
 */
function bool RestartAttacker()
{
    local Controller Attacker;

    Attacker = GetCurrentAttacker();
    if ( (Attacker != None) && (Attacker.PlayerReplicationInfo != None) ) {
        Attacker.PlayerReplicationInfo.NumLives = 1;
        Attacker.PlayerReplicationInfo.bOutOfLives = false;
        RestartPlayer( Attacker );
        return true;
    }

    return false;
}


/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    if ( (Scorer != None) && bOverTime )
        EndGame(Scorer,"timelimit");
}

/**
 * IsAttackingTeam()
 *
 * Check if given TeamNumber is currently attacking
 */
function bool IsAttackingTeam(int TeamNumber)
{
    return ( TeamNumber == CurrentAttackingTeam );
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

    if ( IsAttackingTeam ( P.Controller.GetTeamNum() ) ) {
        P.CreateInventory( AttackerWeapon );
        P.Health = AttackerHealth;
        P.HealthMax = AttackerHealth;
    } else {
        P.CreateInventory( DefenderWeapon );
        P.Health = DefenderHealth;
        P.HealthMax = DefenderHealth;
    }

    P.NextWeapon();
}


/**
 * SelectNextAttacker()
 * Shortcut to CurrentAttackingTeam...GetNextAttacker()
 *
 * Assigns "AttackingPlayerNum" so we gotta replicate after this to make sure
 * everyone knows who has been chosen.
 */
function SelectNextAttacker()
{
    local ELTPlayerTeam AttackingTeam;

    AttackingTeam = ELTPlayerTeam(Teams[CurrentAttackingTeam]);
    AttackingPlayerNum = AttackingTeam.GetNextAttacker();

    // replicate
    ELTGameReplication(GameReplicationInfo).AttackingPlayerNum = AttackingPlayerNum;
    ELTGameReplication(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    // tell others
    Level.Game.Broadcast(self, GetAttackerName()@"is attacking.");
    Log("### > "@GetAttackerName()@"is attacking.");
}

/**
 * GetCurrentAttacker()
 * Based on the current indexes, read the controller from the TeamInfo players array
 */
function Controller GetCurrentAttacker()
{
    local ELTPlayerTeam AttackingTeam;

    AttackingTeam = ELTPlayerTeam(Teams[CurrentAttackingTeam]);

    if ( AttackingTeam == None )
        return None;

    return AttackingTeam.Players[AttackingPlayerNum];
}

/**
 * GetAttackerName()
 * Usually just used for debug, returns the attackers player name
 */
function string GetAttackerName()
{
    local Controller Attacker;

    Attacker = GetCurrentAttacker();

    if ( Attacker == None )
        return "Unknown";

    if ( Attacker.PlayerReplicationInfo == None )
        return "Unknown";

    return Attacker.PlayerReplicationInfo.GetHumanReadableName();
}

/**
 * GetDefenderNum()
 *
 * Native function from GameInfo.
 * Properly return our defending teamindex
 */
function int GetDefenderNum()
{
    return (1 - CurrentAttackingTeam);
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

/**
 * FindPlayerStart()
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint   N, BestStart;
    local byte              Team, T;
    local float             BestRating, NewRating;
    local Teleporter        Tel;

    // Fix for InTeam not working correctly in GameInfo
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.Team != None )
        Team = Player.PlayerReplicationInfo.Team.TeamIndex;
    else
        Team = InTeam;

    if ( Player != None )
        Player.StartSpot = None;

     if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if ( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if ( string(Tel.Tag)~=incomingName )
                return Tel;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        NewRating = RatePlayerStart(N, Team, Player);
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if ( PlayerStart(BestStart) == None )
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
        log(" Player:" @ Player.GetHumanReadableName() @ "Team:" @ Team @ "Player.Event:" @ Player.Event );
        BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N ) // consider all playerstarts...
        {
            if ( PlayerStart(N) != None )
                T = PlayerStart(N).TeamNumber;
            else
                T = Team;
            NewRating = RatePlayerStart(N, T, Player);
            if ( InventorySpot(N) != None )
                NewRating -= 50;
            NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

    // Ugly Hack to force player to use a specific Spawning area
    if ( Player != None )
        Player.Event = '';

    return BestStart;
}

/**
 * RatePlayerStart()
 * Wrapper for PC:QueueAnnouncement, taking team affiliation into account
 */
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local int i;

    P = PlayerStart(N);
    if ( P == None )
        return -10000000;

    if ( SpawnManagers.Length > 0 )
    {
        for (i=0; i<SpawnManagers.Length; i++)
        {
            // Ignore TeamGame RatePlayerStart, since we don't want
            // PRI.Team to match with PlayerStart.TeamNumber
            if ( SpawnManagers[i].ApprovePlayerStart(P, Team, Player) )
                return super(DeathMatch).RatePlayerStart(N, Team, Player);
        }
    }
    return -9000000;
}


// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    MaxTeamSize=3
    MaxLives=1;

    // testing with bots
    MinPlayers=6
    InitialBots=5

    Acronym="ELT"
    GameName="Elite TeamGame"

    GoalScore=0
    ResetTimeDelay=5
    SpawnProtectionTime=0
    FriendlyFireScale=0.000000

    bScoreTeamKills=false
    bSpawnInTeamArea=true
    bPlayersBalanceTeams=false
    bPlayersMustBeReady=true
    bWeaponShouldViewShake=false
    bBalanceTeams=true
    bWeaponStay=true

    // config options
    AttackerWeapon="EliteMod.ELTLightning"
    AttackerDamage=1
    AttackerHealth=4

    DefenderWeapon="EliteMod.ELTRocketLauncher"
    DefenderDamage=1
    DefenderHealth=1


    // classes
    PlayerControllerClassName="EliteMod.ELTPlayer"
    GameReplicationInfoClass=class'EliteMod.ELTGameReplication'
    DefaultEnemyRosterClass="EliteMod.ELTPlayerTeam"
    MutatorClass="EliteMod.ELTLevelMutator"
}
