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

In the above system, we have plotted several observation and dependent variable pairs [1,1], [2,4], [3,9], [4,16].  We have also added in a line.  This line allows us to predict the dependent variables for future observations (when the child is 5, according to our line, they will have 20 friends).  The line is defined by an equation {%m%}y=bx+a{%em%} where m is the slope of the line, and b is the y-intercept.  In the simplest form of linear regression, we can figure out m and b to find the line.  In more complex forms, such as {%m%}y=b\_{1}x\_{1} + b\_{2}x\_{2}+a{%em%}, we can predict y using multiple features.

Today, I'm going to shed some light on the internals to linear regression, and do some comparisons of various approaches in Python.  If you have not read my earlier post on [matrix inversion](/blog/inverting-your-very-own-matrix), I highly recommend it.

<!--more-->

Setup
--------------------------------

As you can see from the line and points above, the point of linear regression is to minimize the sum of squared errors.

We can express the various pairs in matrix form using the equation {%m%}y=bX + e{%em%} where X is the matrix of X observations, y is the vector of dependent values, b is the vector of coefficients, and e is a vector of errors (which we want to minimize).

{%math%}
\begin{bmatrix}
1 \\
4 \\
9 \\
16
\end{bmatrix}=
\begin{bmatrix}
1 & 1 \\
1 & 2 \\
1 & 3 \\
1 & 4
\end{bmatrix}
\begin{bmatrix}
b_{0} \\
b_{1}
\end{bmatrix} +
\begin{bmatrix}
e_{1} \\
e_{2} \\
e_{3} \\
e_{4}
\end{bmatrix}
{%endmath%}

We add in an extra column on the left of the X matrix to create the intercept, which is {%m%}b\_{0}{%em%}.  We can multiply out the matrices to get:

{%math%}
\begin{bmatrix}
1 \\
4 \\
9 \\
16
\end{bmatrix}=
\begin{bmatrix}
1b_{0} + 1b_{1} + e_{1}\\
1b_{0} + 2b_{1} + e_{2}\\
1b_{0} + 3b_{1}+ e_{3}\\
1b_{0} + 4b_{1}+ e_{4}
\end{bmatrix}
{%endmath%}

So, we want to solve for {%m%}b\_{0}{%em%} and {%m%}b\_{1}{%em%} in a way that minimizes the error.

Minimizing Error
--------------------------------



