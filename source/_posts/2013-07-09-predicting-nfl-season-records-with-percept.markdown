---
layout: post
title: "Predicting NFL season records with percept"
date: 2013-07-09 10:42
comments: true
categories:
    - machine learning
    - ML
    - percept
    - equirio
    - NFL
    - football
published: true
---

*Cross-posted to [Vik's Blog](http://www.vikparuchuri.com) and [Equirio](http://www.equirio.com).*

Introduction
-----------------

I was recently looking for a good machine learning task to try out, and I thought that predicting season records for NFL teams might be interesting.  The NFL season is about to start (finally!), and now seems like a good time for them.

Why was I looking for a good machine learning task to try out?  I have been developing a lightweight, modular, machine learning framework with my company, [Equirio](http://www.equirio.com), and I wanted something to test it with.  All of the code here will be in Python, and you can easily use it outside of the framework if you want.

We are going to start with a high-level, nontechnical overview of what we will be doing, and then follow that up with some technical details.

<!--more-->

Overview
------------------

### Machine learning description

In machine learning, the goal is to learn from data and a known outcome to predict an unknown outcome for future data.  For example, let's say that we have data for how hot it has been for the past 10 days, and we want to predict how hot it will be tomorrow.  The data (how hot it has been for the past 10 days), and the outcome (how hot it will be tomorrow), will be somewhat correlated.  So, we can take data and outcomes from the past (ie, how hot it was for the 10 days before today, and how hot it was today), and use it to predict how hot it will be tomorrow.  This will not be a perfect prediction, and we will have some error, as we do not have all of the needed information.  For example, maybe there is a cold front coming in from the north, but in our simple model, we don't have that information.

### How does this apply to NFL data?

In our case, we want to predict how well an NFL team will play next season.  In order to do this, we need some data about how well NFL teams performed in past seasons.

[Pro football reference](http://www.pro-football-reference.com/boxscores/) has some of the data we need.

![upload template](../images/nfl-season/pfr-box.png)

You can see that it is very generic information: for each game, we have the winner, the loser, who was at home, how many points each team had, how many turnovers each team had, and how many yards each team gained.

We could find other sources for data, which would make our algorithm much more accurate, but I will leave that exercise to you.

### Training and Prediction






