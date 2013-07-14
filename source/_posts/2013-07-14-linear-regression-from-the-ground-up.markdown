---
layout: post
title: "Linear regression from the ground up"
date: 2013-07-14 19:19
comments: true
categories:
    - math
    - linear regression
    - matrices
    - ML
    - machine learning
    - Python
---

Linear regression is a very basic technique that we use a lot in machine learning.  In a lot of cases (and I have been guilty of this), we just use it without much thought as to how the internals actually work.

We can plot observations (such as, a child's age is 1), and associated dependent variables (ie, the child has 1 friend) on an x/y axis, like the one below:

![linear regression](../images/linear-regression/linear-system.png)

In the above system, we have plotted several observation and dependent variable pairs [1,1], [2,4], [3,9], [4,16].  We have also added in a line.  This line allows us to predict the dependent variables for future observations (when the child is 5, according to our line, they will have 20 friends).  The line is defined by an equation {%m%}y=mx+b{%em%} where m is the slope of the line, and b is the y-intercept.  In the simplest form of linear regression, we can figure out m and b to find the line.  In more complex forms, such as {%m%}y=m\_{1}x\_{1} + m\_{2}x\_{2}+b{%em%}, we can predict y using multiple features.

Today, I'm going to shed some light on the internals to linear regression, and do some comparisons of various approaches in Python.  If you have not read my earlier post on [matrix inversion](/blog/inverting-your-very-own-matrix), I highly recommend it.