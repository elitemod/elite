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
 * ELTObjectivePole
 *
 * This is the large blocking pole in the center of the ELTObjectiveBase.
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 24/12/2012 4:48:33 PM$
 */
class ELTObjectivePole extends Actor;

// ============================================================================
// Variables
// ============================================================================

var(Material) Material      CurrentSkin;

// ============================================================================
// Replication
// ============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        CurrentSkin;
}

// ============================================================================
// Implementation
// ============================================================================

simulated function SetTeamSkin(Material NewSkin)
{
    CurrentSkin = NewSkin;
}

simulated function Tick( float t )
{
    Super.Tick(t);
    Skins[0] = CurrentSkin;
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true

    // TODO: crappy mesh, outsource
    StaticMesh=StaticMesh'Plutonic_BP2_static.Factory.SG_outer'

    CurrentSkin=Texture'UCGeneric.SolidColors.White'
    DrawType=DT_StaticMesh
    DrawScale3D=(X=0.6,Y=0.6,Z=2.8)
    PrePivot=(X=0,Y=0,Z=70)
    bUseCylinderCollision=False
    bCanBeDamaged=False

    bIgnoreEncroachers=True
    bCollideActors=True
    bCollideWorld=True
    bBlockActors=True
    bBlocksTeleport=True
    bBlockZeroExtentTraces=True
    bBlockKarma=True
    bBlockProjectiles=True
    bProjTarget=True

    bHidden=false
    bStasis=false
    bStatic=false

    bDynamicLight=true
    bUnlit=true
}
