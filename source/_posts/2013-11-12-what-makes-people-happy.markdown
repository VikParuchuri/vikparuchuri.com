---
layout: post
title: "What makes us happy?  Let's look at data to find out."
date: 2013-11-13 17:49
comments: true
categories:
    - happiness
    - happsee
    - Somerville
    - R
    - leaflet
    - Kaggle
    - causation
---

I've had a lot of different jobs over the past 4 years, and I've had some incredible experiences along the way.  Lately, I've been struggling with what to do next.  Or perhaps more accurately, I've been struggling with how to decide what to do next.  Decisions that seem obvious in hindsight are tough to come to grips with beforehand, and it's led me to think about what metric I am trying to maximize.  I admit that it's odd to think of life as a way to increase certain metrics, but aren't we doing this already in a different way?  A lot of people (myself included) will at some point say that all we care about is money.  Isn't that just us saying that money is the metric we want to maximize?  Now that I am older and wiser (yeah, right), I find myself increasingly concerned with maximizing my own happiness.

Happiness is this strange concept that nobody quite understands, nobody quite wants to admit to not having, and isn't always consistent (do we care about moment-to-moment happiness, or long-term happiness?).  I think [Wikipedia](http://en.wikipedia.org/wiki/Happiness) says it best with "happiness is a fuzzy concept and can mean different things to different people."  Great.  Thanks, Wikipedia.  The more I read about happiness research, the more I realized that in order to truly understand what makes me happy, I would have to start capturing information about it.  This has led me to develop an Android application called [Happsee](http://www.happsee.com) that can be used to track and visualize happiness.  The results have been fantastic so far, and I will be sharing them in a later post.  This post, though, is about looking at happiness on a higher level.

In the course of creating Happsee, I met/have been meeting with a lot of people in the Boston area who are doing interesting things in the field.  One of these people is [Daniel Hadley](http://www.linkedin.com/in/danielhadley), the head of [SomerStat](http://www.ci.somerville.ma.us/departments/somerstat/staff), a very cool department of the city of [Somerville](http://www.somervillema.gov/) that tries to quantify various aspects of life in the city and make them better.  One of these aspects is happiness, and SomerStat has compiled data on happiness in Somerville going back to 2006.  I tried not to let my eyes get too wide when Daniel told me about this data (normal people like normal things -- I like data).  He was gracious enough to share the anonymized data with me, and I will be looking at it in this post in order to see if it can help us better understand happiness.

<!--more-->

More about the data, and our first chart
----------------------------------------------

The data from Somerville consists of a survey that asks people how happy they are, how satisfied with life they are, and some other questions about their happiness on a 1-10 scale. It also contains other information, like location, race, and gender.  Here is a small sample:

![somerville sample](http://127.0.0.1:4000/images/somerville-happiness/somerville_survey.png)

As you can see, the data is pretty messy in places.  My first step was to cleanup and explore the data.  After doing so, I got this plot:

![somerville happiness 2d](http://127.0.0.1:4000/images/somerville-happiness/happiness_clusters.png)

This plot comes from taking survey questions about how satisfied people are in general, and how satisfied they are about their neighborhoods, and turning them into two dimensional data.  The technique I used (read more about [SVD](http://en.wikipedia.org/wiki/Singular_value_decomposition) if you are interested, it's very cool) thought that people's happiness and their satisfaction with their neighborhood were both very important, and clustered people according to them.

What does this tell us?  Well, off the bat, most people are happy and/or really like where they live.  I don't know how this data was collected, so there could be sample bias, but it seems like Somervillians (is this even a word?) are very well off.  It's also interesting to note that even though how much you like your area correlates strongly with happiness, it's still possible for a lot of people to be happy if they don't like the area or vice versa.  I would have thought this wouldn't happen for a lot of people, but I guess the Wikipedia quote had it right.

Mapping happiness
----------------------------------------------

People seem to have very strong feelings about their neighborhoods.  Let's try mapping out happiness by area to see if there is any correlation:

<div>
    <link rel="stylesheet" href="//cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" />
    <link rel="stylesheet" href="http://127.0.0.1:4000/stylesheets/somerville-happiness/somerville_happiness.css"/>
    <link href='http://fonts.googleapis.com/css?family=Cherry+Swash' rel='stylesheet' type='text/css'>

    <div id="somerville-map" class="somerville-map"></div>

    <script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script>
    <script src="http://127.0.0.1:4000/javascripts/somerville-happiness/rainbowvis.js"></script>
    <script src="http://127.0.0.1:4000/javascripts/somerville-happiness/somerville_map.js"></script>
</div>

The above shows the coordinates of each survey response to the question how happy are you right now in 2013.  All coordinates are anonymized by adding random noise to both latitude and longitude (so some points are in weird places, like the middle of the highway).

It looks like there are some clusters of low happiness towards the edges of the city.  These may be correlated with certain features of the neighborhood.  I would love to hear insight on this if anyone has any.

So it looks like while how much you like your neighborhood is pretty strongly correlated with happiness, there is no particular neighborhood that makes people extremely unhappy (or vice versa).  Let's look at what does correlate with happiness.

What correlates with happiness?
------------------------------------------------

We can use a statistical significance test to discover the things that are closely related to happiness.  We will be using an [ANOVA](http://en.wikipedia.org/wiki/Analysis_of_variance) test.  This test will give us a [p-value](http://en.wikipedia.org/wiki/P-value).  We will take any p-value below .05 to mean that the variable is related to happiness.

The survey questions whose answers correlated closely with happiness in order of most to least:

<div>
    <p class="c2">How satisified are you with your life in general?</p>
    <p class="c2">Taking everything into account, how satisfied are you with Somerville as a place to live?</p>
    <p class="c2">How satisfied are you with your neighborhood as a place to live? </p>
    <p class="c2">In general, how similar are you to other people you know? </p>
    <p class="c2">How would you rate the Public Services in Somerville? (there were a lot of closely correlated items here, like public schools, garbage collection, and street maintenance) </p>
    <p class="c2">When making decisions, are you more likely to seek advice or decide for yourself?</p>
    <p class="c2">Overall, would you say that the City of Somerville is moving in the right direction or the wrong direction?</p>
    <p class="c2">What is your marital status?</p>
    <br/>
</div>

The above items are correlated with happiness, which means that generally, as happiness changes, so do they (can be either positive or negative).  However, this doesn't tell us anything actionable.  For example, happier people could be more likely to think that the city of Somerville is headed in the right direction.  What we really want to know is if thinking Somerville is headed in the right direction *causes* people to become happier.

What causes happiness?
---------------------------------------------------

Correlation versus causation is an extremely difficult problem to solve, especially when you can't gather additional data.  [Kaggle](http://www.kaggle.com/), a website that posts machine learning challenges, recently had a [competition](http://www.kaggle.com/c/cause-effect-pairs) on the subject.  Luckily for us, I participated in the competition, and have a program that can tell if something is a cause or an effect with reasonable accuracy (but not perfect).  Let's run the program on the factors that are correlated with happiness to discover if any of them were likely to *cause* happiness.

The analysis indicates that how you answer the following question is caused by how happy you are:

<div>
    <p class="c2">Taking everything into account, how satisfied are you with Somerville as a place to live?</p>
    <br/>
</div>

This is a very interesting result, as it shows that how satisfied you feel about life can be caused by how happy you feel in a particular moment.  I will let the psychologists sort this result out, but for me personally, it indicates that trying to maximize moment-to-moment happiness could be a viable strategy.

The analysis indicates that how you feel about these questions causes how happy you are.  So, of you answer more positively to these, you will generally be happier:

<div>
    <p class="c2">Taking everything into account, how satisfied are you with Somerville as a place to live?</p>
    <p class="c2">How satisfied are you with your neighborhood as a place to live? </p>
    <p class="c2">In general, how similar are you to other people you know? </p>
    <p class="c2">How do you feel about the Public Schools?</p>
    <p class="c2">How do you feel about the Public Works Department (e.g. requests for yard waste stickers or white good pick-up)?</p>
    <p class="c2">How do you feel about the Recreation Programs in Somerville?</p>
    <br/>
</div>

There are some surprises here (public works?), but they generally seem consistent with prior results.  How people feel about their neighborhoods strongly affects how happy they are.  Improving things like public school quality should boost resident happiness.  Personally, this indicates that moving to another place would be a great way to boost happiness (luckily, I love Cambridge).

A closer look at some interesting correlations
---------------------------------------------------

Let's take a closer look at some of the interesting variables that could potentially cause happiness:

![neighborhood satisfaction](http://127.0.0.1:4000/images/somerville-happiness/neighborhood_satisfaction.png)

It seems that happiness goes up as you like your neighborhood more, but there is a strange set of high happiness levels associated with low neighborhood satisfaction.  I wonder if anyone in Somerville has insight into this.

![similarity](http://127.0.0.1:4000/images/somerville-happiness/similarity.png)

This is very interesting to me, as surrounding yourself with diverse viewpoints is often helpful.

![public schools](http://127.0.0.1:4000/images/somerville-happiness/public_schools.png)

A lot of public services look like this one (although to lesser degrees).

What does it all mean?
---------------------------------------------------

As with everything about happiness, its hard to tell.  Below are some provisional conclusions that are by no means ironclad.

### On a personal level
* Where you live seems to be very important.
* Who you associate with seems to be important.
* How you interact with your surroundings (school, recreation, etc) seems to matter.

### On a city level
* The quality of city services can matter a lot.
* More "customer-facing" services like schools and recreation seem to be the most important.
* Citizen happiness can be affected at a city level.

What's next?
---------------------------------------------------

I will be looking into this data more and seeing if anything else remains to be discovered.  There are a huge amount of interesting things that can be done, and thanks again to Daniel and SomerStat for letting me look at this.

  As I continue making [Happsee](http://www.happsee.com), I am going to try to figure out these kinds of insights and more in real-time, which I am hugely excited about.  Here is a map tracking two weeks of my own happiness in and around Boston:

<div>
<img src="http://127.0.0.1:4000/images/somerville-happiness/hs2-1.png" height="300px" width="200px">
</div>

Imagine being able to anonymously map happiness in real-time throughout your city, and couple the mapping with realtime insight.  This could be incredibly powerful.  The more steps I take down the path to understanding myself and my own happiness, the more I am struck by how much it can tell me and help me.

If you are interesting in talking more about this post, what I am working on, or data in general, feel free to contact me.  If anyone wants to do similar analysis in their own city, I am happy to help.  I normally put the code for my blog posts on Github, but I will need to hold off for now to clean the code up and check on whether or not the data can be released.