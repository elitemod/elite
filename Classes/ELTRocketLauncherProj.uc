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
 * ELTRocketLauncherProj
 * Projectile
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Weapons
 * @version $wotgreal_dt: 02/01/2013 1:56:28 AM$
 */
class ELTRocketLauncherProj extends RocketProj;

var ELTRocketTrail GlowEffect;

// ============================================================================
// Implementation
// ============================================================================

simulated function Destroyed()
{
    if ( GlowEffect != None )
        GlowEffect.Destroy();

    Super.Destroyed();
}

simulated function PostBeginPlay()
{
    local byte TeamNum;

    if ( Level.NetMode != NM_DedicatedServer) {
        GlowEffect = Spawn(class'EliteMod.ELTRocketTrail',self);
        Corona = Spawn(class'EliteMod.ELTRocketCorona',self);
    }

    if ( GlowEffect != None ) {
        TeamNum = Instigator.Controller.GetTeamNum();

        if ( TeamNum == 0 ) {
            GlowEffect.MakeRed();
            LightHue=255;
        }
        else if ( TeamNum == 1 ) {
            GlowEffect.MakeBlue();
            LightHue=170;
        }
    }

    Dir = vector(Rotation);
    Velocity = speed * Dir;
    if (PhysicsVolume.bWaterVolume) {
        bHitWater = True;
        Velocity=0.6*Velocity;
    }
    super(Projectile).PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    local float dist;

    if ( (GlowEffect != None) && (Instigator != None) && Instigator.IsLocallyControlled() )
    {
        if ( Role == ROLE_Authority )
            GlowEffect.Delay(0.1);
        else {
            dist = VSize(Location - Instigator.Location);
            if ( dist < 100 )
                GlowEffect.Delay(0.1 - dist/1000);
        }
    }
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    speed=2800.0
    MaxSpeed=2800.0
    Damage=1.0
    DamageRadius=220.0
    MomentumTransfer=50000

    // green
    LightBrightness=255
    LightSaturation=127
    LightHue=62
}
