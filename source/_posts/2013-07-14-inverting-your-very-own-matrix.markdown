---
layout: post
title: "Inverting your very own matrix"
date: 2013-07-14 11:19
comments: true
categories:
    - math
    - ML
    - machine learning
    - python
---

Introduction
----------------------------

I had my natural predilection towards math crushed out of me at some point in school, and since then, Math and I had a wary understanding.  I dabbled quietly, and Math turned a blind eye to me ignoring some of its deeper theory.  When I stuggled loudly, Math did its best to hide its smirks.  I generally refrained from throwing textbooks.

Ever since I started working on machine learning, it was necessary for Math and I to come to a deeper agreement.  As part of that agreement, I will be making posts about some useful techniques (I'm bad at negotiation).

The first topic will be matrix inversion.  Matrix inversion directly leads us into linear regression, and is helpful in other methods (although it can generally be bypassed by other techniques).

Matrices
----------------------------

I highly suggest you look up resources on [linear algebra](http://en.wikipedia.org/wiki/Linear_algebra) if you don't know what they are.  [Khan academy](https://www.khanacademy.org/math/linear-algebra) has some linear algebra resources, and [here is a free book](http://joshua.smcvt.edu/linearalgebra/#current_version) on linear algebra, although I cannot vouch for it, as I have not used it.

{% math %}
\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}
{% endmath %}

This is a simple 2x2 matrix.  The first number refers to the number of rows, and the second, the number of columns.  A matrix is just a construct that can hold and manipulate numbers in useful ways.  Matrices are central to machine learning.

Why invert?
-----------------------------

We need to invert matrices because we cannot divide matrices.  "Matrix division" is actually just multiplying a matrix by its inverse, to get the identity matrix.

Say we have the equation {%m%}1=YX{%em%}, with Y and X being matrices.  If we want to solve for X, we need to divide by Y.  Instead, we will have to multiply by the inverse of Y, so that we get {%m%}Y^{-1}=X{%em%}.

Crucially, we can only invert "square"(number of columns equals their number of rows) matrices.

Inversion methods
------------------------------

One intuitive method is called [Gauss-Jordan Elimination](http://en.wikipedia.org/wiki/Gaussian_elimination).

Let's say that we start with the following matrix, and we want to invert it:

{%math%}
\begin{bmatrix}
1 & 3 & 3\\
1 & 4 & 3\\
1 & 3 & 4
\end{bmatrix}
{%endmath%}

We first start by adding the identity matrix to the right of our matrix:

{%math%}
\left.\begin{matrix}
 1 & 3 & 3 \\
 1 & 4 & 3\\
 1 & 3 & 4
\end{matrix}\right|\begin{matrix}
1 & 0 & 0\\
0 & 1 & 0\\
0 & 0 & 1
\end{matrix}
{%endmath%}

The identity matrix is a special kind of matrix, that is equivalent to "1" in integer multiplication.  Any matrix times the identity matrix will equal the original matrix.  So, {%m%}XI=X{%em%}, where I is the identity matrix.

You can read more about [the identity matrix](http://faculty.wlc.edu/buelow/PRC/nt6-4.htm) and [matrix multiplication](http://www.mathsisfun.com/algebra/matrix-multiplying.html).

Now, we can do basic *row operations* on our combined matrix.  These are:

* We can swap any two rows.
* We can multiply any row by a number than isn't zero.
* We can add a row times a number to another row.

Our goal is to get our matrix on the left into [row echelon form](http://en.wikipedia.org/wiki/Row_echelon_form).  In simpler terms:

* All rows with at least one nonzero element are above any rows of all zeroes.
* The first nonzero number from the left of a nonzero row is always to the right of the first nonzero number of the row above it.
* All entries in a column below a leading entry are zeroes.

The identity matrix would be an example of a matrix in row echelon form.

We should perform our row operations on both the left hand and right hand matrices.  Once we are done converting our left hand matrix into row echelon form, our right hand matrix will be the inverse of the original matrix.