---
layout: post
title: "Using the power of sound to figure out which Simpsons character is speaking"
date: 2013-07-18 23:55
comments: true
categories:
    - NLP
    - simpsons
    - R
    - python
    - ML
    - machine learning
---

[Earlier](/blog/figuring-out-which-simpsons-character-is-speaking), I looked at transcripts of Simpsons episodes and tried to figure out which character was speaking which line.

 This worked decently, but it wasn't great. It gave us memorable scenes like this one:

 ```
"Homer :  D'oh!  A deer!  A female deer."
"Marge :  Son, you're okay!"
"Bart :  Dad, I can't let you sell him. Stampy and I are friends. Ow!"
"Bart :  Dad, how would you like to be sold to an ivory dealer?"
"Bart :  Dad, you're sinking!  Huh?"
"Marge :  Get a rope, Bart.  No, that's okay."
 ```

 And this one:

 ```
"Homer :  I don't like this new director's cut."
"Secondary :  You're stealing a table?  I'm not stealin' it."
"Tertiary :  Ah. Is that my necktie you're wearing?  Souvenir."
"Bart :  Mom, what if there's a really bad, crummy guy who's going to jail, but I know he's innocent."
"Marge :  Well, Bart, your Uncle Arthur used to have a saying ''Shoot 'em all, and let God sort 'em out.'' Unfortunately, one day he put his theory into practice."
 ```

 And some not so memorable scenes:

 ```
"Homer :  Mmm, engineblock eggs."
"Marge :  Hey, it's morning, and Mom and Dad aren't home yet."
"Tertiary :  Hey. This isn't the Y.M.C.A."
"Homer :  Dispatch, this is Chief Wiggum back in pursuit of the rebelling women."
"Homer :  All right. Your current location?  Oh. Uh, I'm a I'm on a road. Looks to be asphalt."
 ```

Trying to identify who is speaking only by looking at the text is a bit like trying to walk in a straight line with your eyes closed.  There is a lot of information that you end up missing.

Imagine trying to identify which one of your friends said `Hey, how's it going?`.  Even if you know someone for years and years, you will never get any insight into whether or not they said that phrase.

Enter our friend, sound.  If we played you a sound clip of your friend saying the same phrase, you would almost instantly know who said it.  Audio has a lot of information in this context that text cannot convey, and if we want to accurately identify our Simpsons characters, we need to use it.

As we progress, keep in mind that the code for this is available [here](https://github.com/VikParuchuri/simpsons-scripts), but this is the non-technical explanation.  I will make a full technical post once I evaluate the various methods.

<!--more-->

Quantifying sound
--------------------------------------------------

Sound is a tricky thing.  It is pretty easy to look at a piece of text, and think of how a computer might process it, as computers work with text all the time.  It's a little different with sound, which can be very messy and indefinite.

Thankfully, we can exploit some properties of sound to ensure that it can be easily processed by computer.  The first is that all sound is a wave.

What we see below is a plot of the beginning of the simpsons intro music:

![intro music](../images/simpsons-audio/intro_sounds.png)

We can zoom in to actually see the lines:

![intro zoom](../images/simpsons-audio/intro_zoom.png)

One of the lines is the right side audio, and the left side audio is the blue.  It doesn't matter much which is which for our purposes, but let's say that blue is left and green is right.  Most audio now, including our Simpsons audio, is in stereo format, which means that there are 2 independent sources of sound.  For our purposes, it means that we have two streams of sound to look at.

You can see that sound has some obvious tendencies.  The sound is oscillating up and down, but the pattern is not always fixed, so one peak might be higher or lower than the one before it.  We can use these oscillations to differentiate between speakers.

Here is Homer speaking the line `Sure do! When you're 18,you're out the door!`:

![homer sound](../images/simpsons-audio/homer_sound.png)

And here is Lisa speaking the line `No, Dad, you promised if Bart and I got "C" averages, we could go to Kamp Krusty.`:

![lisa sound](../images/simpsons-audio/lisa_sound.png)

We can note distinct differences between the two.  A lot of this is due to the different words being spoken, but we can hope that at least some of it is due to the unique voice of Lisa as compared to Homer.

How do we do this?
---------------------------------------------------

When we start, we have subtitle files, which look like this:

```
282
00:17:32,523 --> 00:17:35,651
I am so Krunchy the Clown!
[ Belches ]

283
00:17:35,760 --> 00:17:37,955
All right. That's it.

284
00:17:38,062 --> 00:17:40,326
I've been scorched by Krusty before.

285
00:17:40,431 --> 00:17:42,899
I got a rapid heartbeat
from those Krusty Brand vitamins.

286
00:17:43,000 --> 00:17:45,468
My Krusty calculator
didn't have a seven or an eight!
```

We also have the episodes from some of the Simpsons seasons (well, I do, at least).

We want to do two main things:
* Correlate the lines in the subtitles to the lines in the videos
* Find a way to get things that we can use to predict with out of the videos

The first thing is relatively easy.  This line `00:17:32,523 --> 00:17:35,651` is timing information, that tells us that Barney is pretending to be Krusty from 17 minutes and 32 seconds into the episode until 17 minutes and 35 seconds into the video.  We can parse the subtitles to get the whole line, when the line started in seconds, and when the line ended in seconds.

