//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ELTObjective extends ELTObjectiveBase;

function MakeControllable(byte CurrentAttackingTeam)
{
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
