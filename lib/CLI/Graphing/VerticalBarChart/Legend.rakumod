unit class CLI::Graphing::VerticalBarChart::Legend {
	use CLI::Graphing::VerticalBarChart;
	use Text::Wrap;

	has $.data;
	has $.labels;
	has $.key_chars;
	has $.max_width;

	method generate() returns String {
		return "" if $!data.elems == 0;

		my $max_key_chars = calculate-max-key-chars($!data,
													CLI::Graphing::VerticalBarChart::KEY_CHARS);
		my $left_cols_size = 2 + $max_key_chars + 2;
        # ^^ that's  "| " + max_key_chars + ": "

		my $right_cols_size = 2;
        # ^^ that's " |"

		my Str @rows_without_edges = [];
		my $max_text_width = $!max_width - $left_cols_size - $right_cols_size;
		for 0..($!data.elems - 1) -> $index {
			#pair.key = index, pair.value = datum
			my $key = generate-key-for-index(0, $max_key_chars, CLI::Graphing::VerticalBarChart::KEY_CHARS);
			@rows_without_edges.push: generate-legend-row($!labels[$index],
														  $key,
														  $!max_width,
														  $max_key_chars);
		}
		my $max_legend_width = @rows_without_edges.map({.chars}).max;
		$max_legend_width = $max_width - 4 if $max_legend_width + 4 < $max_width;

		my Str @response = [];
		@response.push: generate-top-horizontal-edge($max_legend_width + 4);
		@response.push: "\n";
		my @rows_without_edges = pad-rows-to-width(@rows_without_edges, $max_legend_width);
		for @rows_without_edges -> $row {
			@response.push: "│ ";
			@response.push: $row;
			@response.push: " │";
		}
		@response.push: generate-bottom-horizontal-edge($max_legend_width + 4);
		return @response.join;
	}

	method pad-rows-to-width(Array $rows, Int $largest_legend_size) returns Array {
		my Str @new_rows = [];
		for $rows -> $row {
			if $row.chars < $largest_legend_size {
				@new_rows.push: $row ~ (" " x  ($largest_legend_size - $row.chars));
			} else {
				@new_rows.push: $row;
			}
		}
		return @new_rows;
	}

	method generate-bottom-horizontal-edge(Int $max_width) returns Str {
		"└" ~ ("─" x ($max_width - 2) ) ~ "┘"
	}

	method generate-top-horizontal-edge(Int $max_width) returns Str {
		"┌" ~ ("─" x ($max_width - 2) ) ~ "┐"
	}

	method generate-legend-row(Str $legend,
							  Str $key,
							  Int $max_width,
							  Int $max_key_chars) returns Array {
		my $max_text_width = $max_width - 6 - $max_key_chars;
		my Str @legend = [];
		@legend.push: $key;
		if $key.chars < $max_key_chars {
			@legend.push: (' ' x ($max_key_chars - $key.size));
		}
		@legend.push: ': ';
		my @legend_lines = wrap-text($legend,
									 width => $max_text_width,
									 hard-wrap => False #Undecided about this...
									).lines;
		if @legend_lines.elems == 1 {
			@legend.push: @legend_lines.head;
		} else {
			for @legend_lines.pairs -> $pair {
				#$pair.key == index, $pair.value = text
				@legend.push: ( ' ' x ($max_key_chars + 2) ) if $pair.key > 0;
				@legend.push: $pair.value;
				@legend.push: "\n" if $pair.key != @legend_lines.elems  - 1;
			}
		}

		return @legend_lines;
	}


} # end class
