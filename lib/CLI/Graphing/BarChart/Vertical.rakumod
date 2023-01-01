class CLI::Graphing::BarChart::Vertical {
	use Listicles;

	has $.data;
	has $.graph_height;
	has $.y_axis_labels = [];
	has $.x_axis_labels = [];
	has $.bar_column_character = '█';
	has $.x_axis_divider_character = '─';
	has $.space_between_columns = True;


	#| Prints the graph to standard out.
	method print() {
		say self.generate();
	}

	#| Generates a string representation of the graph.
	method generate() returns Str {
		unless $!graph_height {
			die("You must specify a graph_height (number of lines for the core graph).");
		}
		if $!x_axis_labels.elems > 0 and $!x_axis_labels.elems != $!data.elems {
			die("There must be 1 x axis label for each data element.");
		} elsif $!x_axis_labels.elems > 0 {
			$!x_axis_labels = $!x_axis_labels.map({.Str}).Array;
		}
		if $!y_axis_labels.elems > 0 and $!y_axis_labels.elems != $!graph_height {
			die("There must be 1 y axis label for each row of the graph.");
		} elsif $!y_axis_labels.elems > 0 {
			$!y_axis_labels = $!y_axis_labels.map({.Str}).Array;
		}

		# data is a list of numbers
		#   we're going to assume numbers are percentages
		# graph_height is the max height of the table
		#   graph_height = 100%
		#   column height is $graph_height * ($datum / 100)
		#
		# BUT we're actually going to bulid the table horizontally
		# then rotate it left 90°
		# 1st datum = first row.
		#

		my $rows = self!generate-sideways-graph($!data,
													   $!x_axis_labels,
													   $!graph_height,
													   $!bar_column_character);


		# now we've got a bunch of horizontal bars
		# [
		#  [████    ]
		#  [███     ]
		#  [███████ ]
		# ]
		#
		# in order to rotate the matrix by -90° we need to reverse each row
		# and then transpose the result (or vice-versa)
		# [
		#  [   ]
		#  [  █]
		#  [  █]
		#  [  █]
		#  [█ █]
		#  [███]
		#  [███]
		#  [███]
		# ]
		my @rotated = [Z] $rows.map({.reverse.Array});


		# reversing the labels because 0x0 on the grid is bottom left
		# but we need 0 to be the top one not the bottom
		my @reversed_y_labels = $!y_axis_labels.reverse;

		# Going to need these in a moment.
		my $max_x_label = $!x_axis_labels.is-empty
							?? 0
							!! $!x_axis_labels.map({.chars}).max;
		my $max_y_label = @reversed_y_labels.is-empty
						   ?? 0
						   !! @reversed_y_labels.map({.chars}).max;

		# expanding each "cell" of that with the appropriate
		# amount of padding based on the X axis labels
		# If there are y axis labels we'll add those
		# after padding to the length of the longest one.
		my $padded_rows = self!pad-columns(@rotated,
											 @reversed_y_labels,
											 $max_x_label
											);

		# if we have x axis labels add them now.
		# This is separated out because the special handling
		# required for the divider line resulted in a whole
		# pile of "oh but if there's an x label" complications
		if ! $!x_axis_labels.is-empty {
			$padded_rows = self!append-x-label-rows($padded_rows, $!x_axis_labels, $max_y_label);
		}

		# join the cells together into one big string
		# with or without spaces between columns.
		my $response = self!join-rows($padded_rows,
									 $!space_between_columns,
									 (! $!x_axis_labels.is-empty),
									 $max_y_label);
		return $response;
	}


	#### Private stuff you don't need to worry about
	#### ... unless there's a bug ;)

	# pads the string you passed in with spaces up to $width
	method !pad-with-space(Str $string, Int $width, Bool $pad_right=True) returns Str {
		return $string if $string.chars >= $width;

		return sprintf('%-' ~ $width ~ 's', $string) if $pad_right;
		return sprintf('%' ~ $width ~ 's', $string);
	}
	# method !pad-with-x-array(Str $string, Int $width, Str $padding_char=' ') returns Array {
	method !pad-with-x-array(Str $string,
							 Int $width,
							 Str $padding_char=' ',
							 Bool $pad_right = True) returns Array {
		my @response = $string.split('', skip-empty => True).Array;
		return @response if @response.elems >= $width;
		if $pad_right {
			return @response.append($padding_char xx $width - @response.elems);
		}
		return ($padding_char xx $width - @response.elems).Array.append: @response;
	}

	method !generate-sideways-graph(Array $data,
									Array $x_axis_labels,
									Int $graph_height,
									Str $bar_column_character) returns Array {

		my @rows = [];
		my @col_widths = []; # if your x axis label is > 1 char we need to compensate
		for $data.pairs -> $pair {
			my $num_chars = $graph_height * ($pair.value / 100);

			my @new_row = self!pad-with-x-array(($bar_column_character x $num_chars), $graph_height);
			# remember, the graph is sideways, so the x axis is currently on the left
			# if it's not there we don't do anything
			# if it is there we prepend to the left side of the row
			@rows.push: @new_row;
		}
		return @rows;
	}

	method !append-x-label-rows(Array $rows,
								Array $x_axis_labels,
								Int $max_y_label) returns Array {

		return $rows if $x_axis_labels.is-empty;
		my $has_y_labels = $max_y_label != 0;
		my $max_x_label  = $x_axis_labels.map({.chars}).max;

		# FIXME
		# BUG NO LEADING FROM Y LABELS DESPITE BELOW
		# also get rid of special handling of last rows in join function
		my @divider_row = $has_y_labels ?? [' ' x $max_y_label + 2] !! [];
		my @label_row = @divider_row;
		#                  (one column's worth of ─)  repeated for num columns
		@divider_row.append: (
			($!x_axis_divider_character x $max_x_label) xx $x_axis_labels.elems
		).Array;

		@label_row.append: $x_axis_labels.map({self!pad-with-space($_, $max_x_label)}).Array;

		$rows.push: @divider_row;
		$rows.push: @label_row;
		return $rows;
	}

	method !pad-columns(Array $rotated_grid,
						Array $reversed_y_labels,
						Int $max_x_label
					   ) returns Array {
		my $max_y_label = $reversed_y_labels.is-empty
							?? 0
							!! $reversed_y_labels.map({.chars}).max;
		my $has_x_labels = $max_x_label > 0;
		my $has_y_labels = $max_y_label > 0;

		my $column_width = $has_x_labels ?? $max_x_label !! 1;

		my $total_rows = $rotated_grid.elems;
		my @result = [];

		for $rotated_grid.pairs -> $row_pair {
			my $original_row = $row_pair.value;
			my @row = [];
			#  $row_pair: 9 => $(" ", " ", " ", " ", " ", "█")
			if $has_y_labels {
				my $left_chars = self!pad-with-x-array(
										$reversed_y_labels[$row_pair.key],
										$max_y_label,
										' ',
										False
									)
									.append([' ', '│']).join('');
				@row.push: $left_chars;
			}
			for $original_row.Array -> $column {
				my $padded_column = self!pad-with-space($column, $column_width);
				@row.append: $padded_column;
			}
			@result.push: @row;
		}
		return @result;
	}

	method !join-rows(Array $padded_rows,
					  Bool $space_between_columns,
					  Bool $has_x_axis,
					  Int $max_y_label) returns Str {
		my $has_y_label = $max_y_label > 0;
		my @response;
		if ($space_between_columns) {
			# no matter what everything up to penultimate row gets added
			# with spaces
			for $padded_rows[0..*-3] -> $row {
			# for $padded_rows.Array -> $row {
				if $has_y_label {
					# first element of row is the concatenation of
					# <y label>, <space>, <vertical bar>
					# ...but we DO want to insert spaced between all the other elements
					@response.append: $row.join(' ');
				} else {
					@response.append: $row.join(' ');
				}
				@response.append: "\n";
			}
			# now deal with the last 2 rows
			@response.append: $padded_rows[*-2].join(
				$has_x_axis ?? $!x_axis_divider_character !! ' '
			);
			@response.append: "\n";
			@response.append: $padded_rows[*-1].join(' ');
			return @response.join('');
		} else {
			return $padded_rows.map({.join('')}).join("\n");
		}
	}
}
