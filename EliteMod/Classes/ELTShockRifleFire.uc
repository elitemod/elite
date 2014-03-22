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
 * ELTShockRifleFire
 *
 * Regenerating Firemode
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Weapons
 * @version $wotgreal_dt: 24/12/2012 8:08:28 PM$
 */
class ELTShockRifleFire extends ShockBeamFire;

var float AmmoRegenTime;

// ============================================================================
// Implementation
// ============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(AmmoRegenTime / 10, true);
}

function Timer()
{
    if ( !Weapon.AmmoMaxed(0) )
        Weapon.AddAmmo(1,0);
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    AmmoPerFire=99
    AmmoRegenTime=0.3
    AmmoClass=class'EliteMod.ELTShockRifleAmmo'
}
