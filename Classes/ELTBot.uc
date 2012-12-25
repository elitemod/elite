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
 * EliteBot
 * Controller for Bots
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Controllers
 * @version $wotgreal_dt: 25/12/2012 1:07:30 PM$
 */
class ELTBot extends xBot;

// ============================================================================
// Implementation
// ============================================================================

function SetPawnClass(string inClass, string inCharacter)
{
    if ( inClass != "" ) {
        inClass = "EliteMod.ELTPawn";
    }
    super.SetPawnClass(inClass, inCharacter);
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    PlayerReplicationInfoClass=class'EliteMod.ELTPlayerReplication'
    PawnClass=class'EliteMod.ELTPawn'
    bAdrenalineEnabled=False
}
