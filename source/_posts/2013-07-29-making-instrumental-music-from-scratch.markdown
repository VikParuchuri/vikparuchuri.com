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

* Calibrate track generation by reading in a lot of MIDI tracks
* Generate instrumental tracks with various instruments
* Combine the instrumental tracks to make songs
* Convert the songs into sound
* Judge the quality of the sound
* Now that we know which songs are good and which songs are bad, remove the bad songs, generate new songs, and repeat

One important thing to note is that we can analyze (in fact, we have to analyze) a lot of songs to calibrate the process by which we do the instrumental track generation, the first step.  So we can generate tracks that take on the characteristics of any genre we want.  We are also indebted to the human composers and artists who created the music in the first place.  In my case, I got the instrumental tracks from [midi world](http://www.midiworld.com/) and [midi archive](http://midi-archive.com/).  A lot of the free midi sites use sessions to discourage scraping, and these were the only two I could find that do not have such provisions.

MIDI
------------------------------------

MIDI was standardized in 1983, and defines a protocol that allows instruments to communicate easily.  It enables different instruments to be placed on different channels.  It also encodes instrument notes by specifying pitch, velocity, and duration.  Tempo tracks define timing information, such as [MPQN](http://nokturnal.pl/home/atari/midi_delta) and BPM.










