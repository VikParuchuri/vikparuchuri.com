---
layout: post
title: "Predicting season records for NFL teams - part 2"
date: 2013-07-09 14:20
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

*Cross-posted to [Vik's Blog](http://www.vikparuchuri.com) and [Equirio](http://www.equirio.com).  This is the second, technical, part.  See [the first part](/blog/predicting-nfl-season-records-with-percept) for more detail.*

Introduction
-------------------

This post will introduce the technical details behind the nfl season record prediction that was introduced in [part one](/blog/predicting-nfl-season-records-with-percept).

After selecting the error metric and defining an acceptable baseline, which was setup in part one, the next step is to develop a plan of attack.  In order to create and develop this plan, we will use the [percept](http://www.github.com/equirio/percept) framework created by [Equirio](http://www.equirio.com).

### Installing percept

First, we will need to install percept.  We can do this via:

```
$ git clone git://github.com/equirio/percept.git
$ cd percept
$ xargs -a apt-packages.txt apt-get install
$ virtualenv /path/to/percept
$ source /path/to/percept/bin/activate
$ pip install -r pre_requirements.txt
$ pip install -r requirements.txt
```
