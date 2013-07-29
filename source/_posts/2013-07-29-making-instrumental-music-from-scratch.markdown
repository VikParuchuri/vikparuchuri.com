---
layout: post
title: "Making instrumental music from scratch"
date: 2013-07-29 08:44
comments: true
categories:
    - R
    - python
    - music
    - markov chains
    - genetic algorithms
    - machine learning
---

I recently posted about [automatically making music](http://www.vikparuchuri.com/blog/evolve-your-own-beats-automatically-generating-music).  The method that I used pulled out interesting sequences of music from existing songs and remixed them.  While this method worked reasonably well, it also didn't give me full control over the basics of the music; I wasn't actually specifying which instruments to use, or what notes to play.

Maybe I'm being a control freak, but it would be nice to have complete control over exactly what is being played and how it is being played, rather than making a "remixing engine" (although the remixing engine is cool).  It would also kind of fulfill my on-and-off ambition of playing the guitar (I'm really bad at it).

Enter the [MIDI format](http://en.wikipedia.org/wiki/MIDI).  The MIDI format lets you specify pitch, velocity, and instrument.  You can specify different instruments in different tracks, and then combine the tracks to make a song.  You can write the song into what is basically a text file, after which you can covert it to sound (I'll describe this process a bit more further down).  Using the power of MIDI, we can quickly define music from the ground up using a computer, and then play it back.

Now that we know that something like MIDI exists, we can define our algorithm like this:

* Generate instrumental tracks with various instruments
* Combine the instrumental tracks to make songs
* Convert the songs into sound
* Judge the quality of the sound
* Now that we know which songs are good and which songs are bad, remove the bad songs, generate new songs, and repeat






