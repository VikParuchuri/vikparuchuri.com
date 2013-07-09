---
layout: post
title: "Predicting season records for NFL teams - overview"
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

*This is the first, non-technical, part of this series.  See [the second part](/blog/predicting-season-records-for-nfl-teams-part-2) for more detail.*

Introduction
-----------------

I was recently looking for a good machine learning task to try out, and I thought that doing something NFL-related would be interesting, because the NFL season is about to start (finally!).

Why was I looking for a good machine learning task to try out?  I have mostly done my data analysis work in R, but recently, I have been moving over to Python.  As part of that process, trying as many real-world problems out as possible helps.  I have also been developing a lightweight, modular, machine learning framework with my company, [Equirio](http://www.equirio.com).

We are going to start with a high-level, nontechnical overview of what we will be doing, and then follow that up with some technical details in a second post.

<!--more-->

High Level Overview
------------------

### Machine learning description

In machine learning, the goal is to learn from data and a known outcome to predict an unknown outcome for future data.  For example, let's say that we have data for how hot it has been for the past 10 days, and we want to predict how hot it will be tomorrow.  The data (how hot it has been for the past 10 days), and the outcome (how hot it will be tomorrow), will be somewhat correlated.  So, we can take data and outcomes from the past (ie, how hot it was for the 10 days before today, and how hot it was today), and use it to predict how hot it will be tomorrow.  This will not be a perfect prediction, and we will have some error, as we do not have all of the needed information.  Maybe there is a cold front coming in from the north, but in our simple model, we don't have that information.

### How does this apply to NFL data?

In my case, I wanted to predict something NFL-related.  One of the main problem in doing this kind of analysis, believe it or not, is easy access to data.  It is harder to get detailed per-game data such as who did what on what play, or even season-level statistics per player.

What is fairly easy to get is box score data, such as the below from [Pro football reference](http://www.pro-football-reference.com/boxscores/).

![upload template](../images/nfl-season/pfr-box.png)

You can see that it is very generic information: for each game, we have the winner, the loser, who was at home, how many points each team had, how many turnovers each team had, and how many yards each team gained.

Given this basic information, one of the simplest things we can predict is a teams win/loss record in a given season.

## Before we get started

Before we get started, we have to define an error metric and a baseline.  For example, if the algorithm predicts that the Washington Redskins will win 6 games next year, and they actually win 7 games, was the algorithm good?

To answer this, we need some baseline to measure against.  First, we will define the error metric.  The error metric will just be the mean of the absolute value of all the predictions minus all of the actual results.

Let's take the 2010 season (unfortunately, these tables may look bad in an RSS reader):

<div><table border="1" class="dataframe table display">  <thead>    <tr style="text-align: right;">      <th></th>      <th>next_year_wins</th>      <th>team</th>      <th>year</th>      <th>total_wins</th>    </tr>  </thead>  <tbody>    <tr>      <th>1440</th>      <td> 14</td>      <td>   new orleans saints</td>      <td> 2010</td>      <td> 11</td>    </tr>    <tr>      <th>1441</th>      <td> 12</td>      <td>  pittsburgh steelers</td>      <td> 2010</td>      <td> 14</td>    </tr>    <tr>      <th>1442</th>      <td> 15</td>      <td> new england patriots</td>      <td> 2010</td>      <td> 14</td>    </tr>    <tr>      <th>1443</th>      <td>  4</td>      <td> tampa bay buccaneers</td>      <td> 2010</td>      <td> 10</td>    </tr>    <tr>      <th>1444</th>      <td>  8</td>      <td>  philadelphia eagles</td>      <td> 2010</td>      <td> 10</td>    </tr>    <tr>      <th>1445</th>      <td>  2</td>      <td>       st. louis rams</td>      <td> 2010</td>      <td>  7</td>    </tr>    <tr>      <th>1446</th>      <td> 10</td>      <td>      atlanta falcons</td>      <td> 2010</td>      <td> 13</td>    </tr>    <tr>      <th>1447</th>      <td>  4</td>      <td>     cleveland browns</td>      <td> 2010</td>      <td>  5</td>    </tr>    <tr>      <th>1448</th>      <td>  9</td>      <td>   cincinnati bengals</td>      <td> 2010</td>      <td>  4</td>    </tr>    <tr>      <th>1449</th>      <td>  8</td>      <td>      oakland raiders</td>      <td> 2010</td>      <td>  8</td>    </tr>    <tr>      <th>1450</th>      <td>  6</td>      <td>        buffalo bills</td>      <td> 2010</td>      <td>  4</td>    </tr>    <tr>      <th>1451</th>      <td> 13</td>      <td>      new york giants</td>      <td> 2010</td>      <td> 10</td>    </tr>    <tr>      <th>1452</th>      <td> 15</td>      <td>    green bay packers</td>      <td> 2010</td>      <td> 14</td>    </tr>    <tr>      <th>1453</th>      <td>  9</td>      <td>       denver broncos</td>      <td> 2010</td>      <td>  4</td>    </tr>    <tr>      <th>1454</th>      <td>  6</td>      <td>    carolina panthers</td>      <td> 2010</td>      <td>  2</td>    </tr>    <tr>      <th>1455</th>      <td> 10</td>      <td>        detroit lions</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1456</th>      <td>  0</td>      <td>     tennessee oilers</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1457</th>      <td>  0</td>      <td>  st. louis cardinals</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1458</th>      <td>  8</td>      <td>        chicago bears</td>      <td> 2010</td>      <td> 12</td>    </tr>    <tr>      <th>1459</th>      <td>  0</td>      <td>    phoenix cardinals</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1460</th>      <td> 14</td>      <td>  san francisco 49ers</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1461</th>      <td>  2</td>      <td>   indianapolis colts</td>      <td> 2010</td>      <td> 10</td>    </tr>    <tr>      <th>1462</th>      <td>  5</td>      <td>  washington redskins</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1463</th>      <td>  7</td>      <td>     seattle seahawks</td>      <td> 2010</td>      <td>  8</td>    </tr>    <tr>      <th>1464</th>      <td>  8</td>      <td>    arizona cardinals</td>      <td> 2010</td>      <td>  5</td>    </tr>    <tr>      <th>1465</th>      <td> 11</td>      <td>       houston texans</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1466</th>      <td>  9</td>      <td>     tennessee titans</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1467</th>      <td>  5</td>      <td> jacksonville jaguars</td>      <td> 2010</td>      <td>  8</td>    </tr>    <tr>      <th>1468</th>      <td>  0</td>      <td>     los angeles rams</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1469</th>      <td>  8</td>      <td>   san diego chargers</td>      <td> 2010</td>      <td>  9</td>    </tr>    <tr>      <th>1470</th>      <td>  6</td>      <td>       miami dolphins</td>      <td> 2010</td>      <td>  7</td>    </tr>    <tr>      <th>1471</th>      <td>  8</td>      <td>        new york jets</td>      <td> 2010</td>      <td> 13</td>    </tr>    <tr>      <th>1472</th>      <td>  0</td>      <td>      baltimore colts</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1473</th>      <td> 13</td>      <td>     baltimore ravens</td>      <td> 2010</td>      <td> 13</td>    </tr>    <tr>      <th>1474</th>      <td>  7</td>      <td>   kansas city chiefs</td>      <td> 2010</td>      <td> 10</td>    </tr>    <tr>      <th>1475</th>      <td>  0</td>      <td>      boston patriots</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1476</th>      <td>  0</td>      <td>       houston oilers</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1477</th>      <td>  0</td>      <td>  los angeles raiders</td>      <td> 2010</td>      <td>  0</td>    </tr>    <tr>      <th>1478</th>      <td>  3</td>      <td>    minnesota vikings</td>      <td> 2010</td>      <td>  6</td>    </tr>    <tr>      <th>1479</th>      <td>  8</td>      <td>       dallas cowboys</td>      <td> 2010</td>      <td>  6</td>    </tr>  </tbody></table>

</div><br/><br/>

We can see each team, along with how many games it won in 2010 (total_wins), and how many it won in 2011 (next_year_wins).  Let's say that we predict that each team will win the same amount of games in 2011 as it won in 2010.  Thankfully, we already know how many games each team won, so we can use our error metric to calculate the error.

Once we remove the 2012 season (we don't know what the wins will be next year), and any teams with 0 victories (teams that do not exist anymore), we can calculate the total error for all of the seasons.  The error comes out to be *3.1*.  So, if we just assume that teams will win as many games next year, the actual number will, on average be +/- *3.1* games away.

Let's try another baseline.  It's well known that teams tend to regress towards the mean.  So, let's just go with 8 as the number of victories for every team (in a 16 game season, 8 would be average).  If we do this, we actually get a better result.  The error is now only *2.8*.  Let's use this as our baseline.  If our system can reduce the error, than we can say that our system is potentially useful.

### Training and Prediction

So, we take as much past data as we can (I used data from 1980 to now), convert per-game data into per-season data by calculating a lot of features for each team, such as *how many points the team scored in their last 5 games of the season*, or *opponent record for the season*.  A feature is basically a decision criteria.  If I want to know if it will be sunny tomorrow, one data point that I might want is if it is sunny or not today.

We can then train our machine learning model, and evaluate its error.  Our error here is *2.6*, which is better than the baseline.

We can then use our model to predict how teams will perform in future seasons (in this case, 2013).

After our training, we get predictions, which come out to:

<div>
<table border="1" class="dataframe table display">  <thead>    <tr style="text-align: right;">      <th></th>      <th>team</th>      <th>year</th>      <th>total_wins</th>      <th>predicted_2013_wins</th>    </tr>  </thead>  <tbody>    <tr>      <th>1544</th>      <td>    arizona cardinals</td>      <td> 2012</td>      <td>  5</td>      <td>  5.95</td>    </tr>    <tr>      <th>1526</th>      <td>      atlanta falcons</td>      <td> 2012</td>      <td> 14</td>      <td>  9.63</td>    </tr>    <tr>      <th>1552</th>      <td>      baltimore colts</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1553</th>      <td>     baltimore ravens</td>      <td> 2012</td>      <td> 14</td>      <td>  9.91</td>    </tr>    <tr>      <th>1555</th>      <td>      boston patriots</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1530</th>      <td>        buffalo bills</td>      <td> 2012</td>      <td>  6</td>      <td>  7.16</td>    </tr>    <tr>      <th>1534</th>      <td>    carolina panthers</td>      <td> 2012</td>      <td>  7</td>      <td>  7.85</td>    </tr>    <tr>      <th>1538</th>      <td>        chicago bears</td>      <td> 2012</td>      <td> 10</td>      <td>  9.43</td>    </tr>    <tr>      <th>1528</th>      <td>   cincinnati bengals</td>      <td> 2012</td>      <td> 10</td>      <td>  8.65</td>    </tr>    <tr>      <th>1527</th>      <td>     cleveland browns</td>      <td> 2012</td>      <td>  5</td>      <td>  6.56</td>    </tr>    <tr>      <th>1559</th>      <td>       dallas cowboys</td>      <td> 2012</td>      <td>  8</td>      <td>  8.27</td>    </tr>    <tr>      <th>1533</th>      <td>       denver broncos</td>      <td> 2012</td>      <td> 13</td>      <td>  9.49</td>    </tr>    <tr>      <th>1535</th>      <td>        detroit lions</td>      <td> 2012</td>      <td>  4</td>      <td>  7.33</td>    </tr>    <tr>      <th>1532</th>      <td>    green bay packers</td>      <td> 2012</td>      <td> 12</td>      <td> 10.87</td>    </tr>    <tr>      <th>1556</th>      <td>       houston oilers</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1545</th>      <td>       houston texans</td>      <td> 2012</td>      <td> 13</td>      <td> 10.00</td>    </tr>    <tr>      <th>1541</th>      <td>   indianapolis colts</td>      <td> 2012</td>      <td> 11</td>      <td>  9.17</td>    </tr>    <tr>      <th>1547</th>      <td> jacksonville jaguars</td>      <td> 2012</td>      <td>  2</td>      <td>  6.05</td>    </tr>    <tr>      <th>1554</th>      <td>   kansas city chiefs</td>      <td> 2012</td>      <td>  2</td>      <td>  6.35</td>    </tr>    <tr>      <th>1557</th>      <td>  los angeles raiders</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1548</th>      <td>     los angeles rams</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1550</th>      <td>       miami dolphins</td>      <td> 2012</td>      <td>  7</td>      <td>  7.74</td>    </tr>    <tr>      <th>1558</th>      <td>    minnesota vikings</td>      <td> 2012</td>      <td> 10</td>      <td>  8.71</td>    </tr>    <tr>      <th>1522</th>      <td> new england patriots</td>      <td> 2012</td>      <td> 13</td>      <td> 11.44</td>    </tr>    <tr>      <th>1520</th>      <td>   new orleans saints</td>      <td> 2012</td>      <td>  7</td>      <td>  8.10</td>    </tr>    <tr>      <th>1531</th>      <td>      new york giants</td>      <td> 2012</td>      <td>  9</td>      <td>  8.20</td>    </tr>    <tr>      <th>1551</th>      <td>        new york jets</td>      <td> 2012</td>      <td>  6</td>      <td>  6.65</td>    </tr>    <tr>      <th>1529</th>      <td>      oakland raiders</td>      <td> 2012</td>      <td>  4</td>      <td>  6.55</td>    </tr>    <tr>      <th>1524</th>      <td>  philadelphia eagles</td>      <td> 2012</td>      <td>  4</td>      <td>  6.84</td>    </tr>    <tr>      <th>1539</th>      <td>    phoenix cardinals</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1521</th>      <td>  pittsburgh steelers</td>      <td> 2012</td>      <td>  8</td>      <td>  9.41</td>    </tr>    <tr>      <th>1549</th>      <td>   san diego chargers</td>      <td> 2012</td>      <td>  7</td>      <td>  7.81</td>    </tr>    <tr>      <th>1540</th>      <td>  san francisco 49ers</td>      <td> 2012</td>      <td> 14</td>      <td>  9.72</td>    </tr>    <tr>      <th>1543</th>      <td>     seattle seahawks</td>      <td> 2012</td>      <td> 12</td>      <td>  9.06</td>    </tr>    <tr>      <th>1537</th>      <td>  st. louis cardinals</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1525</th>      <td>       st. louis rams</td>      <td> 2012</td>      <td>  7</td>      <td>  6.36</td>    </tr>    <tr>      <th>1523</th>      <td> tampa bay buccaneers</td>      <td> 2012</td>      <td>  7</td>      <td>  7.25</td>    </tr>    <tr>      <th>1536</th>      <td>     tennessee oilers</td>      <td> 2012</td>      <td>  0</td>      <td>  0.00</td>    </tr>    <tr>      <th>1546</th>      <td>     tennessee titans</td>      <td> 2012</td>      <td>  6</td>      <td>  6.93</td>    </tr>    <tr>      <th>1542</th>      <td>  washington redskins</td>      <td> 2012</td>      <td> 10</td>      <td>  9.12</td>    </tr>  </tbody></table>
    <script>
    $('.table').dataTable({
        "bPaginate": false,
        "bLengthChange": false,
        "bSort": false,
        "bStateSave": true,
        "sScrollY": 450,
        "sScrollX": 500,
        "aLengthMenu": [[50, 100, -1], [50, 100, "All"]],
        "iDisplayLength": 40,
    });
    </script><br/>
</div><br/><br/>






