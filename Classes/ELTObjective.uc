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
 * ELTObjective
 *
 * The center of attention for this gametype.
 *
 * It has 3 different display states it may be in and always
 * starts as "Neutral". As the game progresses the GameInfo timer
 * may trigger "MakeControllable()" which will color the objective
 * according to the DefenderTeamIndex.
 *
 * ==== MAPPER WARNING ====
 * Although mappers could use this item directly, it is recommened to not
 * place it into their levels, as they would bind themselve to this package.
 * Mappers should use the dummy actor provided in EliteMapUtils package that does
 * not undergo default versioning (in other words: the filename will not change).
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 25/12/2012 12:20:03 PM$
 */
class ELTObjective extends GameObjective;

#exec OBJ LOAD FILE=UCGeneric.utx
#exec OBJ LOAD FILE=XGameTextures.utx

// configurable
var() sound ChargingSound;      // sound played when an attacker is standing on it
var() int MaxChargedAmount;     // maximum amount that can be charged until score
var() int ScoreForMaxCharge;    // points awarded for fully charging the pole


// internal
var Pawn ChargingPawn;          // pawn who is currently charging up
var bool bIsBeingCharged;       // an attacker is standing on it.
var float ChargeTickTime;       // charge timer, seconds, or fraction
var int ChargeTickAmt;          // amount to charge per tick (time*amt<=max)
var int ChargedAmount;          // current amount

// visuals
var ELTObjectivePole        Pole;
var ELTObjectiveBase        PoleBase;
var xDOMRing                Ring;

var Material                SkinRed, SkinBlue, SkinWhite;
var Material                CurrentTeamSkin;

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        bIsBeingCharged, ChargedAmount, CurrentTeamSkin;
}

// ============================================================================
// Implementation
// ============================================================================

function MakeControllable( int CurrentAttackingTeam )
{
    Log("--- MakeControllable ---");
    SetTeam( 1 - CurrentAttackingTeam );
    HighlightPhysicalObjective( true );
    ApplyColoring( 1 - CurrentAttackingTeam );
    NetUpdateTime = Level.TimeSeconds - 1;
    GotoState('Controllable');
}

simulated function Reset()
{
    FlagIdle();
    ApplyColoring(255);
    ChargedAmount = 0;
    super.Reset();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    ChargedAmount = 0;

    if ( (Level.NetMode != NM_Client) && !Level.Game.IsA('ELTTeamGame') )  {
        bHidden = true;
    }
    else if (Level.NetMode != NM_Client)
    {
        // initialize externals
        PoleBase = spawn(class'EliteMod.ELTObjectiveBase',self,,Location);
        Pole = spawn(class'EliteMod.ELTObjectivePole',self,,Location);
        Ring = Spawn(class'XGame.xDomRing',self,,Location+Vect(0,0,860),Rotation);

        ApplyColoring( DefenderTeamIndex );

        // start timer
        SetTimer(ChargeTickTime, true);
    }
}

simulated function PostNetReceive()
{
    if ( IsCaptured() ) // priority
    {
        ApplyColoring( 1 - DefenderTeamIndex );
    }
    else if( !IsControllable() ) // display inactive
    {
        ApplyColoring( 255 );
    }
    else // not caputred, but controllable
    {
        ApplyColoring( DefenderTeamIndex );
    }
}


function bool IsCaptured()
{
    return (GetStateName() == 'Captured');
}

function bool IsControllable()
{
    return (GetStateName() == 'Controllable');
}

function FlagCharging(Actor Other)
{
    AmbientSound = ChargingSound;
    ChargingPawn = Pawn(Other);
    bIsBeingCharged = true;
}

function FlagIdle()
{
    AmbientSound = None;
    ChargingPawn = None;
    bIsBeingCharged = false;
}

simulated function ApplyColoring( int TeamIndex )
{
    if ( PoleBase == None )
        return;

    if ( TeamIndex == 0 ) {
        CurrentTeamSkin = SkinRed;

        Ring.Skins[0] = class'xDomRing'.Default.RedTeamShader;
        Ring.RepSkin = class'xDomRing'.Default.RedTeamShader;
        Pole.Skins[0] = CurrentTeamSkin;
        Pole.RepSkin = CurrentTeamSkin;
        PoleBase.Skins[1] = CurrentTeamSkin;
        PoleBase.SecondRepSkin = CurrentTeamSkin;

        LightHue = 0;
        LightBrightness = 255;
        LightSaturation = 128;
    }
    else if ( TeamIndex == 1 ) {
        CurrentTeamSkin = SkinBlue;

        Ring.Skins[0] = class'xDomRing'.Default.BlueTeamShader;
        Ring.RepSkin = class'xDomRing'.Default.BlueTeamShader;
        Pole.Skins[0] = CurrentTeamSkin;
        Pole.RepSkin = CurrentTeamSkin;
        PoleBase.Skins[1] = CurrentTeamSkin;
        PoleBase.SecondRepSkin = CurrentTeamSkin;

        LightHue = 170;
        LightBrightness = 255;
        LightSaturation = 128;
    }
    else {
        CurrentTeamSkin = SkinWhite;

        Ring.Skins[0] = class'xDomRing'.Default.NeutralShader;
        Ring.RepSkin = class'xDomRing'.Default.NeutralShader;
        Pole.Skins[0] = CurrentTeamSkin;
        Pole.RepSkin = CurrentTeamSkin;
        PoleBase.Skins[1] = CurrentTeamSkin;
        PoleBase.SecondRepSkin = CurrentTeamSkin;

        LightBrightness=128;
        LightHue=255;
        LightSaturation=255;
    }
}

// ============================================================================
// States: Controllable = Can be attacked
// ============================================================================

state Controllable
{
    simulated event Tick(float DeltaTime)
    {
        local Pawn SomePawn;
        Super.Tick( DeltaTime );

        // test if someone is standing on the object
        if ( ChargingPawn == None )
            foreach TouchingActors(class'Pawn', SomePawn)
                Touch(SomePawn);
    }

    function Touch(Actor Other)
    {
        local byte TouchingTeamIndex;
        if ( Other.IsA('Pawn') && Pawn(Other).IsPlayerPawn() ) {
            TouchingTeamIndex = Pawn(Other).GetTeamNum();
            if ( TouchingTeamIndex != DefenderTeamIndex ) {
                FlagCharging( Other );
                ApplyColoring( TouchingTeamIndex );
                HighlightPhysicalObjective( false );
            }
        }
    }

    function UnTouch(Actor Other)
    {
        local byte TouchingTeamIndex;
        if ( Other.IsA('Pawn') && Pawn(Other).IsPlayerPawn() ) {
            TouchingTeamIndex = Pawn(Other).GetTeamNum();
            if ( TouchingTeamIndex != DefenderTeamIndex ) {
                FlagIdle();
            }
        }
        ApplyColoring( DefenderTeamIndex );
        HighlightPhysicalObjective( true );
    }

    function Timer()
    {
        if ( bIsBeingCharged ) {
            if ( ChargedAmount < MaxChargedAmount ) {
                ChargedAmount += ChargeTickAmt;
                if (ChargedAmount >= MaxChargedAmount) {
                    ChargedAmount = MaxChargedAmount;
                }
            } else {
                GotoState('Captured');
            }
        }
    }
}
// ============================================================================
// States: Has been fully charged
// ============================================================================

state Captured
{
    function Timer()
    {
        SetTimer(0,false);

        FlagIdle();

        ApplyColoring( 1 - DefenderTeamIndex );
        HighlightPhysicalObjective( false );
        ChargedAmount = MaxChargedAmount;
        DisableObjective( ChargingPawn );

        // trigger "END ROUND"
        ELTGame(Level.Game).EndRound(ERER_PoleTapped, ChargingPawn, "fully_charged");
    }
}
// ============================================================================
// States: Initial Idle State
// ============================================================================

auto state Idle
{
    function Timer()
    {
        // do nothing
    }
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=10
    bAlwaysRelevant=true
    bNetNotify=true

    // object id
    ObjectiveName="ELITE Objective"
    DefenderTeamIndex=255

    // charge speed and max amount
    ChargeTickAmt=4
    ChargeTickTime=0.1
    MaxChargedAmount=100
    ScoreForMaxCharge=1

    // charging radius
    bUseCylinderCollision=true
    CollisionRadius=135.000000
    CollisionHeight=80.000000

    // ambient sound
    ChargingSound=sound'WeaponSounds.LinkGun.BLinkGunBeam4'
    SoundRadius=255
    SoundVolume=255

    // skins
    SkinRed=Texture'UCGeneric.SolidColors.Red'
    SkinBlue=Texture'UCGeneric.SolidColors.Blue'
    SkinWhite=Texture'UCGeneric.SolidColors.White'

    bReplicateObjective=true
    bTeamControlled=false
    bCollideActors=true
    bDynamicLight=true
    bNoDelete=false
    bStatic=false
    bHidden=false
    bStasis=false
    bUnlit=true

    LightType=LT_SubtlePulse
    LightEffect=LE_QuadraticNonIncidence
    LightRadius=24
    LightBrightness=128
    LightHue=255
    LightSaturation=255
}
