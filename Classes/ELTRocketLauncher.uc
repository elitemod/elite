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
 * ELTRocketLauncher
 *
 * The weapon all defenders get
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 8:01:59 PM$
 */
class ELTRocketLauncher extends RocketLauncher;

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    ItemName="ELITE Rocket Launcher Xtreme"
    bCanThrow=false
    FireModeClass(0)=ELTRocketLauncherFire
    FireModeClass(1)=ELTRocketLauncherFireM
    ELTRocketLauncherAmmo
}
