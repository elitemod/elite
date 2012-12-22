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
 * ELTShockRifle
 *
 * The weapon all attackers get
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 22/12/2012 6:33:36 PM$
 */
class ELTShockRifle extends ShockRifle;

DefaultProperties
{
    ItemName="ELITE ShockRifle"
    bCanThrow=false
    FireModeClass(0)=ELTShockRifleFire
    FireModeClass(1)=ELTShockRifleFire
}
