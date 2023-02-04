use Terminal::Graphing::BarChart::Core;

class Terminal::Graphing::BarChart::Horizontal is Terminal::Graphing::BarChart::Core {
	use Listicles;
	# From Core...
	# has $.data;
	# has $.bar_length;
	# has $.y_axis_labels = [];
	# has $.x_axis_labels = [];

	has $.bar_drawing_character = '▄';

	method generate() returns Str {
		self.validate-or-die();


		my $rows = self.generate-core-graph($.data, $.bar_length, $.bar_drawing_character);
		# X axis labels are just another row
		# Y axis labels just get prepended
		# 0x0 is top left
		# the last row is the x axis labels (if present)
		#
		# 1. find the length of the longest y_axis_labels
		my $max_y_label = $.y_axis_labels.map({.chars}).max;
		my $border =[' ', '│', ' '];
		if $.y_axis_labels {
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
			if ! $.x_axis_labels.is-empty {
				$rows.push(self.pad-with-x-array(" │ ",
															$max_y_label + 3,
															' ',
															False
															)
						.append($.x_axis_labels.Array))
			}
		} elsif ! $.x_axis_labels.is-empty {
			$rows.push($.x_axis_labels)
		}

		self!join-rows($rows);
	}
	method !join-rows($rows){
		$rows.map({.join('')}).join("\n");
	}

	method validate-or-die(){
		self.validate-bar-length();
		if $.x_axis_labels {
			self.validate-x-labels($.x_axis_labels);
			self.x_axis_labels = $.x_axis_labels.map({.Str}).Array;
		}
		if $.y_axis_labels {
			self.validate-y-labels($.y_axis_labels, $.data);
			self.y_axis_labels = $.y_axis_labels.map({.Str}).Array;
		}

	}
	#| either works or dies
	method validate-x-labels($x_labels) {
		return True unless $x_labels;
		my $all_good = $x_labels.all-are(-> $x {$x.chars <= 1 });
		die("x labels on horizontal graphs must be 1 or zero characters long") unless $all_good;
		if $x_labels.elems > $.bar_length {
			die ("You can't have more x labels than characters in the bar_length");
		}
	}
	method validate-y-labels($y_labels, $data){
		return True unless $y_labels;
		if $y_labels.elems > 0 & $y_labels.elems > $data.elems {
			die("You can't have more y labels than data elements.")
		}
	}
}
