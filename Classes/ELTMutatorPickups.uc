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
 * ELTMutatorPickups
 *
 * Mutator for dealing with pickup and weapon replacements
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 23/12/2012 1:10:11 PM$
 */
class ELTMutatorPickups extends Mutator;

var name WeaponName[2];

simulated function BeginPlay()
{
    local xPickupBase P;
    local Pickup L;

    foreach AllActors(class'xPickupBase', P)
    {
        P.bHidden = true;
        if (P.myEmitter != None)
            P.myEmitter.Destroy();
    }
    foreach AllActors(class'Pickup', L)
        if ( L.IsA('WeaponLocker') )
            L.GotoState('Disabled');

    Super.BeginPlay();
}

function bool AlwaysKeep(Actor Other)
{
    if ( Other.IsA(WeaponName[0]) || Other.IsA(WeaponName[1]) )
    {
        if ( NextMutator != None )
            NextMutator.AlwaysKeep(Other);

        return true;
    }

    if ( NextMutator != None )
        return ( NextMutator.AlwaysKeep(Other) );
    return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    Log("Check:"@Other);

    if ( Other.IsA('Weapon') )
    {
        if ( !Other.IsA(WeaponName[0]) && !Other.IsA(WeaponName[1]) ) {
            Level.Game.bWeaponStay = false;
            return false;
        }
    }

    if ( Other.IsA('Pickup') )
    {
        if ( Other.bStatic || Other.bNoDelete )
            Other.GotoState('Disabled');
        return false;
    }

    bSuperRelevant = 0;
    return true;
}

defaultproperties
{
    WeaponName[0]=ELTRocketLauncher
    WeaponName[1]=ELTShockRifle

    GroupName="Arena"
    IconMaterialName="MutatorArt.nosym"
    FriendlyName="ELITE Weapons"
    Description="Clean the level from weapons but always keep ELITE weapons."

    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true
}
