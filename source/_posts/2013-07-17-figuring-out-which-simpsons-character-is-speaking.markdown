---
layout: post
title: "Figuring out which Simpsons character is speaking"
date: 2013-07-17 11:36
comments: true
categories:
    - simpsons
    - percept
    - machine learning
    - ML
    - clustering
    - python
---

You probably have a favorite Simpsons character.  Maybe you hope to someday [block out the sun](http://en.wikipedia.org/wiki/Who_Shot_Mr._Burns%3F), Mr. Burns style, maybe you enjoy Homer's skill in [averting meltdowns](http://en.wikipedia.org/wiki/Homer_Defined), or maybe you identify with Lisa's struggles for acceptance.  Through its characters, the Simpsons made a huge impact on a generation, and although the show is still running, my best memories will be of the [early seasons](http://deadhomersociety.com/zombiesimpsons/).

I recently wanted to do some linguistic analysis of Simpsons episodes.  To my surprise, I found that it is impossible to find Simpsons episodes scripts with information about who is speaking which line.  You can find [episode capsules](http://snpp.com/episodes/7G10.html) on snpp.com, but they feature only quotes from the episodes.  Simpsoncrazy has some [scripts](http://www.simpsoncrazy.com/scripts), but not enough for any real analysis.  You can find complete [transcripts](http://www.springfieldspringfield.co.uk/view_episode_scripts.php?tv-show=the-simpsons&episode=s01e01), but they lack any information on who is speaking when.

Here is a (very confusing) sample of a transcript:

```
I think the boy's hurt.
Just give him a nickel and let's get going! I think we should call an ambulance, sir.
Hey, cool.
I'm dead! Please hold on to the handrail.
Do not spit over the side.
Aunt Hortense.
Great-grandpa Simpson.
```

I immediately set about to correct this glaring omission.  Rather that sit down and manually label each episode with speaker information, I decide to use the power of the computer to do it for me.  To quote Homer, "Don't worry, head.  The computer will do our thinking now."

I will follow this post up with a technical one, but for now, you can find all of my code [here](https://github.com/VikParuchuri/simpsons-scripts).

Get the transcripts!
--------------------------------------------

Our first step is to grab the scripts and the transcripts.  The scripts have the information we need (lines and who spoke them):

```
Moe:  [answering the phone] Flaming Moe's.
Bart: Uh, yes, I'm looking for a friend of mine.  Last name Jass.  First name
      Hugh.
Moe:  Uh, hold on, I'll check.  [calling]  Hugh Jass!  Somebody check the
      men's room for a Hugh Jass!
Hugh: Uh, I'm Hugh Jass.
Moe:  Telephone.  [hands over the receiver]
Hugh: Hello, this is Hugh Jass.
Bart: [surprised]  Uh, hi.
Hugh: Who's this?
Bart: Bart Simpson.
Hugh: Well, what can I do for you, Bart?
Bart: Uh, look, I'll level with you, Mister.  This is a crank call that
      sort of backfired, and I'd like to bail out right now.
Hugh: All right.  Better luck next time. [hangs up]  What a nice young man.
```

So, we have the scripts and transcripts, right? (It's amazing how easy it is to do this step if you just decide that you have done it).  We are going to use the scripts to train the computer to figure out who is speaking in the transcripts.

Just like it is difficult to decide which one of the 5000 varieties of soap at the supermarket is the correct one, it is equally difficult for a computer to decide which one of 50+ characters is speaking a line.  We are going to figure out which characters talk in a similar way to others, and group them together, based on our scripts.


