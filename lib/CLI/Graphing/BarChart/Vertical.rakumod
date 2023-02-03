use CLI::Graphing::BarChart::Core;

class CLI::Graphing::BarChart::Vertical is CLI::Graphing::BarChart::Core {
	use Listicles;


	# From Core...
	# has $.data;
	# has $.bar_length;
	# has $.y_axis_labels = [];
	# has $.x_axis_labels = [];

	has $.bar_drawing_character = '█';
	has $.x_axis_divider_character = '─';
	has $.space_between_columns = True;
	has $.graph_height is rw = 10;



	#| Generates a string representation of the graph.
	method generate() returns Str {
		self.bar_length = $.graph_height;
		self.validate-or-die();
		# data is a list of numbers
		#   we're going to assume numbers are percentages
		# bar_length is the max height of the table
		#   bar_length = 100%
		#   column height is $bar_length * ($datum / 100)
		#
		# BUT we're actually going to bulid the table horizontally
		# then rotate it left 90°
		# 1st datum = first row.
		#

		my $rows = self.generate-core-graph($.data,
											$.bar_length,
											$.bar_drawing_character);


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
		my @reversed_y_labels = $.y_axis_labels.reverse;

		# Going to need these in a moment.
		my $max_x_label = $.x_axis_labels.is-empty
							?? 0
							!! $.x_axis_labels.map({.chars}).max;
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
		if ! $.x_axis_labels.is-empty {
			$padded_rows = self!append-x-label-rows($padded_rows, $.x_axis_labels, $max_y_label);
		}

		# join the cells together into one big string
		# with or without spaces between columns.
		my $response = self!join-rows($padded_rows,
									 $.space_between_columns,
									 (! $.x_axis_labels.is-empty),
									 $max_y_label);
		return $response;
	}


	#### Private stuff you don't need to worry about
	#### ... unless there's a bug ;)

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
			($.x_axis_divider_character x $max_x_label) xx $x_axis_labels.elems
		).Array;

		@label_row.append: $x_axis_labels.map({self.pad-with-space($_, $max_x_label)}).Array;

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
				my $left_chars = self.pad-with-x-array(
										$reversed_y_labels[$row_pair.key],
										$max_y_label,
										' ',
										False
									)
									.append([' ', '│']).join('');
				@row.push: $left_chars;
			}
			for $original_row.Array -> $column {
				my $padded_column = self.pad-with-space($column, $column_width);
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
				$has_x_axis ?? $.x_axis_divider_character !! ' '
			);
			@response.append: "\n";
			@response.append: $padded_rows[*-1].join(' ');
			return @response.join('');
		} else {
			return $padded_rows.map({.join('')}).join("\n");
		}
	}
	method validate-or-die(){
		self.validate-bar-length();
		if $.x_axis_labels {
			self.validate-x-labels($.x_axis_labels, $.data);
			self.x_axis_labels = $.x_axis_labels.map({.Str}).Array;
			# $.x_axis_labels.map({.Str}).Array;
		}
		if $.y_axis_labels {
			self.validate-y-labels($.y_axis_labels);
			self.y_axis_labels = $.y_axis_labels.map({.Str}).Array;
			# $.y_axis_labels.map({.Str}).Array;
		}
	}
	method validate-x-labels($x_labels, $data){
		return True unless $x_labels;
		if $x_labels.elems > 0 and $x_labels.elems != $data.elems {
			die("There must be 1 x axis label for each data element.");
		}
	}
	method validate-y-labels($y_labels){
		if $y_labels.elems > 0 and $y_labels.elems != $.bar_length {
			die("There must be 1 y axis label for each row of the graph.");
		}
	}
}
