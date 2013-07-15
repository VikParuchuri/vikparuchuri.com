---
layout: post
title: "Find the determinant of a matrix"
date: 2013-07-15 19:11
comments: true
categories:
    - math
    - ML
    - machine learning
    - python
    - matrix
---

The determinant of a matrix is a number associated with a square (nxn) matrix.  The determinant can tell us if columns are linearly correlated, if a system has any nonzero solutions, and if a matrix is invertible.  See [the wikipedia entry](http://en.wikipedia.org/wiki/Determinant) for more details on this.

Computing a determinant is key to a lot of linear algebra, and by extension, to a lot of machine learning.  It is easy to calculate the determinant for a 2x2 matrix:

{%math%}
\begin{align}
A = \begin{bmatrix}
a & b\\
c & d
\end{bmatrix} \\
det A = \begin{vmatrix}
a & b \\
c & d
\end{vmatrix} \\
det A = ad - bc
\end{align}
{%endmath%}

Calculating the determinant for a bigger matrix is a bit more complicated, as we will see.  All the code for this is available from the [algorithms repository](https://github.com/vikparuchuri/algorithms).

<!--more-->

Laplace Expansion
---------------------------------

Determinants for larger matrices can be recursively obtained by the [Laplace Expansion](http://en.wikipedia.org/wiki/Laplace_expansion).  This computes the matrix determinant by making it equal to a sum of the scaled [minors](http://en.wikipedia.org/wiki/Minor_(matrix)) of the matrix.  A minor is the determinant of a matrix after deleting one row and one column (so a 3x3 matrix would turn into a 2x2 matrix).

So, let's start with this matrix:

{%math%}
A = \begin{bmatrix}
1 & 1 & 2\\
2 & 3 & 4 \\
3 & 4 & 5
\end{bmatrix}
{%endmath%}

To find the determinant of this matrix, we will first consult the formula for laplace expansion.

{%math%}
\sum_{j=1}^{n}(-1)^{1+j}a_{1j}M_{1j}
{%endmath%}

* {%m%}\sum\_{j=1}^{n}{%em%} - this means the sum from j=1 to n, in this case from the first column to the last one.
* {%m%}(-1)^{1+j}{%em%} - this ensures that alternating entries will be added and subtracted
* {%m%}a_{1j}{%em%} - the element in the matrix A at position 1,j.  So, A[1][j].
* {%m%}M_{1j}{%em%} - the minor of matrix A after removing row 1 and column j.

So, we are taking the sum from j=1 to n of -1 to the power (1+j) times the element a at index (1,j) in the original matrix times the minor of the matrix after removing row 1 and column j.

Let's expand this out for our matrix:

{%math%}
\begin{align}
1 * 1 * \begin{vmatrix}
3 & 4 \\
4 & 5
\end{vmatrix} + -1 * 1 * \begin{vmatrix}
2 & 4 \\
3 & 5
\end{vmatrix} + 1 * 2 * \begin{vmatrix}
2 & 3 \\
3 & 4
\end{vmatrix} \\
(3*5 - 4*4) -(2*5 - 4*3) + 2 * (2*4 - 3*3) \\
-1 +2 -2 \\
-1
\end{align}
{%endmath%}

So, our final determinant for this matrix is -1.

Implementation
------------------------------------

Now that we know the formula, we can formalize it in pseudocode:

```
Suppose that we have an nxn matrix A, with number of columns j.
if the number of columns is 2, compute the determinant using ad-bc and return.
Iterate through all of the columns.
    Calculate the multiplier by taking -1 to the power (1+j) times the element at A[1][j].
    Delete row 1 and column j from A, and create a new matrix X.
    Find the determinant of X through recursion (start again at the top with A=X).
    Multiply the determinant by the multiplier.
Sum all of the values and return.
```

This will work by recursing through our matrix to eventually reduce it to a series of 2x2 matrices, where the minors can be calculated.

In order to implement this, we will use the Matrix class that we [already developed](/blog/linear-regression-from-the-ground-up/), with one addition:

``` python
def del_column(self, key):
    """
    Delete a specified column
    """
    for i in xrange(0,self.rows):
        del self.X[i][key]
```

We can then implement a function that takes in a matrix object and computes its determinant:

``` python
def recursive_determinant(X):
    """
    Find the determinant in a recursive fashion.  Very inefficient
    X - Matrix object
    """
    #Must be a square matrix
    assert X.rows == X.cols
    #Must be at least 2x2
    assert X.rows > 1

    term_list = []
    #If more than 2 rows, reduce and solve in a piecewise fashion
    if X.cols>2:
        for j in xrange(0,X.cols):
            #Remove i and j columns
            new_x = deepcopy(X)
            del new_x[0]
            new_x.del_column(j)
            #Find the multiplier
            multiplier = X[0][j] * math.pow(-1,(2+j))
            #Recurse to find the determinant
            det = recursive_determinant(new_x)
            term_list.append(multiplier*det)
        return sum(term_list)
    else:
        return(X[0][0]*X[1][1] - X[0][1]*X[1][0])
```

We can verify if it works by testing out the matrix that we used above:

``` python
X = Matrix([[1,1,2],[2,3,4],[3,4,5]])
recursive_determinant(X)
```
```
-1.0
```

Applications
-------------------------------------

We can now test matrices to see if their columns are linearly dependent:

``` python
X = Matrix([[1,1,2],[2,2,4],[4,4,8]])
recursive_determinant(X)
```
```
0.0
```

The zero indicates that the columns are dependent on each other.

This will also tell us if the matrix can be inverted.

``` python
X = Matrix([[1,1,2],[2,2,4],[4,4,8]])
X.invert()
```

The above should cause an error.

Performance improvements
------------------------------

There are certainly other, higher-performing, solutions to finding a matrix determinant, like [LU Decomposition](http://en.wikipedia.org/wiki/LU_decomposition) but I like this because it makes it easy to figure out what is happening under the hood.

Possible performance improvements to this algorithm could be:

* Creating a global "minor cache" to avoid recomputing the same minors over and over for large matrices.
* Use the 3x3 formula instead of the 2x2 formula, which will avoid some recursion steps.