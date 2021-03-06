/**
 * This file is part of the "Elite" gametype modification for UT2004
 *
 * Copyright (C) 2012-2014, m3nt0r <m3nt0r.de@gmail.com>
 * http://elite2k4.wordpress.com/
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
 * @version $wotgreal_dt: 29.01.2014 4:31:23 $
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
    if ( Level.NetMode != NM_DedicatedServer) {
        GlowEffect = Spawn(class'EliteMod.ELTRocketTrail',self);
        Corona = Spawn(class'EliteMod.ELTRocketCorona',self);
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

    if ( (GlowEffect != None) && (Instigator != None) && (Instigator.PlayerReplicationInfo.Team != None) ) {

        if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 ) {
            GlowEffect.MakeRed();
            LightHue=255;
        }
        else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 1 ) {
            GlowEffect.MakeBlue();
            LightHue=170;
        }
    }

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
