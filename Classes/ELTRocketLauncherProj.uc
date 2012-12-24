//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ELTRocketLauncherProj extends RocketProj;

var NewLinkTrail FlashyTrail;

// ============================================================================
// Implementation
// ============================================================================

simulated function Destroyed()
{
    if ( FlashyTrail != None )
        FlashyTrail.Destroy();

    Super.Destroyed();
}

simulated function PostBeginPlay()
{
    if ( Level.NetMode != NM_DedicatedServer) {
        FlashyTrail = Spawn(class'NewLinkTrail',self);
        SmokeTrail = Spawn(class'EliteMod.ELTRocketLauncherSmoke',self);
        Corona = Spawn(class'RocketCorona',self);
    }

    Dir = vector(Rotation);
    Velocity = speed * Dir;
    if (PhysicsVolume.bWaterVolume) {
        bHitWater = True;
        Velocity=0.6*Velocity;
    }
    super(Projectile).PostBeginPlay();
}

// ============================================================================
// Defaults
// ============================================================================

DefaultProperties
{
    speed=2800.0
    MaxSpeed=2800.0
    Damage=1.0
    DamageRadius=220.0
    MomentumTransfer=50000
}
