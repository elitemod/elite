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
 * ELTObjective
 *
 * The center of attention for this gametype.
 *
 * It has 3 different display states it may be in and always
 * starts as "Neutral". As the game progresses the GameInfo timer
 * may trigger "MakeControllable()" which will color the objective
 * according to the DefenderTeamIndex.
 *
 * ==== MAPPER WARNING ====
 * Although mappers could use this item directly, it is recommened to not
 * place it into their levels, as they would bind themselve to this package.
 * Mappers should use the dummy actor provided in EliteMapUtils package that does
 * not undergo default versioning (in other words: the filename will not change).
 *
 * @author m3nt0r
 * @package Elite
 * @package Objective
 * @version $wotgreal_dt: 24/12/2012 9:25:32 PM$
 */
class ELTObjective extends ELTObjectiveBase;

// ============================================================================
// Implementation
// ============================================================================

function MakeControllable(byte CurrentAttackingTeam)
{
    Log("--- MakeControllable ---");

    // allow touch() to work
    bControllable = true;
    bActive = true;

    // remove "disabled"
    bDisabled = false;
    DisabledBy = none;

    // set defending team
    SetTeam( 1 - CurrentAttackingTeam );

    DisplayAsSafe();

    // sync
    NetUpdateTime = Level.TimeSeconds - 1;

    HighlightPhysicalObjective( true );
}

simulated function Reset()
{
    ChargedAmount = 0;
    bIsBeingCharged = false;
    ChargingPawn = none;

    bDisabled = false;
    DisabledBy = none;

    bControllable = false;
    bActive = false;
    DisplayAsInactive();

    NetUpdateTime = Level.TimeSeconds - 1;
}


DefaultProperties
{

}
