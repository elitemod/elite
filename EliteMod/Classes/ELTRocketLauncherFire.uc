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
 * ELTRocketLauncherFire
 *
 * Regenerating Firemode
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Weapons
 * @version $wotgreal_dt: 25/12/2012 11:38:06 AM$
 */
class ELTRocketLauncherFire extends RocketFire;

var float AmmoRegenTime;

// ============================================================================
// Implementation
// ============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(AmmoRegenTime, true);
}

function Timer()
{
    Super.Timer();

    if ( !Weapon.AmmoMaxed(0) )
        Weapon.AddAmmo(1,0);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    return Spawn(class'EliteMod.ELTRocketLauncherProj',,, Start, Dir);
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    FireRate=0.3
    AmmoRegenTime=0.9
    AmmoClass=class'EliteMod.ELTRocketLauncherAmmo'
}
