Readme for Infinite Mario Bros
10:47 AM 12/25/2006


I stopped working on this project for three reasons;
1) I had to focus on my main project. This was just a fun side project.
2) I didn't feel comfortable abusing copyrighted material for non-personal use, and neither should you.
3) The competition this was an entry for ended.

I'm releasing the source code for this project since I've gotten quite a bit of email with really
good suggestions on how to make this better, but I don't have the time to implement them myself.

The code (/src/) is released as public domain, so you can do with it what you wish.
The art (/res/) is still copyright nintendo, so it's almost certainly NOT ok to do anything at all with it. Ask nintendo.

And, please, if you're going to make a bigger project out of this, please consider replacing the art with legal art.




About the code:

The code is basically undocumented, but should be readable anyway as it's fairly clean. The main entry points are
AppletLauncher and FrameLauncher. The main game is in MarioComponent.

"sonar" is the base of a software sound engine I've been working on. It's pretty nice, but there's a few bugs in it
(mostly timing based). It can easilly be ripped out and reused in another project.

The level editor isn't used for anything more than changing the behavior of blocks anymore. But I think there's still
code in there somewhere for loading a level instead of generating it, so if you want to reintroduce static levels,
you've got a nice base for a level editor there.

The game DOES support scrolling in the Y directions right out of the box! However, I didn't think it fit the retro feeling,
so I made all levels only one screen tall. ;)

The sprite package and class should be renamed into "entity" or "mobile" or something..


/ Markus Persson
http://www.mojang.com/notch/
notch@mojang.com