use Listicles;

unit module CLI::Graphing::VerticalBarChart;

constant KEY_CHARS is export =  ('a'..'z').Array.append: ('A'..'Z').Array;

our sub calculate-max-key-chars(Array $data, Array $key_chars) returns Int is export {
	return ($data.elems / $key_chars.elems) + 1
}

our sub get-key-chars(Array $custom_chars?) returns Array {
	if $custom_chars and ! $custom_chars.is-empty {
		$custom_chars;
	} else {
		KEY_CHARS;
	}
}

our sub generate-key-for-index(Int $index, Int $max_key_chars, Array $key_chars) returns Str is export {
	my $multiplier = ($index / $key_chars.elems) + 1;
	my $lc_index = $index - ($multiplier * $key_chars.elems);
	my $key = ($key_chars[$lc_index] * $multiplier);
	if $key.chars < $max_key_chars {
		my $key_padding_size = $max_key_chars - $key.chars;
		$key ~= " " x $key_padding_size;
	}
	return $key;
}


=begin pod

=head1 NAME

CLI::Graphing::VerticalBarChart - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use CLI::Graphing::VerticalBarChart;

=end code

=head1 DESCRIPTION

CLI::Graphing::VerticalBarChart is ...

=head1 AUTHOR

 <>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
