use Terminal::Graphing::BarChart::Core;

class Terminal::Graphing::BarChart::Horizontal is Terminal::Graphing::BarChart::Core {
	use Listicles;
	# From Core...
	# has $.data;
	# has $.bar_length;
	# has $.y_axis_labels = [];
	# has $.x_axis_labels = [];

	has $.bar_drawing_character = '▄';
	has $.x_axis_divider_character = '─';

	method generate() returns Str {
		self.validate-or-die();


		my $rows = self.generate-core-graph($.data, $.bar_length, $.bar_drawing_character);
		# 0x0 is top left
		my $max_y_label = $.y_axis_labels.is-empty ?? 0 !! $.y_axis_labels.map({.chars}).max;
		my $max_x_label = $.x_axis_labels.is-empty ?? 0 !! 1;
			#$.x_axis_labels.map({.Str.chars}).max;
		my $per_x_label_chars = $max_x_label > 0
								 ?? ($.bar_length / $.x_axis_labels.elems).Int
								 !! 0; # guaranteed evenly divisible
		my $divider_row = $max_x_label > 0
						   ?? ((' ' x ($max_y_label) + 3)
						       ~ ($.x_axis_divider_character x $.bar_length))
								.split('', skip-empty=>True)
						   !! [];

		my $padded_x_labels = $max_x_label > 0
							   ?? $.x_axis_labels.map({self.pad-with-space($_, $per_x_label_chars)}).Array
							   !! [];
		my $border =[' ', '│', ' '];
		if $max_y_label > 0 {
			for (0..^$.data.elems) -> $index {
				if $index < $.y_axis_labels.elems {
					my $prepension = self.pad-with-x-array($.y_axis_labels[$index],
													 $max_y_label,
													 ' ',
													 False);
					$rows[$index] = $prepension
									 .append($border.Array)
									 .append($rows[$index].Array);
				} else {
					# they have fewer Y axis items than data points
					$rows[$index] = self.pad-with-x-array(" │ ",
														 $max_y_label + 3,
														 ' ',
														 False
														 ).append($rows[$index].Array);
				}
			}
			if $max_x_label > 0 {
				$rows.push( $divider_row );
				$rows.push(self.pad-with-x-array(
								  "   ",
								  $max_y_label + 3,
								  ' ',
								  False
								  )
								.append($padded_x_labels.Array));
			}
		} elsif $max_x_label > 0 {
			$rows.push( $divider_row );
			$rows.push($padded_x_labels.Array);
		}

		self!join-rows($rows);
	}
	method !join-rows($rows){
		$rows.map({.join('')}).join("\n");
	}

	method validate-or-die(){
		self.validate-bar-length();
		if $.x_axis_labels {
			self.validate-x-labels($.x_axis_labels, $.bar_length);
			self.x_axis_labels = $.x_axis_labels.map({.Str}).Array;
		}
		if $.y_axis_labels {
			self.validate-y-labels($.y_axis_labels, $.data);
			self.y_axis_labels = $.y_axis_labels.map({.Str}).Array;
		}

	}
	#| either works or dies
	method validate-x-labels($x_labels, $bar_length) {
		return True unless $x_labels;
		my $all_short = $x_labels.all-are(-> $x {$x.chars <= 1 });
		die("x labels on horizontal graphs must be 1 or zero characters long") unless $all_short;
		if ($bar_length % $x_labels)  != 0 {
			die ("bar_length must be evenly divisble by the number of x_axis labels");
		}
	}
	method validate-y-labels($y_labels, $data){
		return True unless $y_labels;
		if $y_labels.elems > 0 & $y_labels.elems > $data.elems {
			die("You can't have more y labels than data elements.")
		}
	}
}
