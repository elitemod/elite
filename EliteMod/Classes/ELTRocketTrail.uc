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
 * ELTRocketTrail
 * FX
 *
 * @author m3nt0r
 * @package Elite
 * @subpackage Weapons
 * @version $wotgreal_dt: 02/01/2013 2:06:22 AM$
 */
class ELTRocketTrail extends Emitter;

#exec OBJ LOAD FILE=AW-2004Particles.utx

function MakeBlue()
{
    if ( Emitters[0] != None )
    {
        Emitters[0].ColorScale[1].Color.R = 0;
        Emitters[0].ColorScale[2].Color.R = 0;
        Emitters[0].ColorScale[1].Color.B = 170;
        Emitters[0].ColorScale[2].Color.B = 255;
        Emitters[0].ColorScale[1].Color.G = 0;
        Emitters[0].ColorScale[2].Color.G = 0;
    }
}

function MakeRed()
{
    if ( Emitters[0] != None )
    {
        Emitters[0].ColorScale[1].Color.R = 255;
        Emitters[0].ColorScale[2].Color.R = 255;
        Emitters[0].ColorScale[1].Color.B = 0;
        Emitters[0].ColorScale[2].Color.B = 0;
        Emitters[0].ColorScale[1].Color.G = 0;
        Emitters[0].ColorScale[2].Color.G = 0;
    }
}

function Delay(float DelayTime)
{
    if ( Emitters[0] != None )
    {
        Emitters[0].InitialDelayRange.Min = DelayTime;
        Emitters[0].InitialDelayRange.Max = DelayTime;
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter18
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        UseRandomSubdivision=True
        ColorScale(1)=(RelativeTime=0.100000,Color=(G=255,R=96))
        ColorScale(2)=(RelativeTime=0.800000,Color=(G=255))
        ColorScale(3)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        StartLocationOffset=(X=-35.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.900000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.250000)
        StartSizeRange=(X=(Min=20.000000,Max=20.000000))
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.350000,Max=0.650000)
        StartVelocityRange=(X=(Min=400.000000,Max=400.000000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=3.000000
        Name="SpriteEmitter18"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter18'

    DrawScale=0.600000
    bNoDelete=false
    Physics=PHYS_Trailer
}

