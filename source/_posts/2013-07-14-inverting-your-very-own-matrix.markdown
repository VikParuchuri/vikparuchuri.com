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

I had my natural predilection towards math crushed out of me at some point in school, and after that point, Math (yes, we are referring to the higher power of math) and I had a wary understanding.  I dabbled quietly, and Math turned a blind eye to me ignoring some of its deeper theory.  When I stuggled loudly, Math did its best to hide its smirks.  I generally refrained from throwing textbooks.

Ever since I started working on machine learning, it was necessary for Math and I to come to a deeper agreement.  As part of that, I will be making posts about some useful techniques (I'm bad at negotiation).

The first topic will be matrix inversion.  Matrix inversion directly leads us into linear regression, and is helpful in other methods, although it can generally be bypassed by other techniques.

We will first look at the theory, and then implement it in Python.  You can get the code from [Github](https://github.com/vikparuchuri/algorithms).

<!--more-->

Matrices
----------------------------

I highly suggest you look up resources on [linear algebra](http://en.wikipedia.org/wiki/Linear_algebra) if you don't know what matrices are.  [Khan academy](https://www.khanacademy.org/math/linear-algebra) has some linear algebra resources, and [here is a free book](http://joshua.smcvt.edu/linearalgebra/#current_version) on linear algebra, although I cannot vouch for it, as I have not used it.

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

Solving the basic equation for multiple linear regression requires matrix inversion.

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

### Row operations

You can read more about [the identity matrix](http://faculty.wlc.edu/buelow/PRC/nt6-4.htm) and [matrix multiplication](http://www.mathsisfun.com/algebra/matrix-multiplying.html).

Now, we can do basic *row operations* on our combined matrix.  These are:

* We can swap any two rows.
* We can multiply any row by a number than isn't zero.
* We can add a row times a number to another row.

### Row echelon form

Our goal is to get our matrix on the left into [row echelon form](http://en.wikipedia.org/wiki/Row_echelon_form).  In simpler terms:

* All rows with at least one nonzero element are above any rows of all zeroes.
* The first nonzero number from the left of a nonzero row is always to the right of the first nonzero number of the row above it.
* All entries in a column below a leading entry are zeroes.

The identity matrix would be an example of a matrix in row echelon form.

We should perform our row operations on both the left hand and right hand matrices.  Once we are done converting our left hand matrix into row echelon form, our right hand matrix will be the inverse of the original matrix.

### Solution

First, we subtract the first row from rows 2 and 3 of the combined matrix (this fits the last basic row operation, as we are multiplying by -1).  When we do this, we subtract row 1 of the left hand matrix from rows 2 and 3 of the left hand matrix, and row 1 of the right hand matrix from rows 2 and 3 of the right hand matrix.

{%math%}
\left.\begin{matrix}
 1 & 3 & 3 \\
 0 & 1 & 0\\
 0 & 0 & 1
\end{matrix}\right|\begin{matrix}
1 & 0 & 0\\
-1 & 1 & 0\\
-1 & 0 & 1
\end{matrix}
{%endmath%}

This looks like we are well on our way to the identity matrix.  Now, we subtract 3 times the second row from the first row.

{%math%}
\left.\begin{matrix}
 1 & 0 & 3 \\
 0 & 1 & 0\\
 0 & 0 & 1
\end{matrix}\right|\begin{matrix}
4 & -3 & 0\\
-1 & 1 & 0\\
-1 & 0 & 1
\end{matrix}
{%endmath%}

And we do the same with the final row:

{%math%}
\left.\begin{matrix}
 1 & 0 & 0 \\
 0 & 1 & 0\\
 0 & 0 & 1
\end{matrix}\right|\begin{matrix}
7 & -3 & -3\\
-1 & 1 & 0\\
-1 & 0 & 1
\end{matrix}
{%endmath%}

So, now that our left hand matrix is in row echelon form (looks like the identity matrix), our inverse is on the right hand:

{%math%}
\begin{bmatrix}
7 & -3 & -3\\
-1 & 1 & 0\\
-1 & 0 & 1
\end{bmatrix}
{%endmath%}

Implementation
--------------------------

### Theory

We can devise an algorithm for Gauss-Jordan Elimination.

Roughly, it goes:

```
Start with i=1, j=1, and matrix Z.
Concatenate Z with its identity matrix as we did above to make matrix X.
Is everything in the column j at and below X[i][j] zero?  If yes, our job is done, increment j and restart from the top.  If j equals the number of columns in Z, we are done.
k is the row index of the first non-zero column entry.
If k!=i, swap row k and row i, so that the highest value is reduced first.
Divide row i by X[i][j], in order to make X[i][j]=1.
Iterate through all the non-i rows, and subtract their j-column value times the i-row from them.  This will ensure that all values in column j that are not in row i will be zero.  This is a requirement of row echelon form.
If i equals the number of rows in X or j equals the number of columns in the original matrix Z (not counting the identity), we are done.
Otherwise, increment i and j and start from the top.
```

This algorithm will loop through each column, and convert it to row-echelon form.  At the end, the right side of the matrix X will be our inverse.  For more information on this, see [this book](http://www.numbertheory.org/book/mp103.pdf).

### Python

The python implementation of this can be found in the [algorithms repository](https://github.com/vikparuchuri/algorithms).

Here is the full code:

{% gist 5994925 %}

Our input will be a list of lists, and we can verify it is working by trying out the matrix we inverted by hand earlier:

```
invert([[1,3,3],[1,4,3],[1,3,4]])
On col 0 and row 0
On col 1 and row 1
On col 2 and row 2
Out[254]: [[7.0, -3.0, -3.0], [-1.0, 1.0, 0.0], [-1.0, 0.0, 1.0]]
```

Happy inverting!
-------------------------

Hopefully this was an interesting entry.  In my next few posts, I will go through linear regression and the other matrix operations that are needed to solve for it.



