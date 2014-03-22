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
 * ELTRoundGameHUD
 *
 * We have no use for " X seconds left " annoucements.
 *
 * Too bad they had to put this into the HUD class.
 * This feature will probably get lost with other HUD mods
 * like UTComp, i guess...
 *
 * Any Ideas?
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage GameInfo
 * @version $wotgreal_dt: 01/01/2013 10:32:43 PM$
 */
class ELTRoundGameHUD extends HUDCTeamDeathMatch;

function CheckCountdown(GameReplicationInfo GRI)
{
    // SILENCE!
}
