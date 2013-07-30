---
layout: post
title: "How divided is the Senate?"
date: 2013-07-29 22:01
comments: true
categories:
    - R
    - politics
    - senate
    - democrats
    - republicans
    - congress
    - python
---

I very seldom pay attention to politics directly, because politics have always seemed a bit circular and cyclical to me.  Most of the political news that I take in ends up worming its way into the news sources that I do consume, like the excellent [longform.org](http://www.longform.org).  Even given my limited intake of political news, one trend that I have noticed lately is the increasing number of references to the Senate as "polarized" or "divided."  [Here](http://voteview.com/political_polarization.asp) is a link to an interesting series of charts on polarization.  Is it possible to quantify this polarization?  Can quantifying the polarization enable us to draw interesting conclusions?

As I started to walk down this road, I figured that it would be tough to find the data that I needed.  My time in the US [foreign service](http://en.wikipedia.org/wiki/United_States_Foreign_Service) showed me just how slow the government can be at effectively publishing and using data.  Imagine my surprise when I found that the [senate website](http://www.senate.gov/pagelayout/legislative/a_three_sections_with_teasers/votes.htm) has a very convenient listing of all of the votes from the 101st congress to the 113th (current) congress.  This data tells us, for each vote, whether each senator voted yes, no, or abstained.

From the vote data, we can generate plots showing how polarized the Senate is.  We will assume that two people are not polarized if they have similar voting patterns.  If we take only [this vote](http://www.senate.gov/legislative/LIS/roll_call_lists/roll_call_vote_cfm.cfm?congress=113&session=1&vote=00187), we would assume that Senator Ayotte and Senator Alexander, who both voted no, are not polarized, as they share the same opinion.  This is well and good, but one bill isn't really reflective of the voting records of the two Senators.  If we really want to figure out where they stand, we would need to perform the analysis across all votes.  I will describe the process further down, but for now, let's jump to a polarization chart:

![senate polarization](../images/senate-polarization/senate.png)

The above chart has a dot for each Senator, although only some senators are labelled due to space constraints.  The further apart the dots are, the more the views of the two senators contrast.  Dots are shaded by political affiliation.  How can we generate this chart?  Keep reading to find out.

<!--more-->

Getting senate data
------------------------------------------------

The first thing that we need to do is get the Senate data.  We can start on [this page](http://www.senate.gov/pagelayout/legislative/a_three_sections_with_teasers/votes.htm).  We see a roll call table in the bottom right.  Each roll call table has a listing of each vote in a given congress:

![roll call table](../images/senate-polarization/roll_call_table.png)

If we click on the vote, we can see the results of the vote.

We can easily write a web scraper, such as the one [i wrote](https://github.com/VikParuchuri/political-positions/blob/master/crawler/crawler/spiders/scrape.py) to grab this data and store it.  This will give us a file of all the voting data.

We can read the file into R (see [this script](https://github.com/VikParuchuri/political-positions/blob/master/senate_analyzer.R)), which gives us a list of lists containing all the vote information.  Here is an excerpt:

```r
> senate[[2]]
$number
[1] "00187"

$session
[1] "1"

$data
      Coons (D-DE),       McCain (R-AZ),    Chambliss (R-GA),      Franken (D-MN),       Inhofe (R-OK),      Johnson (D-SD),       Tester (D-MT),       Carper (D-DE),
               "Yea"                "Nay"                "Nay"                "Yea"                "Nay"                "Yea"                "Yea"                "Yea"
    Schumer (D-NY),   Gillibrand (D-NY),      Fischer (R-NE),       Bennet (D-CO),     Barrasso (R-WY),      Shaheen (D-NH),      Boozman (R-AR),         Kirk (R-IL),
               "Yea"                "Yea"                "Nay"                "Yea"                "Nay"                "Yea"                "Nay"                "Nay"
```

We can reformat this into a dataframe that has a record for each vote by each senator, and the congress/session/vote metadata:

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th></th><th>sen</th><th>vote</th><th>congress</th><th>number</th><th>session</th></tr>
</thead>
<tbody>
<tr><td>1</td><td>Coons (D-DE)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>2</td><td>McCain (R-AZ)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>3</td><td>Chambliss (R-GA)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>4</td><td>Franken (D-MN)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>5</td><td>Inhofe (R-OK)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>6</td><td>Johnson (D-SD)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>7</td><td>Tester (D-MT)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>8</td><td>Carper (D-DE)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>9</td><td>Schumer (D-NY)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
<tr><td>10</td><td>Gillibrand (D-NY)</td><td>Yea</td><td>113</td><td>188</td><td>1</td></tr>
</tbody>
</table>
<br/><br/>
</div>

This is just a short excerpt from the actual dataframe, which has `798,835` individual vote records.

Generating a vote matrix
--------------------------------------------------

Now we have a long list of all the votes by the senators, but we really want something like this:

```
               Vote1      Vote2      Vote3
Senator1    (Yes/No)   (Yes/No)   (Yes/No)
Senator2    (Yes/No)   (Yes/No)   (Yes/No)
Senator3    (Yes/No)   (Yes/No)   (Yes/No)
```

To accomplish this, we will reformat our data by looping through each congress, then looping through each session in the congress, then looping through each vote in the session, and extracting the vote information.

We end up with this:

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th></th><th>X.113.1.1.</th><th>X.113.1.2.</th><th>X.113.1.3.</th><th>X.113.1.4.</th><th>X.113.1.5.</th><th>X.113.1.188.</th><th>name</th><th>party</th><th>state</th></tr>
</thead>
<tbody>
<tr><td>Coons (D-DE)</td><td>1</td><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Coons</td><td>D</td><td>DE</td></tr>
<tr><td>McCain (R-AZ)</td><td>1</td><td>1</td><td>0</td><td>0</td><td>1</td><td>1</td><td>McCain</td><td>R</td><td>AZ</td></tr>
<tr><td>Chambliss (R-GA)</td><td>2</td><td>2</td><td>1</td><td>0</td><td>1</td><td>1</td><td>Chambliss</td><td>R</td><td>GA</td></tr>
<tr><td>Franken (D-MN)</td><td>1</td><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Franken</td><td>D</td><td>MN</td></tr>
<tr><td>Inhofe (R-OK)</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>1</td><td>Inhofe</td><td>R</td><td>OK</td></tr>
<tr><td>Johnson (D-SD)</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Johnson</td><td>D</td><td>SD</td></tr>
<tr><td>Tester (D-MT)</td><td>1</td><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Tester</td><td>D</td><td>MT</td></tr>
<tr><td>Carper (D-DE)</td><td>1</td><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Carper</td><td>D</td><td>DE</td></tr>
<tr><td>Schumer (D-NY)</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Schumer</td><td>D</td><td>NY</td></tr>
<tr><td>Gillibrand (D-NY)</td><td>2</td><td>2</td><td>0</td><td>1</td><td>1</td><td>1</td><td>Gillibrand</td><td>D</td><td>NY</td></tr>
</tbody>
</table>
<br/><br/>
</div>

The above is an excerpt, so we are missing a lot of columns.  As you can see, the leading column names are in the format congress.session.vote.

Decomposing vote matrix
----------------------------------------------

Once we have a vote matrix, we can use [singular value decomposition](http://en.wikipedia.org/wiki/Singular_value_decomposition) to reduce the vote matrix to two dimensions so that we can plot points for each senator.  SVD works by trying to combine information (variance) from the multiple columns into less columns.

We end up with this for the 113th Congress:

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th></th><th>x</th><th>y</th><th>label_code</th><th>label</th><th>state</th><th>name</th><th>full_name</th></tr>
</thead>
<tbody>
<tr><td>1</td><td>-0.0348802242728007</td><td>-0.0885011150722473</td><td>1</td><td>D</td><td>DE</td><td>Coons</td><td>Coons (D-DE)</td></tr>
<tr><td>2</td><td>0.0139333391911509</td><td>0.0619623474516745</td><td>3</td><td>R</td><td>AZ</td><td>McCain</td><td>McCain (R-AZ)</td></tr>
<tr><td>3</td><td>-0.00545157078068947</td><td>0.10221895824691</td><td>3</td><td>R</td><td>GA</td><td>Chambliss</td><td>Chambliss (R-GA)</td></tr>
<tr><td>4</td><td>-0.0362627872805723</td><td>-0.0939015240228452</td><td>1</td><td>D</td><td>MN</td><td>Franken</td><td>Franken (D-MN)</td></tr>
<tr><td>5</td><td>-0.0077981548158297</td><td>0.142184554607829</td><td>3</td><td>R</td><td>OK</td><td>Inhofe</td><td>Inhofe (R-OK)</td></tr>
<tr><td>6</td><td>-0.0426066858139772</td><td>-0.0904442823377511</td><td>1</td><td>D</td><td>SD</td><td>Johnson</td><td>Johnson (D-SD)</td></tr>
<tr><td>7</td><td>-0.044554280398656</td><td>-0.0545406205845917</td><td>1</td><td>D</td><td>MT</td><td>Tester</td><td>Tester (D-MT)</td></tr>
<tr><td>8</td><td>-0.0356973327991686</td><td>-0.0826384224297392</td><td>1</td><td>D</td><td>DE</td><td>Carper</td><td>Carper (D-DE)</td></tr>
<tr><td>9</td><td>-0.0371022993314578</td><td>-0.0968419990947506</td><td>1</td><td>D</td><td>NY</td><td>Schumer</td><td>Schumer (D-NY)</td></tr>
<tr><td>10</td><td>-0.0331094361241657</td><td>-0.0970600008256449</td><td>1</td><td>D</td><td>NY</td><td>Gillibrand</td><td>Gillibrand (D-NY)</td></tr>
<tr><td>11</td><td>-0.0156804216297059</td><td>0.117291940698239</td><td>3</td><td>R</td><td>NE</td><td>Fischer</td><td>Fischer (R-NE)</td></tr>
<tr><td>12</td><td>-0.0289778208474004</td><td>-0.0824901409317521</td><td>1</td><td>D</td><td>CO</td><td>Bennet</td><td>Bennet (D-CO)</td></tr>
<tr><td>13</td><td>-0.0180558122137665</td><td>0.136687567805345</td><td>3</td><td>R</td><td>WY</td><td>Barrasso</td><td>Barrasso (R-WY)</td></tr>
<tr><td>14</td><td>-0.0364473257536752</td><td>-0.0839036582733608</td><td>1</td><td>D</td><td>NH</td><td>Shaheen</td><td>Shaheen (D-NH)</td></tr>
<tr><td>15</td><td>-0.00815268808751543</td><td>0.113170007558517</td><td>3</td><td>R</td><td>AR</td><td>Boozman</td><td>Boozman (R-AR)</td></tr>
<tr><td>16</td><td>-0.0216403625336666</td><td>0.0719986192299611</td><td>3</td><td>R</td><td>IL</td><td>Kirk</td><td>Kirk (R-IL)</td></tr>
<tr><td>17</td><td>-0.029568048844845</td><td>-0.0858533841278676</td><td>1</td><td>D</td><td>FL</td><td>Nelson</td><td>Nelson (D-FL)</td></tr>
<tr><td>18</td><td>-0.016413732654005</td><td>0.128746686935355</td><td>3</td><td>R</td><td>TX</td><td>Cornyn</td><td>Cornyn (R-TX)</td></tr>
<tr><td>19</td><td>-0.0298919244925452</td><td>-0.0880029993263122</td><td>1</td><td>D</td><td>MN</td><td>Klobuchar</td><td>Klobuchar (D-MN)</td></tr>
<tr><td>20</td><td>0.0129837663631103</td><td>0.081881278983249</td><td>3</td><td>R</td><td>AZ</td><td>Flake</td><td>Flake (R-AZ)</td></tr>
<tr><td>21</td><td>0.00426679790452548</td><td>0.0906706864320044</td><td>3</td><td>R</td><td>NE</td><td>Johanns</td><td>Johanns (R-NE)</td></tr>
<tr><td>22</td><td>0.00273613995205289</td><td>0.108642449568633</td><td>3</td><td>R</td><td>KS</td><td>Moran</td><td>Moran (R-KS)</td></tr>
<tr><td>23</td><td>-0.019258803509291</td><td>0.13062638910029</td><td>3</td><td>R</td><td>IA</td><td>Grassley</td><td>Grassley (R-IA)</td></tr>
<tr><td>24</td><td>0.547215825548056</td><td>-0.0593289149366795</td><td>1</td><td>D</td><td>MA</td><td>Markey</td><td>Markey (D-MA)</td></tr>
<tr><td>25</td><td>-0.0353227186543595</td><td>-0.0976376341230047</td><td>1</td><td>D</td><td>HI</td><td>Schatz</td><td>Schatz (D-HI)</td></tr>
<tr><td>26</td><td>-0.00956413282205122</td><td>0.129548524717885</td><td>3</td><td>R</td><td>ID</td><td>Risch</td><td>Risch (R-ID)</td></tr>
<tr><td>27</td><td>-0.0229079628265486</td><td>-0.0869471509735395</td><td>1</td><td>D</td><td>PA</td><td>Casey</td><td>Casey (D-PA)</td></tr>
<tr><td>28</td><td>-0.0115860482094747</td><td>0.131875057650696</td><td>3</td><td>R</td><td>WY</td><td>Enzi</td><td>Enzi (R-WY)</td></tr>
<tr><td>29</td><td>0.00411918634805181</td><td>0.09322702104917</td><td>3</td><td>R</td><td>MS</td><td>Wicker</td><td>Wicker (R-MS)</td></tr>
<tr><td>30</td><td>-0.026944901403195</td><td>-0.0707999020236366</td><td>2</td><td>I</td><td>ME</td><td>King</td><td>King (I-ME)</td></tr>
<tr><td>31</td><td>-0.0361826736711891</td><td>-0.0964110651487557</td><td>1</td><td>D</td><td>WI</td><td>Baldwin</td><td>Baldwin (D-WI)</td></tr>
<tr><td>32</td><td>-0.0268215357509806</td><td>-0.0890432282928414</td><td>1</td><td>D</td><td>OR</td><td>Wyden</td><td>Wyden (D-OR)</td></tr>
<tr><td>33</td><td>-0.0122248435323734</td><td>-0.0754120081322735</td><td>1</td><td>D</td><td>AK</td><td>Begich</td><td>Begich (D-AK)</td></tr>
<tr><td>34</td><td>-0.0245751728057898</td><td>0.141367663303047</td><td>3</td><td>R</td><td>KS</td><td>Roberts</td><td>Roberts (R-KS)</td></tr>
<tr><td>35</td><td>-0.00345843619743554</td><td>0.113606389164264</td><td>3</td><td>R</td><td>NC</td><td>Burr</td><td>Burr (R-NC)</td></tr>
<tr><td>36</td><td>-0.0292497277663385</td><td>-0.085407101553328</td><td>1</td><td>D</td><td>NM</td><td>Heinrich</td><td>Heinrich (D-NM)</td></tr>
<tr><td>37</td><td>-0.0394437787124538</td><td>-0.10050126652756</td><td>1</td><td>D</td><td>HI</td><td>Hirono</td><td>Hirono (D-HI)</td></tr>
<tr><td>38</td><td>-0.0192640058583086</td><td>-0.0370242407531159</td><td>1</td><td>D</td><td>AR</td><td>Pryor</td><td>Pryor (D-AR)</td></tr>
<tr><td>39</td><td>-0.0430280450634182</td><td>-0.0933459229654493</td><td>1</td><td>D</td><td>VT</td><td>Leahy</td><td>Leahy (D-VT)</td></tr>
<tr><td>40</td><td>-0.0109758213217893</td><td>0.103451003006734</td><td>3</td><td>R</td><td>NH</td><td>Ayotte</td><td>Ayotte (R-NH)</td></tr>
<tr><td>41</td><td>-0.0404919136594251</td><td>-0.0943042109057099</td><td>1</td><td>D</td><td>MI</td><td>Stabenow</td><td>Stabenow (D-MI)</td></tr>
<tr><td>42</td><td>-0.0273071654738363</td><td>-0.0924267270931892</td><td>1</td><td>D</td><td>MD</td><td>Mikulski</td><td>Mikulski (D-MD)</td></tr>
<tr><td>43</td><td>-0.00834005326900628</td><td>0.11718205053358</td><td>3</td><td>R</td><td>NV</td><td>Heller</td><td>Heller (R-NV)</td></tr>
<tr><td>44</td><td>-0.0228120494502621</td><td>-0.0501247061910197</td><td>1</td><td>D</td><td>NC</td><td>Hagan</td><td>Hagan (D-NC)</td></tr>
<tr><td>45</td><td>-0.0398873356531087</td><td>-0.0933244585933005</td><td>1</td><td>D</td><td>IL</td><td>Durbin</td><td>Durbin (D-IL)</td></tr>
<tr><td>46</td><td>-0.0381855188001876</td><td>-0.086229921349195</td><td>1</td><td>D</td><td>OR</td><td>Merkley</td><td>Merkley (D-OR)</td></tr>
<tr><td>47</td><td>-0.0195976054340086</td><td>-0.091788450374095</td><td>1</td><td>D</td><td>CO</td><td>Udall</td><td>Udall (D-CO)</td></tr>
<tr><td>48</td><td>-0.00926246130655879</td><td>-0.0188892715011417</td><td>1</td><td>D</td><td>WV</td><td>Manchin</td><td>Manchin (D-WV)</td></tr>
<tr><td>49</td><td>0.00966111542420832</td><td>0.0914499893026106</td><td>3</td><td>R</td><td>ND</td><td>Hoeven</td><td>Hoeven (R-ND)</td></tr>
<tr><td>50</td><td>0.0031092086697181</td><td>0.0851622652898145</td><td>3</td><td>R</td><td>MO</td><td>Blunt</td><td>Blunt (R-MO)</td></tr>
<tr><td>51</td><td>-0.00562041044072087</td><td>0.0103468267205128</td><td>3</td><td>R</td><td>ME</td><td>Collins</td><td>Collins (R-ME)</td></tr>
<tr><td>52</td><td>-0.00825702591654079</td><td>0.127243594535592</td><td>3</td><td>R</td><td>PA</td><td>Toomey</td><td>Toomey (R-PA)</td></tr>
<tr><td>53</td><td>0.0250101385807152</td><td>0.0895482161472582</td><td>3</td><td>R</td><td>TN</td><td>Alexander</td><td>Alexander (R-TN)</td></tr>
<tr><td>54</td><td>-0.0248599821563081</td><td>-0.095729706434113</td><td>1</td><td>D</td><td>RI</td><td>Whitehouse</td><td>Whitehouse (D-RI)</td></tr>
<tr><td>55</td><td>-0.0333199376653913</td><td>-0.0972202109926888</td><td>1</td><td>D</td><td>WA</td><td>Cantwell</td><td>Cantwell (D-WA)</td></tr>
<tr><td>56</td><td>-0.0237285974111554</td><td>0.1426337409077</td><td>3</td><td>R</td><td>SC</td><td>Scott</td><td>Scott (R-SC)</td></tr>
<tr><td>57</td><td>0.00208864306527005</td><td>0.0880785386131045</td><td>3</td><td>R</td><td>MS</td><td>Cochran</td><td>Cochran (R-MS)</td></tr>
<tr><td>58</td><td>0.00510452859342998</td><td>0.109059248449882</td><td>3</td><td>R</td><td>IN</td><td>Coats</td><td>Coats (R-IN)</td></tr>
<tr><td>59</td><td>-0.0325060738924746</td><td>0.148436542924344</td><td>3</td><td>R</td><td>TX</td><td>Cruz</td><td>Cruz (R-TX)</td></tr>
<tr><td>60</td><td>-0.0168944687463986</td><td>-0.100169858331491</td><td>1</td><td>D</td><td>MA</td><td>Warren</td><td>Warren (D-MA)</td></tr>
<tr><td>61</td><td>-0.00504985813984682</td><td>0.116103678690317</td><td>3</td><td>R</td><td>SD</td><td>Thune</td><td>Thune (R-SD)</td></tr>
<tr><td>62</td><td>0.00093559740162602</td><td>0.113313222911704</td><td>3</td><td>R</td><td>AL</td><td>Shelby</td><td>Shelby (R-AL)</td></tr>
<tr><td>63</td><td>-0.00465838024989644</td><td>0.134113692758071</td><td>3</td><td>R</td><td>OK</td><td>Coburn</td><td>Coburn (R-OK)</td></tr>
<tr><td>64</td><td>-0.00664117170127769</td><td>0.10622730554457</td><td>3</td><td>R</td><td>UT</td><td>Hatch</td><td>Hatch (R-UT)</td></tr>
<tr><td>65</td><td>-0.00500337050624833</td><td>0.110290478839911</td><td>3</td><td>R</td><td>OH</td><td>Portman</td><td>Portman (R-OH)</td></tr>
<tr><td>66</td><td>-0.0372190241620294</td><td>0.126847954536274</td><td>3</td><td>R</td><td>UT</td><td>Lee</td><td>Lee (R-UT)</td></tr>
<tr><td>67</td><td>-0.0131122681852286</td><td>0.136328117053898</td><td>3</td><td>R</td><td>WI</td><td>Johnson</td><td>Johnson (R-WI)</td></tr>
<tr><td>68</td><td>-0.0325452232363857</td><td>-0.0989242984488763</td><td>1</td><td>D</td><td>CT</td><td>Blumenthal</td><td>Blumenthal (D-CT)</td></tr>
<tr><td>69</td><td>-0.0325608835753324</td><td>-0.0965579874994683</td><td>1</td><td>D</td><td>MD</td><td>Cardin</td><td>Cardin (D-MD)</td></tr>
<tr><td>70</td><td>-0.0362197521229333</td><td>-0.0885084465604916</td><td>1</td><td>D</td><td>NV</td><td>Reid</td><td>Reid (D-NV)</td></tr>
<tr><td>71</td><td>-0.0377614697054327</td><td>-0.0537364230302328</td><td>1</td><td>D</td><td>MT</td><td>Baucus</td><td>Baucus (D-MT)</td></tr>
<tr><td>72</td><td>-0.0231248134323342</td><td>-0.0690827754890821</td><td>1</td><td>D</td><td>LA</td><td>Landrieu</td><td>Landrieu (D-LA)</td></tr>
<tr><td>73</td><td>-0.0360776026332512</td><td>-0.0966153524943709</td><td>1</td><td>D</td><td>RI</td><td>Reed</td><td>Reed (D-RI)</td></tr>
<tr><td>74</td><td>-0.0334062122015807</td><td>-0.0968346202863056</td><td>1</td><td>D</td><td>CT</td><td>Murphy</td><td>Murphy (D-CT)</td></tr>
<tr><td>75</td><td>-0.0386494891823663</td><td>-0.0924318691119419</td><td>1</td><td>D</td><td>NM</td><td>Udall</td><td>Udall (D-NM)</td></tr>
<tr><td>76</td><td>-0.034261765962939</td><td>-0.0971306029763209</td><td>1</td><td>D</td><td>NJ</td><td>Menendez</td><td>Menendez (D-NJ)</td></tr>
<tr><td>77</td><td>0.0044452992945155</td><td>0.0906954517520155</td><td>3</td><td>R</td><td>TN</td><td>Corker</td><td>Corker (R-TN)</td></tr>
<tr><td>78</td><td>-0.0352178910737286</td><td>-0.10132777843478</td><td>1</td><td>D</td><td>OH</td><td>Brown</td><td>Brown (D-OH)</td></tr>
<tr><td>79</td><td>-0.0338688838171066</td><td>-0.0905868378033902</td><td>1</td><td>D</td><td>CA</td><td>Feinstein</td><td>Feinstein (D-CA)</td></tr>
<tr><td>80</td><td>-0.0136465202405107</td><td>0.125521018575589</td><td>3</td><td>R</td><td>AL</td><td>Sessions</td><td>Sessions (R-AL)</td></tr>
<tr><td>81</td><td>-0.0198635645247844</td><td>-0.0592441352221849</td><td>1</td><td>D</td><td>ND</td><td>Heitkamp</td><td>Heitkamp (D-ND)</td></tr>
<tr><td>82</td><td>0.00851703548561369</td><td>0.11183895075283</td><td>3</td><td>R</td><td>LA</td><td>Vitter</td><td>Vitter (R-LA)</td></tr>
<tr><td>83</td><td>-0.019576243340423</td><td>-0.0481775344083724</td><td>1</td><td>D</td><td>IN</td><td>Donnelly</td><td>Donnelly (D-IN)</td></tr>
<tr><td>84</td><td>-0.00163774827120045</td><td>0.0936077455073306</td><td>3</td><td>R</td><td>GA</td><td>Isakson</td><td>Isakson (R-GA)</td></tr>
<tr><td>85</td><td>-0.011292726591166</td><td>-0.0625129443669425</td><td>1</td><td>D</td><td>MO</td><td>McCaskill</td><td>McCaskill (D-MO)</td></tr>
<tr><td>86</td><td>-0.0357000480753136</td><td>-0.0735127065323662</td><td>1</td><td>D</td><td>VA</td><td>Warner</td><td>Warner (D-VA)</td></tr>
<tr><td>87</td><td>-0.0292309014580987</td><td>-0.0828483216919547</td><td>1</td><td>D</td><td>IA</td><td>Harkin</td><td>Harkin (D-IA)</td></tr>
<tr><td>88</td><td>0.00966030494209233</td><td>0.0636741890603597</td><td>3</td><td>R</td><td>SC</td><td>Graham</td><td>Graham (R-SC)</td></tr>
<tr><td>89</td><td>-0.0222634405364073</td><td>0.112531903150154</td><td>3</td><td>R</td><td>FL</td><td>Rubio</td><td>Rubio (R-FL)</td></tr>
<tr><td>90</td><td>-0.0299927709252352</td><td>-0.0702086799731241</td><td>1</td><td>D</td><td>VA</td><td>Kaine</td><td>Kaine (D-VA)</td></tr>
<tr><td>91</td><td>-0.01976308643714</td><td>-0.107959054848897</td><td>1</td><td>D</td><td>CA</td><td>Boxer</td><td>Boxer (D-CA)</td></tr>
<tr><td>92</td><td>-0.0119432394768267</td><td>-0.106879637174371</td><td>1</td><td>D</td><td>WA</td><td>Murray</td><td>Murray (D-WA)</td></tr>
<tr><td>93</td><td>-0.0158697808112034</td><td>0.128969947769056</td><td>3</td><td>R</td><td>ID</td><td>Crapo</td><td>Crapo (R-ID)</td></tr>
<tr><td>94</td><td>-0.0306370175141373</td><td>-0.095789033771327</td><td>1</td><td>D</td><td>WV</td><td>Rockefeller</td><td>Rockefeller (D-WV)</td></tr>
<tr><td>95</td><td>0.0190442180517968</td><td>0.012248461541754</td><td>3</td><td>R</td><td>AK</td><td>Murkowski</td><td>Murkowski (R-AK)</td></tr>
<tr><td>96</td><td>-0.0448332633666639</td><td>-0.092421654963586</td><td>2</td><td>I</td><td>VT</td><td>Sanders</td><td>Sanders (I-VT)</td></tr>
<tr><td>97</td><td>-0.0242713912858675</td><td>0.126333955122549</td><td>3</td><td>R</td><td>KY</td><td>Paul</td><td>Paul (R-KY)</td></tr>
<tr><td>98</td><td>0.491565045440006</td><td>0.00808162827350793</td><td>3</td><td>R</td><td>NJ</td><td>Chiesa</td><td>Chiesa (R-NJ)</td></tr>
<tr><td>99</td><td>-0.0213028527791772</td><td>0.132160347234302</td><td>3</td><td>R</td><td>KY</td><td>McConnell</td><td>McConnell (R-KY)</td></tr>
<tr><td>100</td><td>-0.0415935326847892</td><td>-0.0973163163238865</td><td>1</td><td>D</td><td>MI</td><td>Levin</td><td>Levin (D-MI)</td></tr>
<tr><td>101</td><td>0.551432788755709</td><td>-0.071981264312893</td><td>1</td><td>D</td><td>MA</td><td>Kerry</td><td>Kerry (D-MA)</td></tr>
<tr><td>102</td><td>0.301028043276857</td><td>-0.0845041483494266</td><td>1</td><td>D</td><td>NJ</td><td>Lautenberg</td><td>Lautenberg (D-NJ)</td></tr>
<tr><td>103</td><td>0.0222177184793535</td><td>-0.163230940742793</td><td>1</td><td>D</td><td>MA</td><td>Cowan</td><td>Cowan (D-MA)</td></tr>
</tbody>
</table>
<br/><br/>
</div>

`x` and `y` are our two dimensional singular values that represent our vote matrices.  `label` is the party of the senator.  `label_code` is the numeric representation of the party (1 is Democrat, 3 is Republican, 2 is Independent).  ``state` is the state the senator is from.

Once we have these singular values, we can use them to plot our original chart:

![senate polarization](../images/senate-polarization/senate.png)

Interesting observations
----------------------------------------------------

* From the chart, we can see that there is significant polarization in the Senate.  In fact, there is a dividing line between the two parties.
* Both independents seem to vote solidly democrat.
* Massachussetts has some really out there senators (full disclosure: I live in MA right now)
* So does New Jersey
* Collins (R-ME), Murkowski (R-AK), Chiesa (R-NJ), Machin (D-WV), and Pryor (D-AR), are the closest things to centrists in the Senate.
* There are solid voting clusters around the party leaderships of both parties.
* The party line seems to come before all else, judging by how closely voting aligns by party.

There are other interesting things in this chart.  Feel free to let me know if you notice anything good.

But wait, there's more!
-----------------------------------------------------

Now that we have these vote matrices, we can do all manner of cool things.  One of the cool things we can do is calculate the [euclidean distance](http://en.wikipedia.org/wiki/Euclidean_distance) between the votes of each Senator and the average votes on all issues.  The greater the distance, the more "radical", or extreme in their views, a senator is.

Here are all the senators, this time sorted by their distances:

<div>
<table border="1" class="dataframe table display">
<thead>
<tr><th></th><th>x</th><th>y</th><th>label_code</th><th>label</th><th>state</th><th>name</th><th>full_name</th><th>distances</th></tr>
</thead>
<tbody>
<tr><td>101</td><td>0.551432788755709</td><td>-0.071981264312893</td><td>1</td><td>D</td><td>MA</td><td>Kerry</td><td>Kerry (D-MA)</td><td>0.564834814542764</td></tr>
<tr><td>24</td><td>0.547215825548056</td><td>-0.0593289149366795</td><td>1</td><td>D</td><td>MA</td><td>Markey</td><td>Markey (D-MA)</td><td>0.559309579320913</td></tr>
<tr><td>98</td><td>0.491565045440006</td><td>0.00808162827350793</td><td>3</td><td>R</td><td>NJ</td><td>Chiesa</td><td>Chiesa (R-NJ)</td><td>0.50402702343082</td></tr>
<tr><td>102</td><td>0.301028043276857</td><td>-0.0845041483494266</td><td>1</td><td>D</td><td>NJ</td><td>Lautenberg</td><td>Lautenberg (D-NJ)</td><td>0.339392958602243</td></tr>
<tr><td>103</td><td>0.0222177184793535</td><td>-0.163230940742793</td><td>1</td><td>D</td><td>MA</td><td>Cowan</td><td>Cowan (D-MA)</td><td>0.186545210134961</td></tr>
<tr><td>59</td><td>-0.0325060738924746</td><td>0.148436542924344</td><td>3</td><td>R</td><td>TX</td><td>Cruz</td><td>Cruz (R-TX)</td><td>0.165896480749798</td></tr>
<tr><td>56</td><td>-0.0237285974111554</td><td>0.1426337409077</td><td>3</td><td>R</td><td>SC</td><td>Scott</td><td>Scott (R-SC)</td><td>0.158640662947416</td></tr>
<tr><td>34</td><td>-0.0245751728057898</td><td>0.141367663303047</td><td>3</td><td>R</td><td>KS</td><td>Roberts</td><td>Roberts (R-KS)</td><td>0.157729205632881</td></tr>
<tr><td>5</td><td>-0.0077981548158297</td><td>0.142184554607829</td><td>3</td><td>R</td><td>OK</td><td>Inhofe</td><td>Inhofe (R-OK)</td><td>0.157161641390102</td></tr>
<tr><td>13</td><td>-0.0180558122137665</td><td>0.136687567805345</td><td>3</td><td>R</td><td>WY</td><td>Barrasso</td><td>Barrasso (R-WY)</td><td>0.152621988932664</td></tr>
<tr><td>67</td><td>-0.0131122681852286</td><td>0.136328117053898</td><td>3</td><td>R</td><td>WI</td><td>Johnson</td><td>Johnson (R-WI)</td><td>0.151926482983146</td></tr>
<tr><td>66</td><td>-0.0372190241620294</td><td>0.126847954536274</td><td>3</td><td>R</td><td>UT</td><td>Lee</td><td>Lee (R-UT)</td><td>0.151014401165793</td></tr>
<tr><td>63</td><td>-0.00465838024989644</td><td>0.134113692758071</td><td>3</td><td>R</td><td>OK</td><td>Coburn</td><td>Coburn (R-OK)</td><td>0.150563032650489</td></tr>
<tr><td>99</td><td>-0.0213028527791772</td><td>0.132160347234302</td><td>3</td><td>R</td><td>KY</td><td>McConnell</td><td>McConnell (R-KY)</td><td>0.149572657072359</td></tr>
<tr><td>28</td><td>-0.0115860482094747</td><td>0.131875057650696</td><td>3</td><td>R</td><td>WY</td><td>Enzi</td><td>Enzi (R-WY)</td><td>0.148273587508265</td></tr>
<tr><td>23</td><td>-0.019258803509291</td><td>0.13062638910029</td><td>3</td><td>R</td><td>IA</td><td>Grassley</td><td>Grassley (R-IA)</td><td>0.148018476577859</td></tr>
<tr><td>26</td><td>-0.00956413282205122</td><td>0.129548524717885</td><td>3</td><td>R</td><td>ID</td><td>Risch</td><td>Risch (R-ID)</td><td>0.146533324110168</td></tr>
<tr><td>93</td><td>-0.0158697808112034</td><td>0.128969947769056</td><td>3</td><td>R</td><td>ID</td><td>Crapo</td><td>Crapo (R-ID)</td><td>0.146312632504688</td></tr>
<tr><td>97</td><td>-0.0242713912858675</td><td>0.126333955122549</td><td>3</td><td>R</td><td>KY</td><td>Paul</td><td>Paul (R-KY)</td><td>0.146223353635669</td></tr>
<tr><td>18</td><td>-0.016413732654005</td><td>0.128746686935355</td><td>3</td><td>R</td><td>TX</td><td>Cornyn</td><td>Cornyn (R-TX)</td><td>0.146216404936958</td></tr>
<tr><td>52</td><td>-0.00825702591654079</td><td>0.127243594535592</td><td>3</td><td>R</td><td>PA</td><td>Toomey</td><td>Toomey (R-PA)</td><td>0.144926057670348</td></tr>
<tr><td>80</td><td>-0.0136465202405107</td><td>0.125521018575589</td><td>3</td><td>R</td><td>AL</td><td>Sessions</td><td>Sessions (R-AL)</td><td>0.143756581273559</td></tr>
<tr><td>11</td><td>-0.0156804216297059</td><td>0.117291940698239</td><td>3</td><td>R</td><td>NE</td><td>Fischer</td><td>Fischer (R-NE)</td><td>0.138960750355783</td></tr>
<tr><td>43</td><td>-0.00834005326900628</td><td>0.11718205053358</td><td>3</td><td>R</td><td>NV</td><td>Heller</td><td>Heller (R-NV)</td><td>0.138362287865482</td></tr>
<tr><td>82</td><td>0.00851703548561369</td><td>0.11183895075283</td><td>3</td><td>R</td><td>LA</td><td>Vitter</td><td>Vitter (R-LA)</td><td>0.138184156829855</td></tr>
<tr><td>61</td><td>-0.00504985813984682</td><td>0.116103678690317</td><td>3</td><td>R</td><td>SD</td><td>Thune</td><td>Thune (R-SD)</td><td>0.137854672693276</td></tr>
<tr><td>89</td><td>-0.0222634405364073</td><td>0.112531903150154</td><td>3</td><td>R</td><td>FL</td><td>Rubio</td><td>Rubio (R-FL)</td><td>0.137806098357527</td></tr>
<tr><td>62</td><td>0.00093559740162602</td><td>0.113313222911704</td><td>3</td><td>R</td><td>AL</td><td>Shelby</td><td>Shelby (R-AL)</td><td>0.137064565612541</td></tr>
<tr><td>35</td><td>-0.00345843619743554</td><td>0.113606389164264</td><td>3</td><td>R</td><td>NC</td><td>Burr</td><td>Burr (R-NC)</td><td>0.136557433557291</td></tr>
<tr><td>15</td><td>-0.00815268808751543</td><td>0.113170007558517</td><td>3</td><td>R</td><td>AR</td><td>Boozman</td><td>Boozman (R-AR)</td><td>0.136101853780071</td></tr>
<tr><td>58</td><td>0.00510452859342998</td><td>0.109059248449882</td><td>3</td><td>R</td><td>IN</td><td>Coats</td><td>Coats (R-IN)</td><td>0.135690894512148</td></tr>
<tr><td>22</td><td>0.00273613995205289</td><td>0.108642449568633</td><td>3</td><td>R</td><td>KS</td><td>Moran</td><td>Moran (R-KS)</td><td>0.134923581714883</td></tr>
<tr><td>65</td><td>-0.00500337050624833</td><td>0.110290478839911</td><td>3</td><td>R</td><td>OH</td><td>Portman</td><td>Portman (R-OH)</td><td>0.134686530230351</td></tr>
<tr><td>53</td><td>0.0250101385807152</td><td>0.0895482161472582</td><td>3</td><td>R</td><td>TN</td><td>Alexander</td><td>Alexander (R-TN)</td><td>0.134450487044903</td></tr>
<tr><td>64</td><td>-0.00664117170127769</td><td>0.10622730554457</td><td>3</td><td>R</td><td>UT</td><td>Hatch</td><td>Hatch (R-UT)</td><td>0.132740120998976</td></tr>
<tr><td>40</td><td>-0.0109758213217893</td><td>0.103451003006734</td><td>3</td><td>R</td><td>NH</td><td>Ayotte</td><td>Ayotte (R-NH)</td><td>0.131773301516089</td></tr>
<tr><td>3</td><td>-0.00545157078068947</td><td>0.10221895824691</td><td>3</td><td>R</td><td>GA</td><td>Chambliss</td><td>Chambliss (R-GA)</td><td>0.131093015114917</td></tr>
<tr><td>92</td><td>-0.0119432394768267</td><td>-0.106879637174371</td><td>1</td><td>D</td><td>WA</td><td>Murray</td><td>Murray (D-WA)</td><td>0.130153978588983</td></tr>
<tr><td>49</td><td>0.00966111542420832</td><td>0.0914499893026106</td><td>3</td><td>R</td><td>ND</td><td>Hoeven</td><td>Hoeven (R-ND)</td><td>0.129407219690427</td></tr>
<tr><td>91</td><td>-0.01976308643714</td><td>-0.107959054848897</td><td>1</td><td>D</td><td>CA</td><td>Boxer</td><td>Boxer (D-CA)</td><td>0.129264357312157</td></tr>
<tr><td>29</td><td>0.00411918634805181</td><td>0.09322702104917</td><td>3</td><td>R</td><td>MS</td><td>Wicker</td><td>Wicker (R-MS)</td><td>0.128684118769704</td></tr>
<tr><td>84</td><td>-0.00163774827120045</td><td>0.0936077455073306</td><td>3</td><td>R</td><td>GA</td><td>Isakson</td><td>Isakson (R-GA)</td><td>0.128132382150922</td></tr>
<tr><td>77</td><td>0.0044452992945155</td><td>0.0906954517520155</td><td>3</td><td>R</td><td>TN</td><td>Corker</td><td>Corker (R-TN)</td><td>0.127877085086648</td></tr>
<tr><td>21</td><td>0.00426679790452548</td><td>0.0906706864320044</td><td>3</td><td>R</td><td>NE</td><td>Johanns</td><td>Johanns (R-NE)</td><td>0.127836560969117</td></tr>
<tr><td>20</td><td>0.0129837663631103</td><td>0.081881278983249</td><td>3</td><td>R</td><td>AZ</td><td>Flake</td><td>Flake (R-AZ)</td><td>0.127583769293001</td></tr>
<tr><td>57</td><td>0.00208864306527005</td><td>0.0880785386131045</td><td>3</td><td>R</td><td>MS</td><td>Cochran</td><td>Cochran (R-MS)</td><td>0.126766732463057</td></tr>
<tr><td>50</td><td>0.0031092086697181</td><td>0.0851622652898145</td><td>3</td><td>R</td><td>MO</td><td>Blunt</td><td>Blunt (R-MO)</td><td>0.126156637213949</td></tr>
<tr><td>16</td><td>-0.0216403625336666</td><td>0.0719986192299611</td><td>3</td><td>R</td><td>IL</td><td>Kirk</td><td>Kirk (R-IL)</td><td>0.124078130072497</td></tr>
<tr><td>60</td><td>-0.0168944687463986</td><td>-0.100169858331491</td><td>1</td><td>D</td><td>MA</td><td>Warren</td><td>Warren (D-MA)</td><td>0.124001435882044</td></tr>
<tr><td>37</td><td>-0.0394437787124538</td><td>-0.10050126652756</td><td>1</td><td>D</td><td>HI</td><td>Hirono</td><td>Hirono (D-HI)</td><td>0.123889758913328</td></tr>
<tr><td>2</td><td>0.0139333391911509</td><td>0.0619623474516745</td><td>3</td><td>R</td><td>AZ</td><td>McCain</td><td>McCain (R-AZ)</td><td>0.123705285262252</td></tr>
<tr><td>78</td><td>-0.0352178910737286</td><td>-0.10132777843478</td><td>1</td><td>D</td><td>OH</td><td>Brown</td><td>Brown (D-OH)</td><td>0.123412758640486</td></tr>
<tr><td>88</td><td>0.00966030494209233</td><td>0.0636741890603597</td><td>3</td><td>R</td><td>SC</td><td>Graham</td><td>Graham (R-SC)</td><td>0.122980572370755</td></tr>
<tr><td>100</td><td>-0.0415935326847892</td><td>-0.0973163163238865</td><td>1</td><td>D</td><td>MI</td><td>Levin</td><td>Levin (D-MI)</td><td>0.122403925388497</td></tr>
<tr><td>68</td><td>-0.0325452232363857</td><td>-0.0989242984488763</td><td>1</td><td>D</td><td>CT</td><td>Blumenthal</td><td>Blumenthal (D-CT)</td><td>0.121121264263079</td></tr>
<tr><td>96</td><td>-0.0448332633666639</td><td>-0.092421654963586</td><td>2</td><td>I</td><td>VT</td><td>Sanders</td><td>Sanders (I-VT)</td><td>0.121104059523429</td></tr>
<tr><td>39</td><td>-0.0430280450634182</td><td>-0.0933459229654493</td><td>1</td><td>D</td><td>VT</td><td>Leahy</td><td>Leahy (D-VT)</td><td>0.120661628709076</td></tr>
<tr><td>25</td><td>-0.0353227186543595</td><td>-0.0976376341230047</td><td>1</td><td>D</td><td>HI</td><td>Schatz</td><td>Schatz (D-HI)</td><td>0.120516995483394</td></tr>
<tr><td>9</td><td>-0.0371022993314578</td><td>-0.0968419990947506</td><td>1</td><td>D</td><td>NY</td><td>Schumer</td><td>Schumer (D-NY)</td><td>0.120411986046654</td></tr>
<tr><td>41</td><td>-0.0404919136594251</td><td>-0.0943042109057099</td><td>1</td><td>D</td><td>MI</td><td>Stabenow</td><td>Stabenow (D-MI)</td><td>0.120043219408707</td></tr>
<tr><td>73</td><td>-0.0360776026332512</td><td>-0.0966153524943709</td><td>1</td><td>D</td><td>RI</td><td>Reed</td><td>Reed (D-RI)</td><td>0.119977187394233</td></tr>
<tr><td>76</td><td>-0.034261765962939</td><td>-0.0971306029763209</td><td>1</td><td>D</td><td>NJ</td><td>Menendez</td><td>Menendez (D-NJ)</td><td>0.119965878040237</td></tr>
<tr><td>55</td><td>-0.0333199376653913</td><td>-0.0972202109926888</td><td>1</td><td>D</td><td>WA</td><td>Cantwell</td><td>Cantwell (D-WA)</td><td>0.119905053274074</td></tr>
<tr><td>31</td><td>-0.0361826736711891</td><td>-0.0964110651487557</td><td>1</td><td>D</td><td>WI</td><td>Baldwin</td><td>Baldwin (D-WI)</td><td>0.119870079027214</td></tr>
<tr><td>10</td><td>-0.0331094361241657</td><td>-0.0970600008256449</td><td>1</td><td>D</td><td>NY</td><td>Gillibrand</td><td>Gillibrand (D-NY)</td><td>0.119775857565045</td></tr>
<tr><td>74</td><td>-0.0334062122015807</td><td>-0.0968346202863056</td><td>1</td><td>D</td><td>CT</td><td>Murphy</td><td>Murphy (D-CT)</td><td>0.119651535736152</td></tr>
<tr><td>69</td><td>-0.0325608835753324</td><td>-0.0965579874994683</td><td>1</td><td>D</td><td>MD</td><td>Cardin</td><td>Cardin (D-MD)</td><td>0.119412340011159</td></tr>
<tr><td>54</td><td>-0.0248599821563081</td><td>-0.095729706434113</td><td>1</td><td>D</td><td>RI</td><td>Whitehouse</td><td>Whitehouse (D-RI)</td><td>0.119390224208126</td></tr>
<tr><td>95</td><td>0.0190442180517968</td><td>0.012248461541754</td><td>3</td><td>R</td><td>AK</td><td>Murkowski</td><td>Murkowski (R-AK)</td><td>0.119338650035987</td></tr>
<tr><td>45</td><td>-0.0398873356531087</td><td>-0.0933244585933005</td><td>1</td><td>D</td><td>IL</td><td>Durbin</td><td>Durbin (D-IL)</td><td>0.119264416633329</td></tr>
<tr><td>6</td><td>-0.0426066858139772</td><td>-0.0904442823377511</td><td>1</td><td>D</td><td>SD</td><td>Johnson</td><td>Johnson (D-SD)</td><td>0.119082469790906</td></tr>
<tr><td>94</td><td>-0.0306370175141373</td><td>-0.095789033771327</td><td>1</td><td>D</td><td>WV</td><td>Rockefeller</td><td>Rockefeller (D-WV)</td><td>0.118904362580451</td></tr>
<tr><td>4</td><td>-0.0362627872805723</td><td>-0.0939015240228452</td><td>1</td><td>D</td><td>MN</td><td>Franken</td><td>Franken (D-MN)</td><td>0.118425828858068</td></tr>
<tr><td>75</td><td>-0.0386494891823663</td><td>-0.0924318691119419</td><td>1</td><td>D</td><td>NM</td><td>Udall</td><td>Udall (D-NM)</td><td>0.118366034195972</td></tr>
<tr><td>47</td><td>-0.0195976054340086</td><td>-0.091788450374095</td><td>1</td><td>D</td><td>CO</td><td>Udall</td><td>Udall (D-CO)</td><td>0.118236088253773</td></tr>
<tr><td>42</td><td>-0.0273071654738363</td><td>-0.0924267270931892</td><td>1</td><td>D</td><td>MD</td><td>Mikulski</td><td>Mikulski (D-MD)</td><td>0.117150656585951</td></tr>
<tr><td>79</td><td>-0.0338688838171066</td><td>-0.0905868378033902</td><td>1</td><td>D</td><td>CA</td><td>Feinstein</td><td>Feinstein (D-CA)</td><td>0.116358543323594</td></tr>
<tr><td>70</td><td>-0.0362197521229333</td><td>-0.0885084465604916</td><td>1</td><td>D</td><td>NV</td><td>Reid</td><td>Reid (D-NV)</td><td>0.115971985332404</td></tr>
<tr><td>46</td><td>-0.0381855188001876</td><td>-0.086229921349195</td><td>1</td><td>D</td><td>OR</td><td>Merkley</td><td>Merkley (D-OR)</td><td>0.115774234530289</td></tr>
<tr><td>1</td><td>-0.0348802242728007</td><td>-0.0885011150722473</td><td>1</td><td>D</td><td>DE</td><td>Coons</td><td>Coons (D-DE)</td><td>0.115670517369723</td></tr>
<tr><td>32</td><td>-0.0268215357509806</td><td>-0.0890432282928414</td><td>1</td><td>D</td><td>OR</td><td>Wyden</td><td>Wyden (D-OR)</td><td>0.115563613050844</td></tr>
<tr><td>27</td><td>-0.0229079628265486</td><td>-0.0869471509735395</td><td>1</td><td>D</td><td>PA</td><td>Casey</td><td>Casey (D-PA)</td><td>0.115286524384875</td></tr>
<tr><td>19</td><td>-0.0298919244925452</td><td>-0.0880029993263122</td><td>1</td><td>D</td><td>MN</td><td>Klobuchar</td><td>Klobuchar (D-MN)</td><td>0.114982973280414</td></tr>
<tr><td>14</td><td>-0.0364473257536752</td><td>-0.0839036582733608</td><td>1</td><td>D</td><td>NH</td><td>Shaheen</td><td>Shaheen (D-NH)</td><td>0.114595708701108</td></tr>
<tr><td>51</td><td>-0.00562041044072087</td><td>0.0103468267205128</td><td>3</td><td>R</td><td>ME</td><td>Collins</td><td>Collins (R-ME)</td><td>0.114302134456818</td></tr>
<tr><td>33</td><td>-0.0122248435323734</td><td>-0.0754120081322735</td><td>1</td><td>D</td><td>AK</td><td>Begich</td><td>Begich (D-AK)</td><td>0.114243839017192</td></tr>
<tr><td>17</td><td>-0.029568048844845</td><td>-0.0858533841278676</td><td>1</td><td>D</td><td>FL</td><td>Nelson</td><td>Nelson (D-FL)</td><td>0.114194289812714</td></tr>
<tr><td>8</td><td>-0.0356973327991686</td><td>-0.0826384224297392</td><td>1</td><td>D</td><td>DE</td><td>Carper</td><td>Carper (D-DE)</td><td>0.114101444562881</td></tr>
<tr><td>36</td><td>-0.0292497277663385</td><td>-0.085407101553328</td><td>1</td><td>D</td><td>NM</td><td>Heinrich</td><td>Heinrich (D-NM)</td><td>0.114048209132161</td></tr>
<tr><td>7</td><td>-0.044554280398656</td><td>-0.0545406205845917</td><td>1</td><td>D</td><td>MT</td><td>Tester</td><td>Tester (D-MT)</td><td>0.113815375991399</td></tr>
<tr><td>87</td><td>-0.0292309014580987</td><td>-0.0828483216919547</td><td>1</td><td>D</td><td>IA</td><td>Harkin</td><td>Harkin (D-IA)</td><td>0.113321234065552</td></tr>
<tr><td>12</td><td>-0.0289778208474004</td><td>-0.0824901409317521</td><td>1</td><td>D</td><td>CO</td><td>Bennet</td><td>Bennet (D-CO)</td><td>0.113231028586499</td></tr>
<tr><td>86</td><td>-0.0357000480753136</td><td>-0.0735127065323662</td><td>1</td><td>D</td><td>VA</td><td>Warner</td><td>Warner (D-VA)</td><td>0.112526922656803</td></tr>
<tr><td>85</td><td>-0.011292726591166</td><td>-0.0625129443669425</td><td>1</td><td>D</td><td>MO</td><td>McCaskill</td><td>McCaskill (D-MO)</td><td>0.112014211462848</td></tr>
<tr><td>71</td><td>-0.0377614697054327</td><td>-0.0537364230302328</td><td>1</td><td>D</td><td>MT</td><td>Baucus</td><td>Baucus (D-MT)</td><td>0.111755195704732</td></tr>
<tr><td>48</td><td>-0.00926246130655879</td><td>-0.0188892715011417</td><td>1</td><td>D</td><td>WV</td><td>Manchin</td><td>Manchin (D-WV)</td><td>0.111750853665797</td></tr>
<tr><td>90</td><td>-0.0299927709252352</td><td>-0.0702086799731241</td><td>1</td><td>D</td><td>VA</td><td>Kaine</td><td>Kaine (D-VA)</td><td>0.111203430282439</td></tr>
<tr><td>30</td><td>-0.026944901403195</td><td>-0.0707999020236366</td><td>2</td><td>I</td><td>ME</td><td>King</td><td>King (I-ME)</td><td>0.11110709047993</td></tr>
<tr><td>72</td><td>-0.0231248134323342</td><td>-0.0690827754890821</td><td>1</td><td>D</td><td>LA</td><td>Landrieu</td><td>Landrieu (D-LA)</td><td>0.111001469145908</td></tr>
<tr><td>81</td><td>-0.0198635645247844</td><td>-0.0592441352221849</td><td>1</td><td>D</td><td>ND</td><td>Heitkamp</td><td>Heitkamp (D-ND)</td><td>0.110305612650745</td></tr>
<tr><td>38</td><td>-0.0192640058583086</td><td>-0.0370242407531159</td><td>1</td><td>D</td><td>AR</td><td>Pryor</td><td>Pryor (D-AR)</td><td>0.110231120430787</td></tr>
<tr><td>83</td><td>-0.019576243340423</td><td>-0.0481775344083724</td><td>1</td><td>D</td><td>IN</td><td>Donnelly</td><td>Donnelly (D-IN)</td><td>0.109949132073788</td></tr>
<tr><td>44</td><td>-0.0228120494502621</td><td>-0.0501247061910197</td><td>1</td><td>D</td><td>NC</td><td>Hagan</td><td>Hagan (D-NC)</td><td>0.109873667752502</td></tr>
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
    </script><br/><br/>
</div>

We can also make a graphic of the most "extreme" senators given this distance:

![senate extremity](../images/senate-polarization/most_radical.png)

Note that the minority party is more likely to be extreme by this distance metric, because the typical view is titled towards the party with more votes.

Using historical data
-----------------------------------------------

We can also calculate how polarized the parties have been by calculating how "extreme" the average member in each party was at any given time.

![senate extremity](../images/senate-polarization/polarization.png)

We can see how polarization has changed over time, and the average distance of each member to the typical voting pattern has shifted.

Thoughts
-----------------------------------------------

This analysis was interesting to do, and I hope to do more in the future.  You can find all of my code [here](https://github.com/VikParuchuri/political-positions).

Some cautions:

* I would hesitate to make any sweeping generalizations from this that are not supported by the data.
* What you see is pretty much what you get.  All of this data is publicly available, and I highly encourage you to look at it if you are interested.

Ideas:

* It could be interesting to analyze voting patterns as compared to the text of bills.  (Does senator X always vote for bills with the phrase "increase defense spending" in them?)
* Voting patterns vs demographic shifts in the US.
* Linking voting patterns and the rise and fall of political parties.
* Predicting state senate votes.
* Doing similar analysis for the House.