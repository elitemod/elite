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
 * EliteMapObjective
 * Placeable
 *
 * The center of attention for this gametype.
 *
 * This actor is only ment for mappers. It will be replaced
 * by ELTObjective once the game starts.
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 24/12/2012 5:06:32 PM$
 */
class EliteMapObjective extends Actor
    placeable;

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    bUnlit=true
    bHidden=false
    bStasis=false
    bStatic=false
    bNoDelete=false
    bCollideActors=true
    bAlwaysRelevant=true
    bDynamicLight=true

    DrawType=DT_StaticMesh

    StaticMesh=StaticMesh'XGame_rc.DominationPointMesh'
    Skins(0)=Texture'XGameTextures.DominationPointTex'
    Style=STY_Normal

    LightType=LT_SubtlePulse
    LightEffect=LE_QuadraticNonIncidence
    LightRadius=12
    LightBrightness=128
    LightHue=255
    LightSaturation=255

    DrawScale=1.60000
    PrePivot=(X=0.0,Y=0.0,Z=52.0)
    bAutoAlignToTerrain=False
}
