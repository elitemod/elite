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
 * ELTRocketLauncherAmmo
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Weapons
 * @version $wotgreal_dt: 24/12/2012 8:03:02 PM$
 */
class ELTRocketLauncherAmmo extends RocketAmmo;

// ============================================================================
// Defaults
// ============================================================================

simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
    Log(" --- Use Ammo");

    if ( super.UseAmmo(AmountNeeded, bAmountNeededIsMax) ) {
        return true;
    }
    return false;
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    ItemName="ELITE RocketLauncher Ammo"
    MaxAmmo=6
    InitialAmount=6
}
