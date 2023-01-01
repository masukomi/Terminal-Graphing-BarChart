# CLI::Graphing::BarChart

CLI::Graphing::BarChart is a simple library to let you produce bar graphs on the command line.
It takes special care to give you good looking output.

![example graph](../readme_images/images/x_and_y_axis.png)

Currently limited to vertical bar charts. See the end of this document for future plans & contribution guidelines. 


SYNOPSIS
========
Note that the 0 x 0 point of this graph is the bottom left corner.
Data and labels start from there and move outwards.

Folks using Arabic & other Right-to-Left are encouraged to make a PR
to support reversed graphs.

## Required Attributes
When creating a graph there are two required keys. `graph_height` and `data`.

`graph_height` is how tall you wish the core graph to be in lines. 
This does not include the additional lines for the x axis or its dividing line.

`data` is an array of numbers. Each is expected to be a percentage from 0 to 100. 
100 create a vertical bar `graph_height` lines tall. 0 will create an empty bar.

Note, there _will_ be rounding issues if your `graph_height` is anything other than 
an even multiple of 100. This is ok. 

Just to set expectations, if for example, you specify a `graph_height`
of 10 that means there are only 10 vertical elements to each bar. If 
one of your data points is 7 you'll end up with an empty bar because that's 
less than the number needed to activate the 1st element (10). 

## Optional Attributes

`x_axis_labels` This is an array of labels that must be equal in length 
to the number of data points. If you want some of your bars to be unlabeled
then specify a space for that "label". 


`y_axis_labels` This is an array of labels that must be equal in length
to the `graph_height` (one label per row). Again, if you want some of
the points to be unlabeled, you should use a space character.

Note that the 0 x 0 point of this graph is the bottom left. So your list 
of `y_axis_labels` will go from bottom up. This corresponds to how the
`data` and `x_axis_labels` go from left to right.

`space_between_columns` This is a `Bool` which defaults to `True`. If you 
set it to `False` the system will _not_ introduce a space between each column. 
This works fine, and may be a good choice if you have a large number of data points,
but for short graphs it's almost always worse looking.

### Advice
From a purely visual perspective it is not recommended that you use 
full words for your `x_axis_labels`. In order to not introduce a false sense
of time compression or similar meaning, every bar gets spread out by the 
length of the longest label.

`y_axis_labels` should be fine regardless of length. They are right-aligned, and 
just shove the graph farther to the right.

I would not recommend generating a graph that's more than 10 characters high. 

See `tester.raku` for examples. 

## Legend

This library does not support generating a legend for your graph.
My advice is to use single letter `x_axis_labels` and then use 
[Prettier::Table](https://github.com/masukomi/Prettier-Table/)
to generate a legend that explains your x axis. 

```raku
use CLI::Graphing::BarChart::Vertical;

my $x_and_y_axis_graph = CLI::Graphing::BarChart::Vertical.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    graph_height => 10,
    x_axis_labels => <a b c d e f g h i j k>,
    y_axis_labels => <0 1 2 3 4 5 6 7 8 9>
);

# to get the string version of the graph
$x_and_y_axis_graph.generate();

# to print the graph to Standard Out
$x_and_y_axis_graph.print();
```

# Future + Contributing

## Future Plans
This actually starts out by generating a horizontal graph and then rotates it, and adds the X axis and divider lines (see inline comments). 

The plan is to add `CLI::Graphing::BarChart::Horizontal` to this library, by extracting the initial bit of `Vertical` into a common module and then building `Horizontal` around that. 

This will happen as soon as I need it, or _you_ need it enough to make a Pull Request.

## Contributing
Please do. All I ask is that you include unit tests that cover whatever changes or additions you make, and that you're fine with your contributions being distributed under the AGPL.

What kind of contributions? New Features, refactored code, more tests, etc.

For best results, please ping me on mastodon (see below) to make sure I see your PR right away.

AUTHOR
======

web: [masukomi](https://masukomi.org)  
mastodon: [@masukomi@connectified.com](https://connectified.com/@masukomi)

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Kay Rhodes (a.k.a. masukomi)

This library is free software; you can redistribute it and/or modify it under the AGPL 3.0 or later. See LICENSE.md for details.
