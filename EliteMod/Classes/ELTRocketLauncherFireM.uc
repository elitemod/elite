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
 * ELTRocketLauncherFireM
 *
 * Regenerating Firemode (multi rockets)
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 8:07:47 PM$
 */
class ELTRocketLauncherFireM extends RocketMultiFire;

// ============================================================================
// Implementation
// ============================================================================

    // NOTE: we do not need another ammo regen here, because ammo is shared.

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    return Spawn(class'ELTRocketLauncherProj',,, Start, Dir);
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    AmmoClass=class'EliteMod.ELTRocketLauncherAmmo'
}
