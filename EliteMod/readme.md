Elite
=====

Custom 3v3 GameType for UT2004
http://elitemod.info

## About

This is a modification for Unreal Tournament 2004 by Epic Games, Inc. A complete gametype
emulating the popular Shootmania Elite mode, which is basically a mix of Unreal's original 
Assault, Domination and Arena gametypes. A match of 6 rounds where 1 outnumbered player has
to either kill the opposing team or capture a gameobjective within 60 seconds. Each player 
gets to attack at least once match. 


## Bugreporting

Signup on this site is very simple and stressfree. Please use the ISSUETRACKER on this website if 
you encounter any bugs. If no one reports, i can't fix them up until i'd notice them myself. Support
the mod by submitting reports, doesn't matter how small. Everything helps.

- https://github.com/elitemod/elite/issues

## Contributing

You are welcome to join me on this mod by simply writing/fixing some code. This is opensource, which
means you are free to write and submit patches if you feel like it. I believe in opensource and hope 
we can all benefit from this.

To contribute just create an account at GitHub (this site) and "FORK" the repository into your new 
account. Then you can make any changes you want and post them online using their client. If you're 
satisfied with your edits and think the changes are useful for all just sent me a "PULL REQUEST" so
i can review them. Once i accept them into this repo the changes will be part of any future release.

- https://github.com/elitemod/elite/pulls

## Building

Since i have a strong web-background and usually work on a Mac i utilized Ruby-Make to create an easy 
build script that helps preparing a release using **UMake**. There are one click packages out there that 
will install the required "rake" console command on Windows. I used: ```rubyinstaller-1.9.3-p327.exe```

With this installed just go into the source folder via commandline and type ```rake``` to start the 
build. If you want to create a brandnew package just edit the "version.txt" and run "rake" again.

For UMAKE to work your copy should be at ```C:\umake.exe```

You will love it. It works like a charm for me. 

- http://tinyurl.com/umake12
- http://tinyurl.com/ruby193win

## Sourcecode

I will not go into great detail about the class design of this package here. It will be all
inside the Wiki at some point. I've created 3 gametypes because i found it more managable. The codebase
has been through a lot of refactoring and this was pretty much the most clean solution.

- ELTTeamGame -> (abstract) Setups playerteams, pawns, lives and weapons. 
- ELTRoundGame -> (abstract) Everything related to countdowns, spawn management, round counting
- ELTGame -> (final) Responsible for managing the gameobjective and scoring. 

Weapon related classes are easily identifiable by their prefix. 

- ELTLightning
- ELTRocket

Broadcast messages are prefixed with:

- ELTMessage

## Guidlines/Authoring

Write code with whatever you like, but please no tab characters. 4 spaces per tab will do fine :)

## License

GPL, GNU General Public License
Version 3, 29 June 2007

