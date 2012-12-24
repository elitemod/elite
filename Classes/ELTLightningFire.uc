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
 * EliteLightningFireMode
 * Manages ammo regen and fire rates
 *
 * @author m3nt0r
 * @package Elite
 * @package Weapons
 * @version $wotgreal_dt: 24/12/2012 7:23:31 PM$
 */
class ELTLightningFire extends SniperFire;

var float AmmoRegenTime;

// ============================================================================
// Implementation
// ============================================================================

function PlayFireEnd()
{
    super.PlayFireEnd();
    SetTimer(AmmoRegenTime / 10, true);
}

function Timer()
{
    if ( !Weapon.AmmoMaxed(0) )
        Weapon.AddAmmo(1,0);
    else
        SetTimer(0, false);
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    AmmoRegenTime=0.3
    AmmoClass=class'EliteMod.ELTLightningAmmo'
    AmmoPerFire=99
}
