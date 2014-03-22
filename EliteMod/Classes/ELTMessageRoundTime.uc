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
 * EliteMessageTimer
 *
 * @author m3nt0r
 * @package Elite
 * @package Broadcasts
 * @version $wotgreal_dt: 01/01/2013 10:40:14 PM$
 */
class ELTMessageRoundTime extends CriticalEventPlus;

var name CountDown[5];

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
    return  "Round ending soon";
}

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    if ( (Switch > 0) && (Switch <= 5) && (P.GameReplicationInfo != None) && (P.GameReplicationInfo.Winner == None) )
    {
        P.QueueAnnouncement( default.CountDown[Switch-1], 1, AP_InstantOrQueueSwitch, 1 );
    }
}


// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
    bIsConsoleMessage=false
    bFadeMessage=True
    bIsUnique=True
    FontSize=0
    StackMode=SM_Down
    PosY=0.10
    Lifetime=1
    DrawColor=(R=255,G=255,B=0,A=255)
    bBeep=False

    CountDown(0)=One
    CountDown(1)=Two
    CountDown(2)=Three
    CountDown(3)=Four
    CountDown(4)=Five
}
