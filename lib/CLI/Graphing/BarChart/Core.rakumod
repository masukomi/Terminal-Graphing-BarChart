class CLI::Graphing::BarChart::Core {
	use Listicles;
	has $.data;
	has $.bar_length is rw = 10;
	has $.y_axis_labels is rw = [];
	has $.x_axis_labels is rw = [];
	# has $.bar_drawing_character = '█';

	# Implement these in subclasses
	method generate(){...}

	#| Prints the graph to standard out.
	method print() {
		say self.generate();
	}

	method validate-bar-length() {
		unless $!bar_length {
			die("You must specify a bar_length (number of lines for the core graph).");
		}
	}

	# each row is an array of the characters that make up that row
	method generate-core-graph(Array $data,
							   Int $bar_length,
							   Str $bar_element_character
							   ) returns Array {

		my @rows = [];
		for $data.pairs -> $pair {
			my $num_chars = $pair.value * ($bar_length / 100);

			my $bar_chars = ($bar_element_character x $num_chars);
			my @new_row = $bar_length == 1
						   ?? $bar_chars.split('', skip-empty => True).Array
						   !! self.pad-with-x-array($bar_chars, $bar_length);

			# remember, the graph is sideways, so the x axis is currently on the left
			# if it's not there we don't do anything
			# if it is there we prepend to the left side of the row
			@rows.push: @new_row;
		}
		return @rows;
	}
	# pads the string you passed in with spaces up to $width
	method pad-with-space(Str $string, Int $width, Bool $pad_right=True) returns Str {
		return $string if $string.chars >= $width;

		return sprintf('%-' ~ $width ~ 's', $string) if $pad_right;
		return sprintf('%' ~ $width ~ 's', $string);
	}
	# method !pad-with-x-array(Str $string, Int $width, Str $padding_char=' ') returns Array {
	method pad-with-x-array(Str $string,
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

}
