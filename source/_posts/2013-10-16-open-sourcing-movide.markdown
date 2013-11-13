---
layout: post
title: "Open sourcing movide, a student-centric learning platform"
date: 2013-10-18 17:24
comments: true
categories:
    - LMS
    - Movide
    - learning
    - education
    - edtech
    - open source
---

I haven't blogged in a while, mostly because I have been trying to figure out what I should do next.  One thing that I have been working on lately that I am very passionate about is [Movide](http://www.movide.com).  Movide is a student-centric learning platform.  You might yawn at this point and wonder why Movide matters.  It's a natural reaction, given the crowded learning tools marketplace.  Movide, matters, I think, because it is an [open source](http://www.github.com/equirio/movide) attempt to change the LMS and learning tool paradigm.

Traditional LMS tools are great for what they do -- enable course content to be translated from in-classroom to online.  They often serve as content-delivery mechanisms rather than skills measurement mechanisms.  This is extremely useful, and I have learned a lot from content hosted on LMS sites.  "Social" LMS tools are also fantastic for what they do -- reimage the LMS experience for a more connected, Facebook-driven era.  These often have content delivered in social-media like "streams."  I know both of these characterizations are oversimplifications, but I have limited space.

Neither tool can cover all learners and learning styles, and as I reflected more about how I learn, talked with people about how they learn, and read about research in the field, I realized that perhaps there was space for a tool that approached learning in a different way.

<!--more-->

Where did Movide come from?
----------------------------------------------

I have thought a lot about learning tools in the past year, in the course of which I have been privileged enough to work at [edX](http://www.edx.org).  This led me to think about how I learn.  Over the past two years, I have learned programming, [machine learning](http://en.wikipedia.org/wiki/Machine_learning), [data science](http://en.wikipedia.org/wiki/Data_science), web development, and a whole host of other associated skills.

Increasingly, the problem isn't finding the right content -- content is everywhere.  I've learned from [Khan academy](http://www.khanacademy.com), I've learned from [Andrew Ng's](http://cs.stanford.edu/people/ang/) machine learning course, I've learned from [StackOverflow](http://www.stackoverflow.com), and I've learned from [this great book](http://www-stat.stanford.edu/~tibs/ElemStatLearn/printings/ESLII_print10.pdf), among dozens of other sources.

I operate best when I find a problem that I want to solve, and then learn how to solve it.  The hardest part for me often is finding that defined problem, and finding an engaged community of peers to share knowledge with.  For data science and machine learning specifically, I found both on [Kaggle](http://www.kaggle.com), but this doesn't work for every field.  What if I wanted to learn history, or how to add, or even something as abstract as how to think critically?

This reflection on how I learn led me to think back on my own in-classroom experiences, and what worked best there and what didn't.  Most of the time, I was a terrible student.  I almost never turned in homework, and I generally had a bad attitude.  I only occasionally connected with the material, and often did not feel engaged. As I look back, I realize that I didn't approach it the right way. The experiences that I can unequivocally remember as good centered around people and problems -- the amazing teacher in high school who brought history alive, the group report I did in elementary school on the Chesapeake Bay, the time my elementary school teacher asked me to research Japanese-American internment during WWII for a school challenge, and many others.  I also remember being extremely curious and eager to share my knowledge -- I would often stay up at night and read novels by flashlight.

I often wondered if I was the only person whose desire to learn was not sated through school.  As I have talked to people over the years, I realize increasingly that I am not alone.  Looking at research like [Sugata Mitra's](http://www.hole-in-the-wall.com/) hole in the wall experiment, and [recent news on it](http://www.wired.com/business/2013/10/free-thinkers/) has also been very interesting to me.  I'm not as radical as some of the debate surrounding the research, but I think the ultimate goal is to harness student curiosity and let it drive the learning process instead of the other way around.

What is Movide?
-------------------------------------------------

Movide is a tool oriented around the idea of a class.  A class can be a teacher and students, a class can be a group of adult learners, a class can be a group of students sharing notes, or a class can be anything in between.  Movide lets anyone create classes.

Here is how the class dashboard looks.  It lets you create classes and view your existing classes:

![movide classes](http://www.vikparuchuri.com/images/movide/dashboard.png)

Inside a class, Movide lets anyone, student or teacher, add content and problems.  Content can be videos, links, personal blog entries, and so on.  Problems right now are restricted to assignments, where students respond to a question with text as well as images, video, and files if they choose, and multiple choice.  But the selection will expand over time.  Once this content exists, teachers can organize it, and students and teachers can discuss it.  Teachers can define concrete learning objectives and skills, and track student progress towards those skills.

Here is how the learning resources (which contain content and problems) look inside a class:

![movide resources](http://www.vikparuchuri.com/images/movide/resources.png)

And here is how the learning objectives and skills look inside a class:

![movide skills](http://www.vikparuchuri.com/images/movide/skills.png)

We can quickly see how some of the ideas I expressed above have made it into Movide.  Movide enables students to find interesting and useful content and then share and discuss it with each other, all while still working towards learning objectives.  This combines the power of self-paced learning with the necessities of the curriculum, while encouraging students to interact with each other.  It also enables teachers to direct the conversation and add course content.

Here are some things that you can do with Movide:

* Give students a way to create and share interactive notes.
* Maintain in-class student blogs.
* Teach a skills-based course, with online course material and the ability to track student progress.
* Create a continuous in-class discussion.
* Ask students to create assignments for each other.
* Offer students homework help outside of class.

Movide is also designed to be easy to use.  I remember talking to someone a year ago about the importance of design, and I, in my arrogance, thought that software was all about coding.  As I have worked more in the field, I have learned how wrong I was.

Obviously, Movide isn't perfect, and it is under continuous development.  But I think that it is a step in the right direction.

How can I help or use Movide?
-------------------------------------------------

So far, what I've really discussed is my own take on learning.  I recognize the immense value in the expertise of learning professionals.  I would love any and all feedback on Movide, and on the ideas I have expressed.  Please feel free to contact me at vik dot paruchuri at gmail, or by any of the means listed on this page.

If you want to use movide, you can [go here](http://www.movide.com).  If you want to run Movide on your own server, you can checkout the [github repo](http://www.github.com/equirio/movide), which has a full deployment script that can get you started very quickly.

If you want to contribute Movide, check it out on Github.  Feel free to message me about what might be most useful to work on.

Technical bits
-------------------------------------------------

Movide is really extensible, and is built in [Python](http://www.python.org/) using the [Django](https://www.djangoproject.com/) web framework.  It uses [django-rest-framework](http://django-rest-framework.org/) to provide a full API, which could be very useful down the road.  The API allows for authenticated retrieval and creation of anything used by the frontend.

The frontend is written in [javascript](http://en.wikipedia.org/wiki/JavaScript), using [Backbone](http://backbonejs.org/), and most of the design is taken care of by [Twitter Bootstrap](http://getbootstrap.com/).  What these technologies mean is that it is very easy to customize Movide to your own needs, whether that need is a retheming or building an iPad app.  A mobile application could easily use the API endpoints and construct a user interface around them.  Retheming is as easy as overriding the default bootstrap stylings.

Movide is currently deployed to [Amazon EC2](http://aws.amazon.com/ec2/), and uses [Cloudformation](http://aws.amazon.com/cloudformation/) to spin up the resource stack, and [Ansible](http://www.ansibleworks.com/) to deploy to it.  The Github repo for Movide has more information about how to do this yourself.

What is the future for Movide?
---------------------------------------------------

I've been talking to people and pondering a lot of future directions for Movide.  Phase one is to create a useful system that enables teachers and students to share and discuss content.

Phase two could involve automatically using machine learning to determine when a student is struggling, or has mastered a skill, and alert the teacher.  I discussed some of these ideas in my [automated essay scoring blog entry](http://www.vikparuchuri.com/blog/on-the-automated-scoring-of-essays).  It could also involve gamifying learning by giving students levels of progress to work towards.  It could also involve creating better collaboration tools within Movide for students and teachers to create documents, or make a class whiteboard online.

Ultimately, the future direction will be dependent on you and your feedback.  I would love to hear any and all thoughts.