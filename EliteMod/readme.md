Elite
=====

Custom 3v3 GameType for UT2004
http://elitemod.info

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

