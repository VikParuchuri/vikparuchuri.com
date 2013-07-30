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

We've all written essays, often at the behest of a teacher.  We have occasionally even enjoyed researching the topic and composing the paper.  Sometimes, this process can take hours and hours of careful work. Given this, people react badly to the notion that their essays may be scored not by a human teacher, but [by machine](http://gettingsmart.com/2012/04/automated-essay-scoring-systems-demonstrate-effectiveness/).  A soulless (or maybe not, but that's a topic for another day) computer judging the quality of our carefully constructed phrases and metaphors is more than most writers can bear.  But is this what automated essay scoring (AES) is?  If not, what is it?  In this article, I aim to explore the field, and where it is going.

Who am I?
--------------------------------------------------------

I have been involved in the AES field for 2 years now.  I didn't know it at the time, but my involvement began, incongruously, with my own struggles with higher education.  I never knew what I wanted out of my life when I was in school, and wouldn't have seen college as the way to get there even if I had.  Afterwards, this gave me a keen interest in trying to find ways to personalize learning.  I later ended up in the [foreign service](http://careers.state.gov/officer), a career that required me to do a lot of writing (see: Wikileaks cables).  For many reasons, I ended up leaving the foreign service, a decision which led me to learn programming and [machine learning](http://en.wikipedia.org/wiki/Machine_learning), the art of how to teach computers to predict things, through online materials.  But I kept my love for writing alive, primarily through my blogging.

Imagine my surprise when I found a competition sponsored by the [Hewlett Foundation](http://www.hewlett.org/) and hosted by [Kaggle](http://www.kaggle.com/) that aimed to develop algorithms to [automatically score essays](http://www.kaggle.com/c/ASAP-AES).  I won't try to dance around the issue; I initially competed because I noticed that some extremely smart people were in it, and I wanted to see how I stacked up.  But as time went on (the competition ran for about 3 months), I became more and more invested in the subject, and began to recall my own experiences with higher education and writing.  I was fortunate enough to be able to work with [Justin Fister](http://www.kaggle.com/users/12386/justin-fister), and we ended up coming in 3rd place in the competition.  In a [second competition for short answers](http://www.kaggle.com/c/asap-sas), we teamed up with Measurement, Inc. (MI), and came in first place on the leaderboard, although we were ineligible for prizes due to our company affiliation.

As strange as it sounds, even though I was sitting at my computer, coding for hours on end, participating in those competitions was a lot of fun.  I was able to spend every day learning, striving, and implementing (I may have had a less rosy recollection had I not done so well).  But the luster quickly faded post-contest.  We had made some interesting advances, and now possessed a lot of knowledge, but so what?  The knowledge was not being applied to anything, and there is a huge gap between theoretical and real-world results.  Justin found a job at MI, and I went to work for [edX](https://www.edx.org/), a masively open online class (MOOC) provider based in Boston, where I started to apply what I learned.

You may have heard of the [edX automated essay scoring algorithm](http://www.nytimes.com/2013/04/05/science/new-test-for-computers-grading-essays-at-college-level.html?pagewanted=all), and the backlash such as [this](http://mfeldstein.com/si-ways-the-edx-announcement-gets-automated-essay-grading-wrong/) and [this](http://www.hackeducation.com/2012/04/15/robot-essay-graders/) to it.  I created this algorithm, and as much as the criticism can sting (seriously, the guy who wrote the first backlash article I linked to decided to call it [first year graduate student level](https://news.ycombinator.com/item?id=5801692), which I guess is a compliment, because I never went to grad school), I think that there are valid points on both sides of the issue, and I will try to go through them in my discussion.

What is AES
-------------------------------------------------------------

To me, AES is the art of giving students automatic, iterative, and correct, scores and feedback on their essays and constructed responses.  You may notice that I inserted several concepts that go beyond the narrow scope contained in the words "automated essay scoring".  I will go through each one in order:

* Feedback - in many applications of AES, such as in a ["second reader"](http://www.mba.com/the-gmat/gmat-scores-and-score-reports/understanding-your-score-report.aspx) role on the GMAT(more on what this is later), feedback isn't as important.  But in all cases where a student will be learning based on how their response is scored, feedback is absolutely critical.
* Iterative - One of the main advantages of AES is that students can submit their response as many times as they want, getting very quick feedback and scoring each time.
* Constructed responses - Automated scoring isn't just about essays.  As the second Hewlett Foundation competition showed, computers can grade constructed responses as well.
* Correct - Automated essay scoring is somewhat useful if its scores are only marginally inaccurate, but its utility goes away if it can't score properly.

Now, maybe you don't agree with my definition, but at least we have a baseline idea of what it is for when we proceed through this article.  If you don't agree with this, I would love to hear what your definition is, and how you think this definition can be made better.

A brief history of AES
--------------------------------------------------------------

Remarkably, the idea of AES first came about in 1966, and was advanced by [Ellis Page](http://en.wikipedia.org/wiki/Ellis_Batten_Page).  Amazingly, it only took him two years to come up with working software.  I can't even imagine how much ingenuity it must have taken to do what he did with the hardware/software limitations of the time.  His software, called Project Essay Grade (PEG), was later purchased by Measurement, Inc., which continues to develop it.

Through the 1990s and 2000s, several other companies, such as [Educational Testing Service](http://www.ets.org/), [Pearson](http://www.pearson.com/), and [CTB/McGraw-Hill](http://www.ctb.com/ctb.com/control/main), started developing their own, competing, tools.  Some open tools, such at [BETSY](http://echo.edres.org:8080/betsy/), also appeared.

One major use case of these tools was as an automated "second reader" for high stakes tests.  A human first scored the test, after which a machine scored it.  If the two scored differed by a certain amount, then a third human re-scored the paper to resolve the dispute.  Another major use case was as an in-classroom learning tool.  In fact, these are still the primary use cases for AES.

How does AES work?
---------------------------------------------------------------

Here is a rough diagram of automated essay scoring:

![aes diagram](http://www.vikparuchuri.com/images/aes/aes-flow.png)

So, students first write some essays.  Teachers then grade these essays using whatever criteria they want.

Now, a machine learning model is created.  In order for a machine learning model to be created, features first need to be extracted from the text, as a computer cannot directly understand English.  We need to use the numbers as proxies for meaning.

 Features are just numbers that describe certain things.  For example, in my current apartment, one feature is that it has 1.5 bathrooms, and another feature is that it has 2 bedrooms.  If I was going to build a machine learning model to predict apartment rents, I might pass in these features.  I would then map the features to a certain amount of rent.  So, for example, if one apartment has 1.5 bathrooms and 2 bedrooms and costs 1,000 dollars a month in rent, whereas another apartment has 1 bathroom and 1 bedroom and costs 500 dollars a month in rent, a machine would learn that a certain number of bedrooms and a certain number of bathrooms equal a certain amount of rent.  So, if we ask it to predict the rent for an apartment with 1 bathroom and 2 bedrooms, it might say 900 dollars.

Let's look at this is the context of essays, using some examples from a presentation I did last month:

Say that I wanted to give a survey today and ask you `why do you want to learn about machine learning?`

The responses might look like this:

```
1 I like solving interesting problems.
2 What is machine learning?
3 I'm not sure.
4 Machine learning predicts everything!
```

Let's say that the survey also asks people to rate their interest on a scale of 0 to 2.

We would now have the responses and associated interest scores:

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th>number</th><th>response</th><th>score</th></tr>
</thead>
<tbody>
<tr><td>1</td><td>I like solving interesting problems.</td><td>2</td></tr>
<tr><td>2</td><td>What is machine learning?</td><td>0</td></tr>
<tr><td>3</td><td>I'm not sure.</td><td>0</td></tr>
<tr><td>4</td><td>Machine learning predicts everything!</td><td>2</td></tr>
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
    </script><br/>
</div>

So, let's say that we get a half-filled-out survey that forgot to include the interest score.  All we got was the sentence `I really like solving problems.  Machine learning is very useful.`  Now, if we look at this in the context of the other responses, we can infer that the interest of the person is likely a 2/2.  But how would a computer do the same thing?  Through features.

Some of the features we might extract:

* Presence/absence of the phrase `solving problems`. (0 if absent, 1 if present)
* Number of sentences.
* Presence/absence of `machine learning`.
* Average word length.
* Presence/absence of `machine`.

This is a very simple example, but it gives you a good idea of what features are.  Features allow us to represent text, which a machine does not understand, as numbers, which it does understand.

We can then tell a machine learning [algorithm](http://en.wikipedia.org/wiki/Supervised_learning), such as a random forest, or a linear regression, that a certain sequence of features means that the student got a 2, another sequence of features means that the student got a 0, and so on.  This trains the algorithm.

Once the algorithm is trained, then it can predict the scores for new essays, after we turn them into sequences of features.

Applying AES
-----------------------------------------------

Now that I have given you the theory, let's talk about application.  Here is a diagram of how we applied it at edX:

![edx flow](http://www.vikparuchuri.com/images/aes/edx-flow.png)

So, when a student answers a question, it goes to any or all of self, peer, and AES to be scored.  Written feedback (from peer assessment), and rubric feedback (from all three assessments) are displayed to the student.

It is completely up to the instructor how each problem is scored, and how the rubric looks.  A rubric would look something like this:

```
Topicality
0 points - Student is off topic
1 point - Student stays on topic

Photosynthesis
0 points - Incorrectly defines photosynthesis
1 points - Partially correct definition
2 points - Fully correct definition
```

The AES will give the student feedback on how many points they scored for each category of the rubric.  I show you this example less to discuss the strengths and weaknesses of the edX system, but more to lead into a discussion of how, when, and why AES should be deployed.

Lessons of application
----------------------------------------------------

* Don't forget the goal - The goal here isn't to impress people with fancy technology or tell teachers how they should teach.  The goal is to maximize student learning and limited teacher resources (time) in a way that is flexible, and completely under the control of the subject expert (teacher).
* Scale - In a MOOC setting, AES makes sense.  It is hard/impossible for a teacher to score thousands of students each week, and writing is a critical component of many courses.  But scale can also play a big part in the classroom.  Can a teacher grade 10 drafts per student per week?  Maybe it makes sense to allow students to score their "intermediate revisions" by machine, improve their writing, and give their key drafts and finished products to a teacher for more detailed feedback.
* AES is best used in combination with other technologies - In the same vein as the point above, AES is useful in some domains, and can given students accurate scores and rubric feedback.  However, AES cannot give detailed feedback like an instructor or peer can.  You should evaluate your options and see how you can best use AES.  Maybe it works for certain questions.  Maybe you can grade tests with AES.  Maybe it is good for grading first drafts.
* Put the power in the hands of teachers - AES is useless when the power is in the hands of researchers and programmers (although it does make us feel powerful).  The real people who need to shape and implement these technologies are teachers, and they need the power to define how the AES looks and works,  Maybe a teacher doesn't need to define what features the AES uses, but being able to turn off the AES for certain students might be useful.
* Give people the information that they need - AES is a semi-shadow world to a lot of people, and that may be partially by design.  The less we tell people about how things are done, the more valuable we become.




