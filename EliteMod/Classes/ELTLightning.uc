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
 * EliteLightningGun
 * Weapon
 *
 * @author m3nt0r
 * @package Elite
 * @package Weapons
 * @version $wotgreal_dt: 24/12/2012 7:21:59 PM$
 */
class ELTLightning extends SniperRifle;

// ============================================================================
// Implementation
// ============================================================================

/* disable zoom by always fire mode 0,
   superclass has zoom action hardcoded */
simulated function ClientStartFire(int mode)
{
    Super.ClientStartFire(0);
}

simulated function ClientStopFire(int mode)
{
    Super.ClientStopFire(0);
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    ItemName="ELITE Lightning Gun"
    FireModeClass(0)=Class'EliteMod.ELTLightningFire'
    FireModeClass(1)=Class'EliteMod.ELTLightningFire'
    bCanThrow=false
    bSniping=False
}
