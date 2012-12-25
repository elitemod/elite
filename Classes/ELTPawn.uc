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
 * ELTPawn
 *
 * Used by players and bots. Enjoy! :)
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 25/12/2012 2:34:29 PM$
 */
class ELTPawn extends xPawn;

function TakeDrowningDamage()
{
    // no drowning
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if (!bIsCrouched && !bWantsToCrouch) {
        if (ClassIsChildOf(damageType, class'DamTypeRocket') && InstigatedBy == Self)
        {
            SetMovementPhysics();

            // rocket jump
            Velocity += (Momentum*1.6)/Mass;
            Velocity.Z = 3.2 * JumpZ;

            SetPhysics(PHYS_Falling);
            return;
        }
    }
    super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
}


DefaultProperties
{

}
