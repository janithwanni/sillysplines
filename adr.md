# Architecture Decision Record

We have several options in terms of delivering the final dataset. 

We can give the dataset as 

1. An array of boundary points in the domain of -10, 10
2. A table of x,y coordinates  

In both instances a JSON file is possible or a CSV file is possible. 

We shall opt to using a JSON file of the array to make it easier for us in Javascript

The way we deliver this dataset is currently through a button, we can also set the user to ask whether to show the button and by default the input value is exposed through Shiny albeit as of writing this the reactive value is not named appropriately.
