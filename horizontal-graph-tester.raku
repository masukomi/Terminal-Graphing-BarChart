#!/usr/bin/env raku

use lib 'lib';
use Terminal::Graphing::BarChart::Horizontal;


say "X and Y axis\n";
my $x_and_y_axis_graph = Terminal::Graphing::BarChart::Horizontal.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    bar_length => 10,
    x_axis_labels => <a b c d e f g h i j>,
    y_axis_labels => <0 1 2 3 4 5 6 7 8 9 10>
);

$x_and_y_axis_graph.print();

say "\n\nwide bars, X and Y axis\n";
my $wide_x_and_y_axis_graph = Terminal::Graphing::BarChart::Horizontal.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    bar_length => 20,
    x_axis_labels => <a b c d e f g h i j>,
    y_axis_labels => <alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo>
);

$wide_x_and_y_axis_graph.print();




say "\n\nJust Y axis\n";
my $y_axis_graph = Terminal::Graphing::BarChart::Horizontal.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    bar_length => 10,
    y_axis_labels => <0 1 2 3 4 5 6 7 8 9 10 11>,
);
$y_axis_graph.print();


say "\n\nWide Y axis labels\n";
$x_and_y_axis_graph = Terminal::Graphing::BarChart::Horizontal.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    bar_length => 10,
    x_axis_labels => <a b c d e f g h i j >,
    y_axis_labels => <alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo>,
);
$x_and_y_axis_graph.print();

say "\n\ntoo few Y axis labels\n";
$x_and_y_axis_graph = Terminal::Graphing::BarChart::Horizontal.new(
    data => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    bar_length => 10,
    x_axis_labels => <a b c d e f g h i j>,
    y_axis_labels => <alpha bravo charlie delta echo foxtrot golf hotel >,
);
$x_and_y_axis_graph.print();
