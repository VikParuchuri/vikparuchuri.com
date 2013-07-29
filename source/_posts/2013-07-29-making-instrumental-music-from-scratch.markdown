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
* Generate instrumental tracks
* Combine the instrumental tracks to make songs
* Convert the songs into sound
* Judge the quality of the sound
* Now that we know which songs are good and which songs are bad, remove the bad songs, generate new songs, and repeat

One important thing to note is that we can analyze (in fact, we have to analyze) a lot of songs to calibrate the process by which we do the instrumental track generation, the first step.  So we can generate tracks that take on the characteristics of any genre we want.  We are also indebted to the human composers and artists who created the music in the first place.  In my case, I got the instrumental tracks from [midi world](http://www.midiworld.com/) and [midi archive](http://midi-archive.com/).  A lot of the free midi sites use sessions to discourage scraping, and these were the only two I could find that do not have such provisions.

MIDI
------------------------------------

MIDI was standardized in 1983 (but that doesn't make it any less cool), and defines a protocol that allows instruments to communicate easily.  It enables different instruments to be placed on different channels.  It also encodes instrument notes by specifying pitch, velocity, and duration.  Tempo tracks define timing information, such as [MPQN](http://nokturnal.pl/home/atari/midi_delta) and BPM.

We can write this information to a midi file in bytes.  [Here](http://www.midi.org/techspecs/midimessages.php) are the byte code formats for various midi events.

Byte code is a step between how we see files and data, and how computers store files and data.  For example, we can use a hex editor to see the hex representation of the word "Hello":

![bytes](../images/midi-music/bytes.png)

The midi format stores data in a similar format.

![midi bytes](../images/midi-music/midi_bytes.png)

Even from this brief glimpse of the midi file format, we can see that we don't want to be stuck directly editing midi files.  It would be quite painful.  Luckily, several people have written containers for midi.  These containers allow midi to be edited in natural ways using programming languages, without actually having to edit the files directly.  One of these is called [python-midi](https://github.com/vishnubob/python-midi), and is the editor I chose to use.

Python midi allows us to create instrumental tracks:

``` python
    [midi.ProgramChangeEvent(tick=0, channel=0, data=[0]),
    midi.NoteOffEvent(tick=20, channel=9, data=[42, 64]),
    midi.NoteOnEvent(tick=28, channel=9, data=[38, 90]),
    midi.NoteOnEvent(tick=0, channel=9, data=[42, 90]),
    midi.NoteOffEvent(tick=20, channel=9, data=[38, 64]),
    midi.NoteOffEvent(tick=0, channel=9, data=[42, 64]),
    midi.NoteOnEvent(tick=28, channel=9, data=[42, 70]),
    midi.NoteOffEvent(tick=20, channel=9, data=[35, 64]),
    midi.NoteOffEvent(tick=0, channel=9, data=[42, 64]),
    midi.NoteOnEvent(tick=28, channel=9, data=[42, 58]),
    midi.EndOfTrackEvent(tick=0, data=[])]
```

A track is just a list of events.  The key events in a normal track are:

* ProgramChangeEvent - defines a change in instrument.  `data` defines which instrument is to be played, using [these codes](http://en.wikipedia.org/wiki/General_MIDI).
* NoteOnEvent - Defines a note that is to be played.  `tick` is how long to wait from the previous note to starting to play the current note.  `data` is made up of pitch and velocity.  Pitch controls the pitch of the note, and velocity is volume.  See [this](http://stackoverflow.com/questions/2038313/midi-ticks-to-actual-playback-seconds-midi-music) for a bit more info about ticks.
* NoteOffEvent - Turns off a note, and decays the sound naturally.  
* EndOfTrackEvent - designates the end of the track

We can also make tempo tracks:

``` python
[midi.SetTempoEvent(tick=0, data=[22, 118, 30]),
  midi.SetTempoEvent(tick=100, data=[22, 195, 83]),
  midi.SetTempoEvent(tick=100, data=[23, 60, 157]),
  midi.SetTempoEvent(tick=100, data=[33, 175, 17]),
  midi.SetTempoEvent(tick=10, data=[27, 141, 27]),
  midi.SetTempoEvent(tick=0, data=[28, 248, 239]),
  midi.SetTempoEvent(tick=0, data=[28, 225, 137]),
  midi.EndOfTrackEvent(tick=0, data=[])]
```

The tempo track defines the [microseconds per quarter note](http://nokturnal.pl/home/atari/midi_delta) and the beats per minute of the song, which essentially governs the pacing.

* SetTempoEvent - Sets the tempo of the instrumental tracks in a song.  `tick` is the same as in an instrumental track. 

We can combine one or more (I think more is possible, although I always use one) tempo tracks with multiple instrumental tracks to make a song.

We can then write this song to a file.  The file will be in the byte format that we discussed earlier.  You can directly edit the file using a hex editor like [bless](http://home.gna.org/bless/) if you really want to.

Otherwise, you can convert the file into a sound file by using [fluidsynth](http://sourceforge.net/apps/trac/fluidsynth/) along with a [soundfont](http://sourceforge.net/apps/trac/fluidsynth/wiki/SoundFont).  Fluidsynth will turn the numbers for pitch, velocity, and instrument into notes.

Once we have our file converted (it will be in .wav format), we can listen to it directly or use tools like [oggenc](http://linux.die.net/man/1/oggenc) to convert the wav to another, smaller, file format.

Okay, now what?
--------------------------------------

MIDI is critical to what we want to do, and once we have the principles down, we can move to our next phase.  The next phase is to define an algorithm to automatically create instrumental and tempo tracks.

We will exploit [markov chains](https://en.wikipedia.org/wiki/Markov_chain) to make our basic tracks.  Markov chains essentially give us the probability of one state changing to another state.  For example, let's say that for the past 5 days, the weather was `Sunny, Cloudy, Sunny, Sunny, Sunny`.  So, after it was sunny, it was cloudy on one day, and sunny on two other days.  After it was cloudy, it was sunny on one day.  So, our system has two states, sunny and cloudy, and it transitions between those states with a certain probability.

We can create a markov chain:

![bytes](../images/midi-music/markov-chain.png)

If today was sunny, there would be a 66% chance of tomorrow being sunny, and a 33% chance of tomorrow being cloudy.  A markov chain is a fancy way of formalizing transitions between things.

It's when we combine markov chains with random number generators that we can do really interesting things.  Let's say that we want to predict how the weather for the next 5 days will be.  To start:

```
Starting (today's) weather = sunny
Iteration 1.  If number is <=66, pick sunny, else pick cloudy (by our diagram).  Random number = 67.
Weather = cloudy.
Iteration 2.  Only possible transition is to sunny, so pick sunny.
Weather = sunny.
Iteration 3.  Random number = 14.
Weather = sunny
Iteration 4.  Random number = 51.
Weather = sunny
Iteration 5.  Random number = 70.
Weather = cloudy
```

Our predictions for the next 5 days would be `[cloudy, sunny, sunny, sunny, cloudy]`.  If we went through the Markov chain a second time, we would get a completely different chain.  However, both chains would be based on past observations, and thus have an element of logic to them.

You can probably immediately see how this is applicable to music.  If we can figure out an appropriate chain, we can use a random number generator to automatically make tracks.

Learning probabilities for the markov chains
----------------------------------------------------

In order to learn the probabilities for the markov chains, we first have to get a lot of midi music. fddf
