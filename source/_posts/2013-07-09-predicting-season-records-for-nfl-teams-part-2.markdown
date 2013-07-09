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

*This is the second, technical, part of this series.  See [the first part](/blog/predicting-nfl-season-records-with-percept) for the overview.*

Introduction
-------------------

This post will introduce the technical details behind the nfl season record prediction that was introduced in [part one](/blog/predicting-nfl-season-records-with-percept).

After selecting the error metric and defining an acceptable baseline, which was setup in part one, the next step is to develop a plan of attack.  In order to create and develop this plan, we will use the [percept](http://www.github.com/equirio/percept) framework created by [Equirio](http://www.equirio.com).

We don't technically need to use percept for this, but it will make a few things easier.  Any of the code shown here can be taken and used independently if desired.  Everything below has been tested using Ubuntu 12.10 and a virtualenv.  A different configuration may not get the same results.

We will be using the [percept](http://www.github.com/equirio/percept) and [nfl_season](http://www.github.com/equirio/nfl_season) git repositories.  You can find documentation for percept [here](http://percept.readthedocs.org/en/latest/)

<!--more-->

Setup
------------------------------------

### Installing percept

First, we will need to install percept.  Percept is a modular machine learning framework.  It will allow us to plan and define a workflow that will get us from raw data to predictions.

Percept is under constant development, and the version on pypi might not be current, so we can install percept via github:

```
$ git clone git://github.com/equirio/percept.git
$ cd percept
$ xargs -a apt-packages.txt apt-get install
$ virtualenv /path/to/percept
$ source /path/to/percept/bin/activate
$ pip install -r pre_requirements.txt
$ pip install -r requirements.txt
$ python setup.py install
```

The virtualenv commands can be skipped if needed.

### Getting the data

We can get the data and code for what we want to do from the nfl_season repository.

```
$ git clone git://github.com/equirio/nfl_season.git
$ cd nfl_season
$ source /path/to/percept/bin/activate
```

The *data* folder in nfl_season has the data that we need.

### Quickstart

For the impatient, you can run everything yourself now by doing the following at the command line:

```
$ cd nfl_season
$ python manage.py run_flow /path/to/nfl_season/config/nfl_save.conf --settings=config.settings --pythonpath=`pwd`
$ python manage.py shell --settings=config.settings --pythonpath=`pwd`
```

And the following in the shell:

```
import pickle
flow = pickle.load(open('/path/to/nfl_season/stored_data/1_tasks'))
res = flow.tasks[3].results.value
error = flow.tasks[3].error.value
```

*res* will be the full results, and *error* will tell you the error value.

If you want to know more about what is happening, read on.

Getting the data into a usable form
------------------------------------

### Inputs

As we can see, the data is in several csv files that look like this:

```
Week,Day,Date,,Winner/tie,,Loser/tie,PtsW,PtsL,YdsW,TOW,YdsL,TOL
1,Wed,September 5,boxscore,Dallas Cowboys,@,New York Giants,24,17,433,1,269,1
1,Sun,September 9,boxscore,Philadelphia Eagles,@,Cleveland Browns,17,16,456,5,210,4
1,Sun,September 9,boxscore,New England Patriots,@,Tennessee Titans,34,13,390,0,284,2
1,Sun,September 9,boxscore,Denver Broncos,,Pittsburgh Steelers,31,19,334,1,284,1
1,Sun,September 9,boxscore,San Francisco 49ers,@,Green Bay Packers,30,22,377,0,324,1
1,Sun,September 9,boxscore,Arizona Cardinals,,Seattle Seahawks,20,16,253,2,254,2
```

Each csv file is data for a single season.  We will need to go from these to one file that contains summary data for a team's performance during a season.

The first step into doing this is what is called an *input* in percept.  The input (inputs.inputs.NFLInput) allows us to take in the multiple csv files and join them into a single one.

```
class NFLInput(BaseInput):
    """
    Extends baseinput to read nfl season data csv
    """
    input_format = NFLFormats.multicsv
    tester = CSVInputTester
    test_cases = [{'stream' : os.path.join(settings.PROJECT_PATH, "data")}]
    help_text = "Load multiple nfl season csv files."
    namespace = get_namespace(__module__)

    def read_input(self, directory, has_header=True):
        """
        directory is a path to a directory with multiple csv files
        """

        datafiles = [ f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory,f)) and f.endswith(".csv")]
        all_csv_data = []
        for infile in datafiles:
            ...
        csv_data = list(chain.from_iterable(all_csv_data))
        self.data = csv_data
```

I have omitted the internals of *read_input*, but you can see them in the source file if you wish.

Above, we see that a lot of things are happening.  Percept defines a BaseInput class that all inputs inherit from.  I will go through each of the class attributes and methods:

* input_format - the type of format that the input accepts and returns.  This is just a string, but we are holding it in the class NFLFormats for convenience.
* tester - this defines a class that will be used to test this input.  This allows us to very easily test.
* test_cases - the format for these is defined by the tester.  Each test case is fed into the tester, which uses it as arguments to the input class during testing.
* help_text - help text about this input class.
* namespace - The namespace for this module.  In this case, the namespace should be "nfl_season."
* read_input - a directory is passed to this function, which then reads all the csv files in the directory, and returns a list of their contents.

This may be a bit confusing, but several of these concepts will be explained as we go along.

### Formatters

After we define our input, which will take in our data and provide it in a consistent format, we will need a formatter.  The formatter will reformat our data from one format (in this case, csv) to another format (this could be any format, but we will be using pandas dataframes here).

[Pandas](http://pandas.pydata.org/) is a python data analysis library that defines a dataframe, which is similar to an R dataframe, a container that can hold data of varying types in each column.  Think of an array, but with several data types.

Our formatter, which is in *formatters.formatters.NFLFormatter*, will take the input and reformat it as needed.  Here, it will turn the csv input and turn it into a dataframe.

Understanding namespaces and testers
--------------------------------------

### Namespaces

Now that we have our data into a dataframe format, which is ready to analyze, let's pause and look into how namespaces work.

Try this command in the *nfl_season* directory:

```
python manage.py list_tasks --settings=config.settings --pythonpath=`pwd`
```

Command line flags:

* --settings - defines which settings file we should load.  Settings can change the behavior of a project.
* --pythonpath - tells manage.py what to append to sys.path for importing.

This will show us a list of the tasks that we can perform:

```
Name                                                Help
base.percept.fieldmodel
formatters.percept.baseformat                       Base class for reformatting input data.  Do not use directly.
formatters.percept.jsonformat                       Example class to convert from csv to dataframe.
inputs.percept.baseinput                            Base class for input.  Do not use directly.
inputs.percept.csvinput                             Example class to load in csv files.
...
inputs.inputs.nflinput                              Load multiple nfl season csv files.
formatters.nfl_season.nflformatter                  Example class to convert from csv to dataframe.
...
```

Each task is listed as category.namespace.name .  Each of these are class attributes that can be set.  For example, in our nflinput class, we set the namespace, but the category was inherited from BaseInput.

Namespaces allow us to easily register and find classes later.

### Testers

Now, try running:

```
python manage.py test --settings=config.settings --pythonpath=`pwd`
```

This will run all available tests in nfl_season.  Every class that has a defined *tester* and *test_cases* will be tested.

### Manage.py

If you have used [Django](https://www.djangoproject.com/) before, manage.py will look familiar.  It allows us to run some project-level tasks.  A listing of all available commands can be found by running:

```
python manage.py help --settings=config.settings --pythonpath=`pwd`
```

Cleaning the data
----------------------------

Now, we have our data in a dataframe roughly like this:

```
<class 'pandas.core.frame.DataFrame'>
Int64Index: 6811 entries, 0 to 7294
Data columns (total 14 columns):
Week          6811  non-null values
Home          6811  non-null values
Winner/tie    6811  non-null values
YdsW          6811  non-null values
TOW           6811  non-null values
PtsW          6811  non-null values
YdsL          6811  non-null values
Loser/tie     6811  non-null values
TOL           6811  non-null values
Year          6811  non-null values
Day           6811  non-null values
PtsL          6811  non-null values
DayNum        6811  non-null values
MonthNum      6811  non-null values
dtypes: object(14)
```

We need to clean it up to remove bad rows and make values numeric.

For example, some of the rows in the data frame repeat the header or are blank, so we remove them:

```
row_removal_values = ["", "Week", "Year"]
for r in row_removal_values:
    data = data[data.iloc[:,0]!=r]
```

We also map the string month value to a number:

```
month_map = {v: k for k,v in enumerate(calendar.month_name)}
data['MonthNum'] = np.asarray([s.split(" ")[0] for s in data.iloc[:,10]])
for k in month_map.keys():
    data['MonthNum'][data['MonthNum']==k] = month_map[k]
```

Look at *tasks.tasks.CleanupNFLCSV* for a full listing of what is done.

Our cleaned data:

<div>
<table border="1" class="dataframe table display">  <thead>    <tr style="text-align: right;">      <th></th>      <th>Week</th>      <th>Home</th>      <th>Winner/tie</th>      <th>YdsW</th>      <th>TOW</th>      <th>PtsW</th>      <th>YdsL</th>      <th>Loser/tie</th>      <th>TOL</th>      <th>Year</th>      <th>Day</th>      <th>PtsL</th>      <th>DayNum</th>      <th>MonthNum</th>    </tr>  </thead>  <tbody>    <tr>      <th>0</th>      <td> 1</td>      <td> 0</td>      <td>   Indianapolis Colts</td>      <td> 452</td>      <td> 1</td>      <td> 41</td>      <td> 293</td>      <td>   New Orleans Saints</td>      <td> 3</td>      <td> 2007</td>      <td> 3</td>      <td> 10</td>      <td> 6</td>      <td> 9</td>    </tr>    <tr>      <th>1</th>      <td> 1</td>      <td> 0</td>      <td>     Seattle Seahawks</td>      <td> 343</td>      <td> 1</td>      <td> 20</td>      <td> 284</td>      <td> Tampa Bay Buccaneers</td>      <td> 2</td>      <td> 2007</td>      <td> 6</td>      <td>  6</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>2</th>      <td> 1</td>      <td> 1</td>      <td>  Pittsburgh Steelers</td>      <td> 365</td>      <td> 1</td>      <td> 34</td>      <td> 221</td>      <td>     Cleveland Browns</td>      <td> 5</td>      <td> 2007</td>      <td> 6</td>      <td>  7</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>3</th>      <td> 1</td>      <td> 0</td>      <td>    Green Bay Packers</td>      <td> 215</td>      <td> 2</td>      <td> 16</td>      <td> 283</td>      <td>  Philadelphia Eagles</td>      <td> 3</td>      <td> 2007</td>      <td> 6</td>      <td> 13</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>4</th>      <td> 1</td>      <td> 1</td>      <td>     Tennessee Titans</td>      <td> 350</td>      <td> 2</td>      <td> 13</td>      <td> 272</td>      <td> Jacksonville Jaguars</td>      <td> 1</td>      <td> 2007</td>      <td> 6</td>      <td> 10</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>5</th>      <td> 1</td>      <td> 0</td>      <td>       Dallas Cowboys</td>      <td> 478</td>      <td> 2</td>      <td> 45</td>      <td> 438</td>      <td>      New York Giants</td>      <td> 1</td>      <td> 2007</td>      <td> 6</td>      <td> 35</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>6</th>      <td> 1</td>      <td> 1</td>      <td> New England Patriots</td>      <td> 431</td>      <td> 0</td>      <td> 38</td>      <td> 227</td>      <td>        New York Jets</td>      <td> 0</td>      <td> 2007</td>      <td> 6</td>      <td> 14</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>7</th>      <td> 1</td>      <td> 0</td>      <td>    Minnesota Vikings</td>      <td> 302</td>      <td> 1</td>      <td> 24</td>      <td> 265</td>      <td>      Atlanta Falcons</td>      <td> 2</td>      <td> 2007</td>      <td> 6</td>      <td>  3</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>8</th>      <td> 1</td>      <td> 0</td>      <td>  Washington Redskins</td>      <td> 400</td>      <td> 2</td>      <td> 16</td>      <td> 273</td>      <td>       Miami Dolphins</td>      <td> 1</td>      <td> 2007</td>      <td> 6</td>      <td> 13</td>      <td> 9</td>      <td> 9</td>    </tr>    <tr>      <th>9</th>      <td> 1</td>      <td> 1</td>      <td>    Carolina Panthers</td>      <td> 385</td>      <td> 2</td>      <td> 27</td>      <td> 238</td>      <td>       St. Louis Rams</td>      <td> 2</td>      <td> 2007</td>      <td> 6</td>      <td> 13</td>      <td> 9</td>      <td> 9</td>    </tr>  </tbody></table>
</div><br/><br/>

CleanupNFLCSV inherits from Task, and is a task, distinct from inputs and formatters.


Tasks
-------------------------------------

Tasks are everything that comes after initial input of the data.  Tasks can be preprocessors, algorithms, or anything in between.

Let's look at the CleanupNFLCSV task:

```
class CleanupNFLCSV(Task):
    tester = CleanupNFLCSVTester
    test_cases = [{'stream' : os.path.join(settings.PROJECT_PATH, "data"), 'dataformat' : NFLFormats.multicsv}]
    data = Complex()

    data_format = NFLFormats.dataframe

    category = RegistryCategories.preprocessors
    namespace = get_namespace(__module__)

    help_text = "Convert from direct nfl data to features."

    def train(self, data, target, **kwargs):
        """
        Used in the training phase.  Override.
        """
        self.data = self.predict(data)

    def predict(self, data, **kwargs):
        """
        Used in the predict phase, after training.  Override
        """
        ...
        return data
```

This task has a tester, and defines a category, namespace, and help_text.  We have some new things, though:

* data - every task can define fields, which are persisted in a manner according to the project settings.  Fields can be persisted in memory, in the local filesystem, in a remote filesystem, etc.  Field naming is arbitrary.  Complex() is one kind of field, which uses pickle to serialize/unserialize.  Other fields include Dict, Float, and List, which use json to serialize.  We can create as many fields as we want and name them whatever we want.
* data_format - This specifies the type of data format that this class accepts.  The format is automatically generated and fed in.
* train - this is used to "train" the task.  This is called if the task is being instantiated on data with known outcomes.
* predict - this is called after training, on data with unknown outcomes.

If you specify an *args* class attribute (dictionary), then those arguments will be passed into the task train and predict methods.

Tasks are run inside of workflows, which we will discuss later on.

Converting per-game features to per-season
-------------------------------------

After cleanup, we have very basic box scores for each game in a season.  We want to generate team statistics for the whole season, which we can then use to predict the following season.

Look at *tasks.tasks.GenerateSeasonFeatures* for the code for this.

We will generate a lot of features, some of which I will describe here:

* total_wins - simple, the number of wins for a team in a season.
* pts_per_yard - number of points gained per yard gained.
* home_pts_opp_stat - points scored by the opponent when the team was at home
* home_yds_stat_last_3 - yards gained by the team in the last three games of the season.

Now, we have some per-season features for the team in isolation.  To take the next step, we will want to do two things:

* Get statistics that span multiple teams in a single season (ie strength of schedule)
* Get statistics that span multiple seasons for a single team (ie points scored over the last 3 seasons)

Our per-season data (only first 25 features shown for brevity):

<div>
<table border="1" class="dataframe table display">  <thead>    <tr style="text-align: right;">      <th></th>      <th>atlanta_falcons</th>      <th>away_eff_ratio</th>      <th>away_opp_pts_per_yard</th>      <th>away_pts_last_10_opp_stat</th>      <th>away_pts_last_10_ratio</th>      <th>away_pts_last_10_spread</th>      <th>away_pts_last_10_stat</th>      <th>away_pts_last_3_opp_stat</th>      <th>away_pts_last_3_ratio</th>      <th>away_pts_last_3_spread</th>      <th>away_pts_last_3_stat</th>      <th>away_pts_last_5_opp_stat</th>      <th>away_pts_last_5_ratio</th>      <th>away_pts_last_5_spread</th>      <th>away_pts_last_5_stat</th>      <th>away_pts_opp_stat</th>      <th>away_pts_per_yard</th>      <th>away_pts_ratio</th>      <th>away_pts_spread</th>      <th>away_pts_stat</th>      <th>away_yds_last_10_opp_stat</th>      <th>away_yds_last_10_ratio</th>      <th>away_yds_last_10_spread</th>      <th>away_yds_last_10_stat</th>    </tr>  </thead>  <tbody>    <tr>      <th>0</th>      <td> 2</td>      <td>  0.96</td>      <td>  0.06</td>      <td> 20.38</td>      <td>  1.22</td>      <td>  3.62</td>      <td> 16.75</td>      <td> 22.67</td>      <td>  1.55</td>      <td>  8.00</td>      <td> 14.67</td>      <td> 20.60</td>      <td>  1.24</td>      <td>  4.00</td>      <td> 16.60</td>      <td> 20.38</td>      <td>  0.06</td>      <td>  1.22</td>      <td>  3.62</td>      <td> 16.75</td>      <td>334.38</td>      <td>  1.27</td>      <td> 70.38</td>      <td>264.00</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>  0.95</td>      <td>  0.06</td>      <td> 23.88</td>      <td>  1.28</td>      <td>  5.25</td>      <td> 18.62</td>      <td> 24.67</td>      <td>  0.86</td>      <td> -4.00</td>      <td> 28.67</td>      <td> 22.80</td>      <td>  0.95</td>      <td> -1.20</td>      <td> 24.00</td>      <td> 23.88</td>      <td>  0.07</td>      <td>  1.28</td>      <td>  5.25</td>      <td> 18.62</td>      <td>373.12</td>      <td>  1.34</td>      <td> 95.25</td>      <td>277.88</td>    </tr>    <tr>      <th>0</th>      <td> 1</td>      <td>  0.64</td>      <td>  0.05</td>      <td> 17.11</td>      <td>  0.67</td>      <td> -8.33</td>      <td> 25.44</td>      <td> 23.00</td>      <td>  0.96</td>      <td> -1.00</td>      <td> 24.00</td>      <td> 23.60</td>      <td>  0.89</td>      <td> -2.80</td>      <td> 26.40</td>      <td> 17.11</td>      <td>  0.08</td>      <td>  0.67</td>      <td> -8.33</td>      <td> 25.44</td>      <td>319.00</td>      <td>  1.05</td>      <td> 16.56</td>      <td>302.44</td>    </tr>    <tr>      <th>0</th>      <td> 2</td>      <td>  1.32</td>      <td>  0.08</td>      <td> 32.00</td>      <td>  2.10</td>      <td> 16.75</td>      <td> 15.25</td>      <td> 38.00</td>      <td>  2.59</td>      <td> 23.33</td>      <td> 14.67</td>      <td> 34.40</td>      <td>  2.42</td>      <td> 20.20</td>      <td> 14.20</td>      <td> 32.00</td>      <td>  0.06</td>      <td>  2.10</td>      <td> 16.75</td>      <td> 15.25</td>      <td>392.25</td>      <td>  1.60</td>      <td>146.38</td>      <td>245.88</td>    </tr>    <tr>      <th>0</th>      <td> 1</td>      <td>  1.06</td>      <td>  0.06</td>      <td> 21.75</td>      <td>  1.35</td>      <td>  5.62</td>      <td> 16.12</td>      <td> 24.00</td>      <td>  0.95</td>      <td> -1.33</td>      <td> 25.33</td>      <td> 24.00</td>      <td>  1.35</td>      <td>  6.20</td>      <td> 17.80</td>      <td> 21.75</td>      <td>  0.06</td>      <td>  1.35</td>      <td>  5.62</td>      <td> 16.12</td>      <td>344.00</td>      <td>  1.27</td>      <td> 73.75</td>      <td>270.25</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>  0.99</td>      <td>  0.06</td>      <td> 18.00</td>      <td>  0.93</td>      <td> -1.38</td>      <td> 19.38</td>      <td> 13.33</td>      <td>  1.00</td>      <td>  0.00</td>      <td> 13.33</td>      <td> 15.80</td>      <td>  1.23</td>      <td>  3.00</td>      <td> 12.80</td>      <td> 18.00</td>      <td>  0.06</td>      <td>  0.93</td>      <td> -1.38</td>      <td> 19.38</td>      <td>316.25</td>      <td>  0.94</td>      <td>-21.00</td>      <td>337.25</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>  0.68</td>      <td>  0.06</td>      <td> 20.12</td>      <td>  0.82</td>      <td> -4.50</td>      <td> 24.62</td>      <td> 15.67</td>      <td>  0.68</td>      <td> -7.33</td>      <td> 23.00</td>      <td> 15.20</td>      <td>  0.66</td>      <td> -8.00</td>      <td> 23.20</td>      <td> 20.12</td>      <td>  0.09</td>      <td>  0.82</td>      <td> -4.50</td>      <td> 24.62</td>      <td>342.00</td>      <td>  1.20</td>      <td> 57.00</td>      <td>285.00</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>  1.10</td>      <td>  0.07</td>      <td> 23.12</td>      <td>  0.93</td>      <td> -1.62</td>      <td> 24.75</td>      <td> 24.33</td>      <td>  0.84</td>      <td> -4.67</td>      <td> 29.00</td>      <td> 24.00</td>      <td>  1.00</td>      <td>  0.00</td>      <td> 24.00</td>      <td> 23.12</td>      <td>  0.06</td>      <td>  0.93</td>      <td> -1.62</td>      <td> 24.75</td>      <td>342.25</td>      <td>  0.85</td>      <td>-62.00</td>      <td>404.25</td>    </tr>    <tr>      <th>0</th>      <td> 0</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>      <td>   nan</td>    </tr>  </tbody></table>
</div><br/><br/>

Getting additional features
-----------------------------------

Now that we have our basic feature set, we can add a bit of complexity.

Look at *tasks.tasks.GenerateSOSFeatures* for a full listing of these.

We will first generate strength of schedule statistics across the league and add those in to the per-game features.

We will also calculate all of our features over the past three seasons:

```
last_3 = data.loc[(data['team']==team) & (data['year']<year) & (data['year']>year-4),:]
if last_3.shape[0]>0:
    last_3_row = pd.DataFrame(list(last_3.mean(axis=0))).T
else:
    last_3_row = pd.DataFrame([0 for l in xrange(0,data.shape[1])]).T
```

Checking our error and making predictions
------------------------------------

Now, we have our full set of features, which looks like this:

```
<class 'pandas.core.frame.DataFrame'>
Int64Index: 1026 entries, 0 to 0
Columns: 381 entries, arizona_cardinals to opp_opp_total_wins
dtypes: float64(328), int64(43), object(10)
```

We have mostly float and int columns, along with a few "object" columns, which are strings.  We will need to remove these columns later on, as most machine learning algorithms do not take strings as input.

### Algorithm

We will be using a random forest algorithm with importances computed.  See *tasks.tasks.RandomForestTrain* .

We will try to calculate error with the random forest and cross validation, via the *tasks.tasks.CrossValidate* class.  In order to do this, we will setup a workflow.

Workflows
-------------------------------

Workflows plug everything that we have talked about together.  A workflow will take an input file, format it, and then take it through several tasks.

Every workflow has a configuration file.

Let's look at one:

```
[meta]
#The workflow can save the results at the end.  If so, then it will use this in the name.
run_id = 1
#Do we want to load a saved workflow?
load_previous_flow = False
#Do we want to save this workflow?
save_flow = True
#Whether or not we want to train and predict, or just train.
predict = False

[inputs]
#This is passed into the input class that has the appropriate format.  We defined NFLInput to take the format multicsv.
# The workflow will pass in the data directory to its read_input method.
file = ../data/
#The format the file argument above is in.
format = multicsv

[targets]
#We can optionally define a target along with the data if we are predicting for a known quantity.
file = ../data/
#The format that the target is in.
format = multicsv

[tasks]
# list defines, in sequence, the tasks that will process the data.
# So, in this case, we will load the data, format it, and then pass it into the train method of the cleanupnflcsv preprocessor.
# The cleanup nflcsv preprocessor will process the data, and store it as a self attribute (field).
# This will then be picked up by the workflow, and passed into generateseasonfeatures, and so on down the chain.
list = preprocessors.nfl_season.cleanupnflcsv,preprocessors.nfl_season.generateseasonfeatures,preprocessors.nfl_season.generatesosfeatures,preprocessors.nfl_season.sequentialvalidate


[predict]
#Optional argument, file in which data for predictions is
#Data for predictions will be passed through the same tasks as the inputs, but will be passed to the predict methods.
file = ../data/csv/1/data.csv
format = csv
```

This workflow is at config/nfl_save.conf.

## Running a workflow

We can run it by running:

```
python manage.py run_flow --settings=config.settings --pythonpath=`pwd`
```

Once the workflow is run, it will store its results in the stored_data directory (or another directory if we change it in the settings).

Validation
----------------------------

We could do cross validation, but we will instead do sequential validation.

Cross validation is tricky in this case, because we are working with what is essentially time series data.  We have incorporated data from multiple seasons into one.  The 2008 season would have information from the 2005-2007 seasons, because it has features corresponding to prior seasons.  This would nullify cross validation results, as it is possible that a model could be trained on 2008 data and used to predict 2005.

Sequential validation is my made-up term referring to the process of looping through year by year (after a minimum number of years), and predicting that year given data from previous years.  So, since we have data from 1970-2012, we will loop through each of those years, and predict the year given the previous years (with a minimum of 10, so we actually start at 1980).

We can do sequential validation using *tasks.tasks.SequentialValidate*, and it will in fact be our final task in our workflow.

So, now we can run validation with this at the command line(may take ~15 minutes):

```
$ cd nfl_seasons
$ python manage.py run_flow /path/to/nfl_season/config/nfl_save.conf --settings=config.settings --pythonpath=`pwd`
```

After it is finished running, we can run a shell using:

```
$ python manage.py shell --settings=config.settings --pythonpath=`pwd`
```

In the shell, we can get the results and error from sequential validation:

```
import pickle
flow = pickle.load(open('/path/to/nfl_season/stored_data/1_tasks'))
res = flow.tasks[3].results.value
error = flow.tasks[3].error.value
```

The workflow will automatically save the results using *pickle.dump* .  We can see the fields of the SequentialValidate class below:

```
data = Complex()
results = Complex()
error = Float()
importances = Complex()
importance = Complex()
column_names = List()
```

All of the tasks in a workflow are available at `workflow.tasks` .  In each task, the fields are available by doing `workflow.tasks[task_number].fieldname.`

Trying out importance will give us the random forest importances of each feature.

Potential Improvements
--------------------------

This algorithm does generate improvement over the baseline, but it could be better:

* Add in better data, such as number of sacks per season.
* Incorporate salary data, such as highest paid player on a team.
* Add in information on weather conditions faced during the season.
* Change the "look-back" period to more than 3 years.  Try incorporating multiple look back periods.
* Use feature importance to remove uninformative or overvalued features.
* Try ensembling, or a different algorithm.
* Add in metadata about the team, such as coaching, ownership, attendance, etc.
* Link historical teams with current teams (matching now is done on exact name, but that would lose data when a team relocated).

I am sure that there are also numerous other improvements that I have not thought of.

Conclusion
-------------------------

This hopefully showed that it is possible to predict the NFL better than the baseline expectation, even with minimal data.  More breadth of data would improve this method considerably.

It also hopefully served as an introduction to the percept platform, which has the potential to make machine learning easier to test, deploy, and modularize.

Please feel free to contact me at vik dot paruchuri at gmail with any questions or concerns.


<div>
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
</script>
</div>






