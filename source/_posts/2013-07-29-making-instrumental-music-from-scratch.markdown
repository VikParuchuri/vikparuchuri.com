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

I recently posted about [automatically making music](http://www.vikparuchuri.com/blog/evolve-your-own-beats-automatically-generating-music).  The algorithm that I made pulled out interesting sequences of music from existing songs and remixed them.  While this worked reasonably well, it also didn't have full control over the basics of the music; it wasn't actually specifying which instruments to use, or what notes to play.

Maybe I'm being a control freak, but it would be nice to have complete control over exactly what is being played and how it is being played, rather than making a "remixing engine" (although the remixing engine is cool).  It would also kind of fulfill my on-and-off ambition of playing the guitar (I'm really bad at it).

Enter the [MIDI format](http://en.wikipedia.org/wiki/MIDI).  The MIDI format lets you specify pitch, velocity, and instrument.  You can specify different instruments in different tracks, and then combine the tracks to make a song.  You can write the song into a file, after which you can covert it to sound (I'll describe this process a bit more further down).  Using the power of MIDI, we can define music from the ground up using a computer, and then play it back.

Now that we know that something like MIDI exists, we can define our algorithm like this:

* Calibrate track generation by reading in a lot of MIDI tracks
* Generate instrumental tracks and tempo tracks
* Combine the instrumental tracks to make songs
* Convert the songs into sound
* Judge the quality of the sound
* Now that we know which songs are good and which songs are bad, remove the bad songs, generate new songs, and repeat

One important thing to note is that we can analyze (in fact, we have to analyze) a lot of songs to calibrate the process by which we do the instrumental track generation, the first step.  So we can generate tracks that take on the characteristics of any genre we want.  We are also indebted to the human composers and artists who created the music in the first place.  This algorithm is less to replace them than to explore music creation in my own way.  All of the code for the algorithm is available [here](https://github.com/VikParuchuri/evolve-music).

I got instrumental tracks from [midi world](http://www.midiworld.com/) and [midi archive](http://midi-archive.com/).  A lot of the free midi sites use sessions to discourage scraping, and these were the only two I could find that do not have such provisions.

<a name="player"></a>

Below are some sample tracks created using the algorithm.  If the player below does not show up you may have to visit [my site](http://www.vikparuchuri.com/blog/making-instrumental-music-from-scratch#player) to see it.

<div>
    <div id="jquery_jplayer_1" class="jp-jplayer"></div>
    <div id="jp_container_1">
      <div class="jp-playlist">
        <ul>
          <li></li>
        </ul>
      </div>
       <div class="jp-type-single">
      <div class="jp-gui jp-interface">
        <ul class="jp-controls">
          <li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
          <li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
          <li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
          <li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
          <li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
          <li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
        </ul>
        <div class="jp-progress">
          <div class="jp-seek-bar">
            <div class="jp-play-bar"></div>
          </div>
        </div>
        <div class="jp-volume-bar">
          <div class="jp-volume-bar-value"></div>
        </div>
        <div class="jp-time-holder">
          <div class="jp-current-time"></div>
          <div class="jp-duration"></div>
          <ul class="jp-toggles">
            <li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
            <li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
          </ul>
        </div>
      </div>
      <div class="jp-title">
        <ul>
          <li>Bubble</li>
        </ul>
      </div>
      <div class="jp-no-solution">
        <span>Update Required</span>
        To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
      </div>
    </div>
    </div>
      <script type="text/javascript">
    $(document).ready(function(){

        var myPlaylist = new jPlayerPlaylist({
          jPlayer: "#jquery_jplayer_1",
          cssSelectorAncestor: "#jp_container_1"
        },
        [
          {
            title: "Heavy",
            oga:"http://www.vikparuchuri.com/downloads/code/07-25-2013-223535.ogg"
          }
        ],
        {
          playlistOptions: {
            enableRemoveControls: true
          },
          swfPath: "/javascripts",
          supplied: "oga",
          smoothPlayBar: true,
          keyEnabled: true,
          audioFullScreen: true
        });
        });
  </script>
</div>


<!--more-->

MIDI
------------------------------------

MIDI was standardized in 1983 (but that doesn't make it any less cool), and defines a protocol that allows instruments to communicate easily.  It enables different instruments to be placed on different channels.  It also encodes instrument notes by specifying pitch, velocity, and duration.  Tempo tracks define timing information, such as [MPQN](http://nokturnal.pl/home/atari/midi_delta) and BPM.

We can write this information to a midi file in bytes.  [Here](http://www.midi.org/techspecs/midimessages.php) are the byte code formats for various midi events.

Byte code is a step between how we see files and data, and how computers store files and data.  For example, we can use a hex editor to see the hex representation of the word "Hello":

![bytes](../images/midi-music/bytes.png)

The midi format stores data in a similar way:

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

A track is just a list of events, in order.  Each event affects the music in some way.  The important events in an instrumental track are:

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

The tempo track defines the [microseconds per quarter note](http://nokturnal.pl/home/atari/midi_delta) and the beats per minute of the song, which govern the pacing.

* SetTempoEvent - Sets the tempo of the instrumental tracks in a song.  `tick` is the same as in an instrumental track. 

We can combine one or more (I think more is possible, although I always use one) tempo tracks with multiple instrumental tracks to make a song.  The song can then be written to a file.  The file will be in the byte format that we discussed earlier.  You can directly edit the file using a hex editor like [bless](http://home.gna.org/bless/) if you really want to.  Otherwise, you can convert the file into a sound file by using [fluidsynth](http://sourceforge.net/apps/trac/fluidsynth/) along with a [soundfont](http://sourceforge.net/apps/trac/fluidsynth/wiki/SoundFont).  Fluidsynth will turn the numbers for pitch, velocity, and instrument into notes, and write the result to a [wav](http://en.wikipedia.org/wiki/WAV) file.  Once we have our file converted, we can listen to it directly, or use tools like [oggenc](http://linux.die.net/man/1/oggenc) to convert the wav to another, smaller, file format.

Okay, now what?
--------------------------------------

MIDI is critical to what we want to do, and once we have the principles down, we can move to our next phase.  The next phase is to define an algorithm to automatically create instrumental and tempo tracks.

Here is a rough diagram of our algorithm:

![algo flow](../images/midi-music/algo-flow.png)

We will exploit [markov chains](https://en.wikipedia.org/wiki/Markov_chain) to make our basic tracks.  Markov chains are defined with the probability of one state changing to another state.  For example, let's say that for the past 5 days, the weather was `Sunny, Cloudy, Sunny, Sunny, Sunny`.  So, after it was sunny, it was cloudy on one day, and sunny on two other days.  After it was cloudy, it was sunny on one day.  So, our system has two states, sunny and cloudy, and it transitions between those states with a certain probability.

Creating a markov chain:

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

Our predictions for the next 5 days would be `[cloudy, sunny, sunny, sunny, cloudy]`.  If we went through the Markov chain a second time, we would get a completely different set of predictions.  However, both sets of predictions would be based on past observations, and thus have an element of logic to them.

You can probably immediately see how this is applicable to music.  If we can figure out how to make an appropriate chain, we can use a random number generator to automatically make tracks by stringing notes together.

Learning probabilities for the markov chains
----------------------------------------------------

In order to learn the probabilities for the markov chains, we first have to get a lot of midi music.  As I mentioned earlier, we will get this music from midi world and midi archive.  Midi world has all classical tracks, and midi archive has "modern" tracks that are all over the place, but are not really classical.  We will get these by [web scraping](http://en.wikipedia.org/wiki/Web_scraping), using [this code](https://github.com/VikParuchuri/evolve-music/blob/master/crawler/crawler/spiders/scrape.py).

We can then read in the songs after we download them.  Once we read the songs in, each song will have multiple instrumental tracks that list events like this:

```
midi.ProgramChangeEvent(tick=0, channel=0, data=[0])
midi.NoteOffEvent(tick=20, channel=9, data=[42, 64]),
midi.NoteOnEvent(tick=28, channel=9, data=[38, 90]),
midi.NoteOnEvent(tick=0, channel=9, data=[42, 90]),
midi.NoteOffEvent(tick=20, channel=9, data=[38, 64]),
midi.NoteOffEvent(tick=0, channel=9, data=[42, 64]),
midi.NoteOnEvent(tick=28, channel=9, data=[42, 70]),
midi.NoteOffEvent(tick=20, channel=9, data=[35, 64]),
midi.NoteOffEvent(tick=0, channel=9, data=[42, 64]),
```

We can easily generate three time series from this, for tick, pitch, and velocity, along with a constant value for instrument (from ProgramChangeEvent).  So, we can create the time series `pitch = [42,38,42,38,42,42,35,42]`, `velocity = [64,90,90,64,64,70,64,64]`, and `ticks = [20,28,0,20,0,28,20,0]` for instrument 0, which is the Acoustic Grand Piano.

If we do this for a lot of tracks (I had 500), we can build up very long time series for each instrument.  Then, just like we did with our weather data, we can create markov chains defining the transitions for ticks, pitch, and velocity.  So, from the above events, if we are playing a note with a velocity of 90, we would have a 50% chance of the next note having a velocity of 90, and a 50% chance of the next note having a velocity of 64.  We segment this by instrument because we would expect different pitch and velocity combinations to be ideal for different instruments (ie, you wouldn't play a flute and a guitar the same way).

We can also do the same thing for the tempo tracks, where we can get a time series for ticks and a time series for mpqn (microseconds per quarter note, which defines the speed of the music).

Generating tracks with Markov chains
----------------------------------------------------

Once we learn the markov chains for each value that we want, we can use random number generators to make sequences of notes and tempos.

To make an instrumental track, we have to generate values for ticks, velocity, and pitch.  So, for each of our tick, velocity, and pitch markov chains, we pick a random number, and then initialize our chain with that number (just like we started off with today is sunny earlier).  Then, we can use a random number generator to pick the next value, and so on, until we reach our designated length.  In this case, we want all of our tracks to be the same number of ticks in length, so we first generate the tick sequence, make sure all the ticks add up to a predetermined number (let's say 2000), and then generate the other two sequences to be the same length.

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th>index</th><th>tick</th><th>pitch</th><th>velocity</th></tr>
</thead>
<tbody>
<tr><td>0</td><td>0</td><td>42</td><td>90</td></tr>
<tr><td>1</td><td>20</td><td>38</td><td>64</td></tr>
<tr><td>2</td><td>0</td><td>42</td><td>64</td></tr>
<tr><td>3</td><td>28</td><td>35</td><td>70</td></tr>
<tr><td>4</td><td>20</td><td>42</td><td>64</td></tr>
<tr><td>5</td><td>0</td><td>35</td><td>64</td></tr>
<tr><td>6</td><td>28</td><td>42</td><td>90</td></tr>
<tr><td>7</td><td>0</td><td>42</td><td>90</td></tr>
<tr><td>8</td><td>20</td><td>42</td><td>64</td></tr>
</tbody>
</table>

  <script>
    $('.table').dataTable({
        "bPaginate": false,
        "bLengthChange": true,
        "bSort": false,
        "bStateSave": true,
        "sScrollY": 300,
        "sScrollX": 500,
        "aLengthMenu": [[50, 100, -1], [50, 100, "All"]],
        "iDisplayLength": 6,
    });
    </script><br/><br/>
</div>

Given our notes from the previous section, the above is one potential time series we can get from tick, pitch, and velocity using our markov chains and a random number generator.  Note how we can only transition between notes that existed in the original data and had the right transitions in the original data.

We can do the same for our tempo tracks to generate our SetTempoEvents.

Combining tracks and evaluating quality
---------------------------------------------------------

Once we have a pool of tracks and a pool of tempos, we can combine them to make songs.

We set a number of songs that we want, then we pick a random tempo for each song, and we start to pick tracks to fill out the songs.  We follow some rules:

* The number of instrumental tracks in each song is randomly chosen, but does not exceed 8.
* We try to select varied instruments for each song (ie, we don't pick a viola, a violin, and a cello as the sole instruments in a song).

Using this process, we create 100 songs.  Now what?  We definitely want some way to figure out if the songs are good or not.  Enter the musical quality assessment tool (MQAT) from my [previous post](http://www.vikparuchuri.com/blog/evolve-your-own-beats-automatically-generating-music).  The MQAT will tell us if a song is good or not by comparing it to examples of good songs.

In order to do this, we must first convert our song into sound.  We could make an algorithm to judge the quality of the MIDI directly, but ultimately the midi file doesn't matter, the sound it generates does.  We could try to tie the tempo to the instrumental tracks and figure out how they affect each other, but it has already been done for us by tools that convert midi files into wav (sound) files.

We convert our midi file into sound using [fluidsynth](http://sourceforge.net/apps/trac/fluidsynth/).  I talked about extracting musical features in my previous post, but I will talk about it a bit here.  Sound is just a wave, and we can measure that wave at various points to get intensities.

![10 seconds of song](http://www.vikparuchuri.com/images/evolve-beats/song_10s.png)

The above is an example of 10 seconds of a song.  The blue and green lines represent different audio channels.  Another way to look at this would be to look at it as a sequence of numbers:

{%math%}
\begin{bmatrix}
2.35185598e-05 & -1.04448336e-05\\
-3.46823663e-06 & -3.73403673e-05\\
-2.69492170e-06 & -1.44758296e-05\\
9.47549870e-06 & 2.09419904e-05\\
-2.70856035e-05 & 3.44590421e-06\\
-3.01332675e-05 & 2.74870854e-05\\
-1.44664727e-06 & 7.49632018e-05\\
-3.80197125e-05 & 2.56412422e-05\\
-5.61815832e-05 & -1.29676855e-05\\
-4.73532873e-06 & 3.69851950e-05

\end{bmatrix}
{%endmath%}

When we read in a song, we get a long sequence of numbers that look like the above.  How many numbers we get depends on the sampling rate of the track (how many times per second it was measured).  From those numbers, we can describe the track.

We already have sample "good" tracks, which are our midi files that we downloaded.  We can compare the songs that we generate to these songs using our MQAT.  We will get a value from 0-1.  If the value is 0, the song is similar to modern/electronic music, and if it is a 1, the song is similar to classical music.  We will define quality to be how close the value is to 1 or 0.  So a song that gets a .2 will have a .2 quality, as will a song that gets a .8.

Semi-Genetic Component
----------------------------------------------------------------

We will  borrow a page from biology and use [genetic algorithms](http://en.wikipedia.org/wiki/Genetic_algorithm) (sort of).  Genetic algorithms let us define a population, and then define mutations to that population.  You also define something that measures "fitness" (how good or bad each member of the population is).  In our case, our population is our set of songs.  We can "mutate" the songs by remixing two songs together (swapping tracks between them), or by adding two songs together to make one larger song.

After we do this, we keep the best songs, generate new songs to add "fresh blood" to the population, and try again with a new "generation."

Here is a diagram of this:

![bytes](../images/midi-music/ga-flow.png)

We repeat our genetic algorithm a few times, and we end up with finished songs.

Results
----------------------------------------------------------------

When we run the algorithm over 2 generations with 100 songs per generation, we get the following:



Extending this
-----------------------------------------------------------------

All of the code for this is available [here](https://github.com/VikParuchuri/evolve-music).

This algorithm is pretty decent, and can make reasonable-sounding music.  The main weaknesses are a lack of domain knowledge and specificity.  Knowing more about audio would help in this.

Potential improvements:

* Have an additional "harmonizing" layer that tries to ensure that songs have good harmony.
* Similar to above, have layered Markov chains for meta-features of the music, like period and instrument changes.
* Define explicitly which instruments sound good with which other instruments.
* Explicitly avoid certain note patterns.
* Algorithm to automatically pick which instruments should be slotted together.
* Algorithm to identify optimal remix candidates.

I would love to hear any comments, suggestions, or feedback you have.