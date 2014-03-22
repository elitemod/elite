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
 * ELTMapMutator
 *
 * Mutator for dealing with pickup and weapon replacements
 * This one also replaces Assault PlayerSpawnManagers and our
 * EliteMapUtils dummies
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 02.02.2014 5:58:19 $
 */
class ELTMapMutator extends Mutator;

var name WeaponName[3];

// ============================================================================
// Implementation
// ============================================================================

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
    if ( Other.IsA(WeaponName[0])
        || Other.IsA(WeaponName[1])
        || Other.IsA(WeaponName[2])
        || Other.IsA('ELTPlayerSpawnManager')
        || Other.IsA('ELTObjective') )
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
    local ELTPlayerSpawnManager PSM;

    if ( Other.IsA('PlayerSpawnManager') )
    {
        // spawn our custom spawn manager at the same location
        PSM = Spawn(class'ELTPlayerSpawnManager',self,,Other.Location,Other.Rotation);

        // copy over settings
        PSM.AssaultTeam = PlayerSpawnManager(Other).AssaultTeam;
        PSM.PlayerStartTeam = PlayerSpawnManager(Other).PlayerStartTeam;
        PSM.bAllowTeleporting = PlayerSpawnManager(Other).bAllowTeleporting;
        PSM.bEnabled = PlayerSpawnManager(Other).bEnabled;

        // disable and destroy the assault-mod psm
        PlayerSpawnManager(Other).bEnabled = false;
        Other.Destroy();
        return false;
    }

    if ( Other.IsA('EliteMapObjective') )
    {
        ReplaceWith(Other, "EliteMod.ELTObjective");
        return false;
    }

    if ( Other.IsA('Weapon') )
    {
        if ( !Other.IsA(WeaponName[0]) && !Other.IsA(WeaponName[1]) && !Other.IsA(WeaponName[2]) ) {
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
    WeaponName[2]=ELTLightning

    GroupName="Arena"
    IconMaterialName="MutatorArt.nosym"
    FriendlyName="ELITE Map Mutator"
    Description="USED INTERNALLY. Clean the level from all items/pickups. Replace weapons with Elite weapons."

    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bNetTemporary=true
}
