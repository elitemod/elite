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
 * ELTObjectiveBase
 * Clone of xDomBase
 *
 * This is still very dirty. The interface is simply. I should rewrite
 * it completely, because there isn't much left of xDom anyway.
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 24/12/2012 4:48:11 PM$
 */
class ELTObjectiveBase extends GameObjective;

#exec OBJ LOAD FILE=UCGeneric.utx

// ============================================================================
// Replication
// ============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        bControllable, bIsBeingCharged, ChargedAmount;
}

// ============================================================================
// Variables
// ============================================================================

// actors
var ELTObjectivePole PoleStaticMesh;  // a smesh in a smesh that is a nav point

// configurable
var() sound ChargingSound;      // sound played when an attacker is standing on it
var() int MaxChargedAmount;     // maximum amount that can be charged until score
var() int ScoreForMaxCharge;    // points awarded for fully charging the pole

// internal
var Pawn ChargingPawn;          // pawn who is currently charging up
var bool bControllable;         // can be charged
var bool bIsBeingCharged;       // an attacker is standing on it.
var int ChargedAmount;          // current amount
var float ChargeTickTime;       // charge timer, seconds, or fraction
var int ChargeTickAmt;          // amount to charge per tick (time*amt<=max)


var(Material) Material DomCombiner[2];
var(Material) Material CRedState[2];
var(Material) Material CBlueState[2];
var(Material) Material CNeutralState[2];
var(Material) Material CDisableState[2];

var(Material) Shader   DomShader;
var(Material) Material SRedState;
var(Material) Material SBlueState;
var(Material) Material SNeutralState;
var(Material) Material SDisableState;

var(Material) float    PulseSpeed;
var xDOMLetter         DomLetter;
var xDOMRing           DOMRing;
var transient byte     NoPulseAlpha;
var           vector    EffectOffset;

// ============================================================================
// Implementation
// ============================================================================

simulated function PostNetReceive()
{
    if ( !bControllable || DefenderTeamIndex > 2 )
        DisplayAsInactive();
    else if ( bIsBeingCharged )
        DisplayAsAttacked();
    else
        DisplayAsSafe();
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
        DomRing = Spawn(class'XGame.xDomRing',self,,Location+EffectOffset,Rotation);
        PoleStaticMesh = spawn(class'ELTObjectivePole',self,,Location);

        // initial state
        bControllable = false;
        bActive = false;

        DisplayAsInactive();

        // start timer
        SetTimer(ChargeTickTime, true);
    }
}

function bool TellBotHowToDisable(Bot B)
{
    if ( bControllable || (VSize(B.Pawn.Location - Location) > 1024) )
        return B.Squad.FindPathToObjective(B,self);

    if ( B.Enemy != None )
        return false;

    B.WanderOrCamp(true);
    return true;
}

//=============================================================================
// Display Helpers
//=============================================================================

simulated function DisplayAsAttacked()
{
    AmbientSound = ChargingSound;

    if ( DefenderTeamIndex == 1 )
        ApplyRedColoring();
    else if ( DefenderTeamIndex == 0 )
        ApplyBlueColoring();
    else
        Warn("## ELTObjectiveBase - DisplayAsAttacked(): Bad DefenderTeamIndex !! ");
}

simulated function DisplayAsSafe()
{
    AmbientSound = none;

    if ( DefenderTeamIndex == 0 )
        ApplyRedColoring();
    else if ( DefenderTeamIndex == 1)
        ApplyBlueColoring();
    else
        Warn("## ELTObjectiveBase - DisplayAsSafe(): Bad DefenderTeamIndex !! ");
}

simulated function DisplayAsInactive()
{
    AmbientSound = none;
    ApplyNeutralColoring();
}

//=============================================================================
// Actor Triggers
//=============================================================================

function Touch(Actor Other)
{
    local int TouchingTeamIndex, AttackingTeamIndex;

    if ( bDisabled || (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() )
        return;

    if ( !bControllable ) {
        DisplayAsInactive();
    }
    else if ( !bIsBeingCharged )
    {
        TouchingTeamIndex = Pawn(Other).PlayerReplicationInfo.Team.TeamIndex;
        AttackingTeamIndex = 1 - DefenderTeamIndex;

        // only react to an valid attacker
        if ((AttackingTeamIndex == TouchingTeamIndex) && (AttackingTeamIndex < 2))
        {
            bIsBeingCharged = true;
            ChargingPawn = Pawn(Other);
            DisplayAsAttacked();
        }
    }
}

function UnTouch(Actor Other)
{
    local int TouchingTeamIndex, AttackingTeamIndex;

    if ( bDisabled || (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() )
        return;

    if ( !bControllable ) {
        DisplayAsInactive();
    }
    else if ( bIsBeingCharged )
    {
        TouchingTeamIndex = Pawn(Other).PlayerReplicationInfo.Team.TeamIndex;
        AttackingTeamIndex = 1 - DefenderTeamIndex;

        if ((AttackingTeamIndex == TouchingTeamIndex) && (AttackingTeamIndex < 2))
        {
            bIsBeingCharged = false;
            ChargingPawn = none;
            DisplayAsSafe();
        }
    }
}

//=============================================================================
// Charging Timer
//=============================================================================

simulated function Timer()
{
    if ( !bDisabled && bControllable && bIsBeingCharged ) {

        if ( ChargedAmount < MaxChargedAmount ) {
            ChargedAmount += ChargeTickAmt;
            if (ChargedAmount >= MaxChargedAmount) {
                ChargedAmount = MaxChargedAmount;
            }
        } else { // charge full

            ChargedAmount = MaxChargedAmount;
            AmbientSound = none;

            if ( DefenderTeamIndex == 0 ) {
                ApplyBlueColoring(); // blue captured from defending red
            } else {
                ApplyRedColoring(); // red captured from defending blue
            }

            // successfully disabled
            bDisabled = true;
            DisabledBy = ChargingPawn.PlayerReplicationInfo;

            // sync
            NetUpdateTime = Level.TimeSeconds - 1;

            // end elite round
            ELTGame(Level.Game).EndRound(ERER_PoleTapped, ChargingPawn, "fully_charged");

            ChargingPawn = none;
        }
    }
}

//=============================================================================
// Animation Stuff from DOM
//=============================================================================

simulated function float Pulse( float x )
{
    if ( x < 0.5 )
        return 2.0 * ( x * x * (3.0 - 2.0 * x) );
    else
        return 2.0 * (1.0 - ( x * x * (3.0 - 2.0 * x) ));
}

simulated function Tick( float t )
{
    local float f;
    local float alpha;
    local Pawn SomePawn;

    Super.Tick(t);

    // test if someone is standing on the object
    if ( bControllable && ((ChargingPawn == None) || !ChargingPawn.IsPlayerPawn()) ) {
        foreach TouchingActors(class'Pawn', SomePawn) {
            if ( SomePawn.IsPlayerPawn() )
                Touch ( SomePawn );
            break;
        }
    }

    if ( DomShader != None && PulseSpeed != 0.0) {
        if ( bControllable ) {
            f = Level.TimeSeconds * PulseSpeed;
            f = f - int(f);
            alpha = 255.0;
            ConstantColor(DomShader.SpecularityMask).Color.A = Pulse(f) * alpha;
        } else {
            ConstantColor(DomShader.SpecularityMask).Color.A = NoPulseAlpha;
        }
    }
}

simulated function SetShaderStatus( Material mat1, Material mat2, Material mat3 )
{
    if( DomCombiner[0] != none )
        Combiner(DomCombiner[0]).Material1 = mat1;
    if( DomCombiner[1] != None )
        Combiner(DomCombiner[1]).Material1 = mat3;
    if( DomShader != none ) {
        if (PulseSpeed != 0.0)
            DomShader.Specular = mat2;
        else
            DomShader.Diffuse = mat2;
    }
}

//=============================================================================
// Color Settings for each state
//=============================================================================

simulated function ApplyBlueColoring()
{
    if ( DomRing == None || PoleStaticMesh == None )
        return;

    if ( !bControllable )
        return;

    LightType = LT_SubtlePulse;
    LightHue = 170;
    LightBrightness = 255;
    LightSaturation = 128;

    DomRing.bHidden = false;
    DomRing.Skins[0] = class'xDomRing'.Default.BlueTeamShader;
    DomRing.RepSkin = class'xDomRing'.Default.BlueTeamShader;

    PoleStaticMesh.SetTeamSkin( CBlueState[0] );
    SetShaderStatus(CBlueState[0],SBlueState,CBlueState[1]);
}

simulated function ApplyRedColoring()
{
    if ( DomRing == None || PoleStaticMesh == None )
        return;

    if ( !bControllable )
        return;

    LightType = LT_SubtlePulse;
    LightHue = 0;
    LightBrightness = 255;
    LightSaturation = 128;

    DomRing.bHidden = false;
    DomRing.Skins[0] = class'xDomRing'.Default.RedTeamShader;
    DomRing.RepSkin = class'xDomRing'.Default.RedTeamShader;

    PoleStaticMesh.SetTeamSkin( CRedState[0] );
    SetShaderStatus(CRedState[0],SRedState,CRedState[1]);
}

simulated function ApplyNeutralColoring()
{
    if ( DomRing == None || PoleStaticMesh == None )
        return;

    LightType = LT_SubtlePulse;
    LightBrightness=128;
    LightHue=255;
    LightSaturation=255;

    DomRing.bHidden = false;
    DomRing.Skins[0] = class'xDomRing'.Default.NeutralShader;
    DomRing.RepSkin = class'xDomRing'.Default.NeutralShader;

    PoleStaticMesh.SetTeamSkin( CNeutralState[0] );
    SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=40
    bReplicateObjective=true
    bAlwaysRelevant=true

    // object id
    ObjectiveName="ELITEv10a.Elite Base"
    DefensePriority=255
    DefenderTeamIndex=255
    ObjectivePriority=0

    // charge speed and max amount
    //    ChargingSound=sound'WeaponSounds.LinkGun.BLinkGunBeam4'
    ChargingSound=sound'MenuSounds.J_MouseOver'
    ChargeTickTime=0.1
    ChargeTickAmt=4
    MaxChargedAmount=100
    ScoreForMaxCharge=1

    // charging radius
    bUseCylinderCollision=true
    CollisionRadius=135.000000
    CollisionHeight=80.000000

    // initial flags
    bControllable=false

    // ambient sound
    SoundRadius=255
    SoundVolume=255

    // display and engine flags
    bHidden=false
    bStasis=false
    bStatic=false
    bUnlit=true
    bNoDelete=false
    bCollideActors=true
    bNetNotify=true
    bTeamControlled=true
    bDynamicLight=true

    DrawType=DT_StaticMesh
    StaticMesh=XGame_rc.DominationPointMesh
    Skins(0)=Texture'XGameTextures.DominationPointTex'
    Skins(1)=XGameShaders.DomShaders.DomPointACombiner
    Style=STY_Normal

    LightType=LT_SubtlePulse
    LightEffect=LE_QuadraticNonIncidence
    LightRadius=12
    LightBrightness=128
    LightHue=255
    LightSaturation=255

    DrawScale=1.60000
    EffectOffset=(X=0.0,Y=0.0,Z=860.0)
    PrePivot=(X=0.0,Y=0.0,Z=56.0)
    bAutoAlignToTerrain=False

    DomCombiner(0)=XGameShaders.DomShaders.DomACombiner
    CRedState(0)=Texture'UCGeneric.SolidColors.Red'
    CBlueState(0)=Texture'UCGeneric.SolidColors.Blue'
    CNeutralState(0)=Texture'UCGeneric.SolidColors.White'
    CDisableState(0)=Texture'UCGeneric.SolidColors.Black'
    DomShader=XGameShaders.DomShaders.PulseAShader
    SRedState=Texture'XGameShaders.DomShaders.RedGrid'
    SBlueState=XGameShaders.DomShaders.BlueGrid
    SNeutralState=XGameShaders.DomShaders.GreyGrid
    SDisableState=XGameShaders.DomShaders.GreyGrid

    PulseSpeed=2.0
    NoPulseAlpha=128
    DestructionMessage=""
}
