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
 * EliteMessageObjective
 * Inform all active players that the game objective is now controllable
 *
 * @author m3nt0r
 * @package Elite
 * @package Broadcasts
 * @version $wotgreal_dt: 01/01/2013 10:17:44 PM$
 */
class ELTMessageObjective extends LocalMessage;

// ============================================================================
// Variables
// ============================================================================

var localized string MSG[4];

// ============================================================================
// Implementation
// ============================================================================

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch( Switch )
    {
        case 0 : return default.MSG[0];
        case 1 : return default.MSG[1];
        case 2 : return default.MSG[2];
        case 3 : return default.MSG[3];
    }

    return default.MSG[Min(Switch,1)];
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    MSG(0)="Pole is now active!" // shown to playing attacker
    MSG(1)="Pole became active. Defend!" // shown to playing defenders
    MSG(2)="Pole became active." // shown to DEAD attacker / specs
    MSG(3)="Pole became active." // shown to DEAD defenders / specs

    bComplexString=false
    bFadeMessage=True
    bIsSpecial=True
    bIsUnique=True
    Lifetime=4
    bBeep=False

    DrawColor=(R=255,G=0,B=0)
    FontSize=1

    StackMode=SM_Down
    PosY=0.242
}
