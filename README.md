# Equipment_Failure_Detection

This was a part of TAMU Datathon held on October 19th and 20th, 2019 at Texas A&M University. This was a Data Science Challenge given by ConocoPhilips.

### Background

80% of producing oil wells in the United States are classified as stripper wells. Stripper wells produce low volumes at the well level, but at an aggregate level these wells are responsible for a significant percentage of domestic oil production.

As with all mechanical equipment, things break and when things break money is lost in the form of repairs and lost oil production. When costs go up cash goes down, but how can we predict when equipment will fail and use this information to drive down our costs?


### Problem Statement

A data set has been provided that has documented failure events that occurred on surface equipment and down-hole equipment. For each failure event, data has been collected from over 107 sensors that collect a variety of physical information both on the surface and below the ground.

Using this data, can we predict failures that occur both on the surface and below the ground? Using this information, how can we minimize costs associated with failures?

The goal of this challenge will be to predict surface and down-hole failures using the data set provided. This information can be used to send crews out to a well location to fix equipment on the surface or send a workover rig to the well to pull down-hole equipment and address the failure.

### Challenges faced

The data had a total of 172 features and there was class imbalance in the target variables.

### Creative solutions

To deal with high dimentionality we used Principal Component Analysis to reduce the dimensionality to 5 Principal Components and further use Kernel trick of Support Vector Machines to separate the 2 classes and get get high F1 score of 99%.
