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
 * @version $wotgreal_dt: 22/12/2012 6:48:35 PM$
 */
class ELTRocketLauncherFireM extends RocketMultiFire;

var float AmmoRegenTime;

function PlayFireEnd()
{
    Super.PlayFireEnd();
    SetTimer(AmmoRegenTime, true);
}

function Timer()
{
    if ( !Weapon.AmmoMaxed(1) )
        Weapon.AddAmmo(1,1);
    else
        SetTimer(0, false);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Spawn(class'ELTRocketLauncherProj',,, Start, Dir);
    if ( P != None )
        p.Damage *= DamageAtten;
    return p;
}

DefaultProperties
{
    AmmoRegenTime=1.0
}
