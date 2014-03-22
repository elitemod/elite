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
 * ELTMessageDistance
 *
 * Display the shot distance in meters on the screen (bottom, center)
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Broadcasts
 * @version $wotgreal_dt: 24/12/2012 8:48:07 PM$
 */
class ELTMessageDistance extends CriticalEventPlus;

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
    return switch@"meters";
}

// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    bBeep=False
    bComplexString=False
    bFadeMessage=True
    bIsSpecial=True
    bIsUnique=True
    Lifetime=1

    DrawColor=(R=255,G=255,B=0)
    FontSize=2

    StackMode=SM_Up
    PosY=0.75
}
