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
 * ELTRocketLauncherFireM
 *
 * Regenerating Firemode (multi rockets)
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 22/12/2012 8:51:44 PM$
 */
class ELTRocketLauncherFireM extends RocketMultiFire;

var float AmmoRegenTime;

function PlayFiring()
{
    Super.PlayFiring();
    SetTimer(AmmoRegenTime, true);
}

function Timer()
{
    if ( !Weapon.AmmoMaxed(0) )
        Weapon.AddAmmo(1,0);
    else
        SetTimer(0, false);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    return Spawn(class'ELTRocketLauncherProj',,, Start, Dir);
}

DefaultProperties
{
    AmmoRegenTime=0.8
    AmmoClass=class'EliteMod.ELTRocketLauncherAmmo'
}
