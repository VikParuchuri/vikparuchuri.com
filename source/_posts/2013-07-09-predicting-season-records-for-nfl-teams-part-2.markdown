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

First, we will need to install percept.  Percept is a modular machine learning framework.  It will allow us to plan and define a workflow that will get us from raw data to predictions.

We can install percept via:

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

Our formatter, which is in *formatters.formatters.NFLFormatter*, will take the input and reformat it as needed.





