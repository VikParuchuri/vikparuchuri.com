---
layout: post
title: "On the automated scoring of essays"
date: 2013-07-30 12:37
comments: true
categories:
    - AES
    - ASAP
    - kaggle
    - edX
    - essay scoring
    - discern
---

We've all written essays, often at the behest of a teacher.  We have occasionally even enjoyed researching a topic and composing the paper.  Sometimes, this process can take hours and hours of careful work.  So, naturally, people react badly to the notion that their essays may be scored not by a human teacher, but [by machine](http://gettingsmart.com/2012/04/automated-essay-scoring-systems-demonstrate-effectiveness/).  A soulless (or maybe not, but that's a topic for another day) computer judging the quality of our carefully constructed phrases and metaphors is more than most writers can bear.  But is this what automated essay scoring (AES) is?  If not, what is it?  In this article, I aim to explore the field, where it is going, and where it should go.

Who am I?
--------------------------------------------------------

I have been involved in the AES field for 2 years now.  I didn't know it at the time, but my involvement began, incongruously, with my own struggles with higher education.  I never knew what I wanted out of my life when I was in school, and wouldn't have seen college as the way to get there even if I had.  This gave me a keen interest in trying to find ways to personalize learning.  Later, I ended up in the [foreign service](http://careers.state.gov/officer), a career that required me to do a lot of writing.  For many reasons, I ended up leaving the foreign service, a decision which led to me learning programming and [machine learning](http://en.wikipedia.org/wiki/Machine_learning), the art of how to teach computers to predict things, entirely through online materials.  But I kept my love for writing alive, primarily through my blogging.

Imagine my own surprise when I found a competition sponsored by the [Hewlett Foundation](http://www.hewlett.org/) and hosted by [Kaggle](http://www.kaggle.com/) that aimed to develop algorithms to [automatically score essays](http://www.kaggle.com/c/ASAP-AES).  I won't try to dance around the issue; I initially competed because I noticed that some extremely smart people were competing, and I wanted to see how I stacked up.  But as time went on (the competition ran for about 3 months), I became more and more invested in the subject, and began to recall my own experiences with higher education and writing.  I was fortunate enough to be able to work with [Justin Fister](http://www.kaggle.com/users/12386/justin-fister), and we ended up getting 3rd place in the competition.  In a [second competition for short answers](http://www.kaggle.com/c/asap-sas), we teamed up with Measurement, Inc. (MI), and came in first place on the leaderboard.

As strange as it sounds, even though sitting at my computer day after day, coding for hours on end, participating in those competitions were some of the most fun times I have had.  I was able to spend every day learning, striving, and implementing (I may have a less rosy recollection had I not done so well).  But the luster quickly faded post-contest.  We had made some great and interesting advances, and now possessed a lot of knowledge, but so what?  The knowledge was not being applied to anything.  Justin found a job at MI, and I went to work for [edX](https://www.edx.org/), a masively open online class (MOOC) provider based in Boston.

You may have heard of the [edX automated essay scoring algorithm](http://www.nytimes.com/2013/04/05/science/new-test-for-computers-grading-essays-at-college-level.html?pagewanted=all), and the backlash such as [this](http://mfeldstein.com/si-ways-the-edx-announcement-gets-automated-essay-grading-wrong/) and [this](http://www.hackeducation.com/2012/04/15/robot-essay-graders/) to it.  I created this algorithm, and as much as the criticism can sting (seriously, the guy who wrote the first backlash article I linked to decided to call it [first year graduate student level](https://news.ycombinator.com/item?id=5801692), which I guess is a compliment, because I never went to grad school), I think that there are valid points on both sides of the issue, and I will try to go through them in my discussion.

What is AES
-------------------------------------------------------------

To me, AES is the art of giving students automatic, iterative, and correct scores and feedback on their essays and constructed responses.  You may notice that I inserted several words that go beyond the narrow scope contained in the words "automated essay scoring".  I will go through each one in order:

* Feedback - in many applications of AES, such as in a ["second reader"](http://www.mba.com/the-gmat/gmat-scores-and-score-reports/understanding-your-score-report.aspx) on the GMAT(more on what this is later), feedback isn't as critical.  But in all cases where a student will be learning based on how their response is scored, feedback is absolutely critical.
* Iterative - One of the main advantages of AES is that students can submit their response as many times as they want, getting very quick feedback and scoring each time.
* Constructed responses - Automated scoring isn't just about essays.  As the second Hewlett Foundation competition showed, computers can grade constructed responses as well.

Now, maybe you don't agree with my definition, but at least we have a baseline idea of what it is for when we proceed through this article.

The history of AES
--------------------------------------------------------------

Remarkably, the idea of AES first came about in 1966, and was advanced by [Ellis Page](http://en.wikipedia.org/wiki/Ellis_Batten_Page).  Remarkably, it only took him two years to come up with working software.  I can't even imagine how much ingenuity it must have taken to do what he did with the hardware/software limitations of the time.  His software, called Project Essay Grade (PEG), was later purchased by Measurement, Inc., which continues to develop it.

Through the 1990s and 2000s, several other companies, such as [Educational Testing Service](http://www.ets.org/), [Pearson](http://www.pearson.com/), and [CTB/McGraw-Hill](http://www.ctb.com/ctb.com/control/main), started developing their own, competing, tools.
