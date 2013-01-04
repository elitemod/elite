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
 *
 * This is the large blocking pole in the center of the ELTObjectiveBase.
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 25/12/2012 12:20:40 PM$
 */
class ELTObjectiveBase extends Actor;

#exec OBJ LOAD FILE=UCGeneric.utx
#exec OBJ LOAD FILE=XGameTextures.utx

var Material    SecondRepSkin;

replication
{
    reliable if (Role == ROLE_Authority)
        SecondRepSkin;
}

simulated event PostNetReceive()
{
    Skins[1] = SecondRepSkin;
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    RemoteRole=ROLE_DumbProxy
    NetUpdateFrequency=100
    bAlwaysRelevant=true
    bNetNotify=true

    // TODO: crappy mesh, outsource
    StaticMesh=XGame_rc.DominationPointMesh
    Skins(0)=Texture'XGameTextures.DominationPointTex'
    Skins(1)=Texture'UCGeneric.SolidColors.White'

    DrawType=DT_StaticMesh
    DrawScale=1.60000
    PrePivot=(X=0.0,Y=0.0,Z=56.0)
    bAutoAlignToTerrain=False

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
