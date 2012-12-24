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
 * ELTGameRules
 *
 * rules
 *
 * @author m3nt0r
 * @package Elite
 * @version $wotgreal_dt: 24/12/2012 2:13:22 AM$
 */
class ELTGameRules extends GameRules;

//
// Restart the game.
//
function bool HandleRestartGame()
{
    Log("## GameRules - HandleRestartGame");

    if ( (NextGameRules != None) && NextGameRules.HandleRestartGame() )
        return true;
    return false;
}

/* CheckEndGame()
Allows modification of game ending conditions.  Return false to prevent game from ending
*/
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    Log("## GameRules - CheckEndGame");
    Log("   - Winner:"@Winner);
    Log("   - Name:"@Winner.GetHumanReadableName());
    Log("   - Reason:"@Reason);

    if ( NextGameRules != None )
        return NextGameRules.CheckEndGame(Winner,Reason);

    return true;
}

/* CheckScore()
see if this score means the game ends
return true to override gameinfo checkscore, or if game was ended (with a call to Level.Game.EndGame() )
*/
function bool CheckScore(PlayerReplicationInfo Scorer)
{
    Log("## GameRules - CheckScore");
    Log("   - Name:"@Scorer.GetHumanReadableName()@", Kills:"@Scorer.Kills@" / Team:"@Scorer.Team.TeamIndex@", TeamScore:"@Scorer.Team.Score);

    if ( NextGameRules != None )
        return NextGameRules.CheckScore(Scorer);

    return false;
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
    Log("## GameRules - ScoreObjective");
    Log("   - Scorer:"@Scorer);
    Log("   - Name:"@Scorer.GetHumanReadableName());
    Log("   - Score:"@Score);

    if ( NextGameRules != None )
        NextGameRules.ScoreObjective(Scorer,Score);
}

function ScoreKill(Controller Killer, Controller Killed) {
    if ( Killer == None && Killed != None ) {
        super.ScoreKill(Killed, Killed); // suicide
        return;
    }
    super.ScoreKill(Killer, Killed);
}

