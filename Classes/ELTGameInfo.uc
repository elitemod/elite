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
 * @version $wotgreal_dt: 22/12/2012 8:57:50 PM$
 */
class ELTGameInfo extends xTeamGame;

const TEAM_RED = 0;
const TEAM_BLUE = 1;

var Controller CurrentAttacker;
var int CurrentAttackingTeam;

event InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);

    CurrentAttackingTeam = TEAM_RED;
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if (ELTGameReplication(GameReplicationInfo) == None)
        return;

    ELTGameReplication(GameReplicationInfo).CurrentAttackingTeam = CurrentAttackingTeam;
}

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
    Log("------------------------ pbp -----");
}

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
    local int Team;
    Super.AddGameSpecificInventory(P);

    if (P == none || P.Controller == none )
        return;

    Team = P.Controller.GetTeamNum();

    // is defender or attacker?
    if ( Team == CurrentAttackingTeam ) {
        P.CreateInventory("EliteMod.ELTShockRifle");
        P.Health = 4;
        P.HealthMax = 4;
    } else {
        P.CreateInventory("EliteMod.ELTRocketLauncher");
        P.Health = 1;
        P.HealthMax = 1;
    }

    // initiate a weaponswitch to fix the "whatToDoNext with no weapon"
    P.NextWeapon();
}

function ScoreKill(Controller Killer, Controller Other) {
    if ( Killer == None && Other != None ) {
        super.ScoreKill(Other, Other); // suicide, teamchange
        return;
    }
    super.ScoreKill(Killer, Other);
}

DefaultProperties
{
    Acronym="ELT"
    GameName="Elite"
    MapPrefix="ELT"
    Description="3vs3 roundbased attacker-defender assault scenario with some elements of domination and deathmatch."

    MaxLives=1
    NumRounds=6
    GoalScore=0
    MaxTeamSize=3

    MinPlayers=6
    NumBots=6

    bPlayersBalanceTeams=true
    bBalanceTeams=true
    bScoreTeamKills=false
    bWeaponStay=true

    PlayerControllerClassName="EliteMod.ELTPlayer"
    GameReplicationInfoClass=class'EliteMod.ELTGameReplication'
    MutatorClass="EliteMod.ELTMutatorPickups"
}
