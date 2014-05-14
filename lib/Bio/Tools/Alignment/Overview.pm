package Bio::Tools::Alignment::Overview;

use 5.008;
use strict;
use warnings;
use GD::Simple;

our $VERSION = "0.3";

sub new {
	my ($class, @args) = @_;
	my $self = {};
	$self->{fileInput}	= undef,
	$self->{fileOutput}	= undef,
	$self->{Pencolor}	= 'blue',
	bless($self, $class);
	return $self;
}


sub input {
	my $self = shift;
	if (@_) { $self->{fileInput} = shift};
	return $self->{fileInput};
}


sub output {
	my $self = shift;
	if (@_) { $self->{fileOutput} = shift};
	return $self->{fileOutput};
}


sub color {
	my $self = shift;
	if (@_) { $self->{penColor} = shift};
	return $self->{penColor};
}


sub make_image{
	my $self = shift;   

	# variables;
	my $fileInPath	= $self->input or die "\n I think you forgot to pass me the input file. \n";
	my $fileOutPath	= $self->output or die "\n I think you forgot to pass me the output file. \n";
	my $penColor	= $self->color;	
	my $seqCounter	= 0;
	my $alignSize	= 0;
	my $proportion	= 0;
	my $height		= 0;
	my $penSize		= 6;
	my $background	= 'white';
	my $seqSpace	= 10;
	my $img			= '';
	my $x			= 10;
	my $y			= 10;
	my $position	= 0;
	my $char		= '';
	my %seqHash;
	my %sortedHash;
	
	open (my $fh, '<', "$fileInPath") or die "\n Can't load file, check the file name and its location \n";

	# iterates the file saving the sequences to a hash whit a 'id' number (seqCounter).
	while (my $line = <$fh>) {
	
		next if $line !~ m/^\S+/;
		chomp $line;

		if ($line =~ m/^\>(.+)/) {
			$seqCounter++;
			$seqHash{$seqCounter} = '';
		} else {
			$seqHash{$seqCounter} = $seqHash{$seqCounter}.$line;
			$alignSize = length($seqHash{$seqCounter});
		}
	}

	# gets the right proportion for images with 560 of weight.
	$proportion = $alignSize / 560;

	# the height is cauculated based on the number os sequences in the hash.
	$height = keys (%seqHash);

	# this is an adjustment of the tickness of the lines that will representate the sequences. With fewer sequences
	# the pensize gets bigger and vice versa.
	$penSize	= 6;
	$seqSpace	= 10; 
	
	if ($height > 20 && $height < 80) {
		$penSize	= 4;
		$seqSpace	= 8;	
	} elsif ($height >= 80) {
		$penSize	= 3;
		$seqSpace	= 5;
	}

	# last adjustment in height size.
	$height = ($height * $seqSpace) + 20;

	# now, lets draw!
	$img = GD::Simple->new(580, $height);
	$img->bgcolor(undef);
	$img->fgcolor('black');
	$img->rectangle(0,0,579, ($height -1));

	$x = 10;
	$y = 10;
	
	$img->bgcolor($background);
	$img->fgcolor($penColor);
	$img->penSize($penSize);
	$img->moveTo($x, $y);

	# first we create a new hash that will be sorted by sequence size.
	for my $key (keys %seqHash) {
		my $counter;
		$counter = $seqHash{$key} =~ s/(\w)/$1/g;
		$sortedHash{$key} = $counter;
	}

	# this is the part were the drawn is actually made.
	for my $key (sort { $sortedHash{$b} <=> $sortedHash{$a} } keys %sortedHash) {
		
		my @elements = split(//, $seqHash{$key});

		for my $char (@elements) {
			
			if ($char eq '-') {
				$position++;
				$img->moveTo( ($x + ($position / $proportion) ), ($y) );
			} else {
				$position++;
				$img->lineTo( ($x + ($position / $proportion) ), ($y) );
			}
		}
		
		$x = 10;
		$y += $seqSpace;
		$position = 0;
		$img->moveTo($x, $y);
	}
	
	open (my $fh2, '>', "$fileOutPath.png" ) or die "\n Error in creating out file! \n";
	print $fh2 $img->png;
}

1;
__END__;


=head1 NAME

Bio::Tools::Alignment::Overview - just another represetation for biological sequence alignment.

=head1 DESCRIPTION

This module creates a simple and resumed representation of a biological sequence alignment.
For now you can ajust the sequence color, with time new customizations will be implemented.
If you find any problem please let me know.

=head1 BASIC USAGE

instantiate the overview object.

	use warnings;
	use strict;
	use Bio::Tools::Alignment::Overview();

	my $view = Bio::Tools::Alignment::Overview->new();

and pass the required parameters.

	$view->input('path_to_my_align_file');
	$view->outup('path_to_my_output_file'); # no extension is required.
	$view->color('color_name'); # 'red'

create the image.

	$view->make_image();

=head1 Methods

For the moment the only customization available is the color for the sequences.

=over

=item INPUT.

	$object->input();

The module is compatible with alignments generated by other programs like ClustalW, MUSCLE and T-COFEE.

=item OUTPUT.

	$object->output();

No extension is required for the output file, the module generates automatically a .png file. 

=item COLOR.

	$object->color();

The module depends on GD::Simple for making the images files so the available colors are listed in L<GD::Simple>.
The default color is blue.

=item MAKE_IMAGE.

	$object->make_image();

This is the method responsible for generating the image file with png extension.

=back

=head1 AUTHOR

Leprevost, C<< <leprevostfv at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bio-tools-alignment-overview at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bio-Tools-Alignment-Overview>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bio::Tools::Alignment::Overview


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bio-Tools-Alignment-Overview>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bio-Tools-Alignment-Overview>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bio-Tools-Alignment-Overview>

=item * Search CPAN

L<http://search.cpan.org/dist/Bio-Tools-Alignment-Overview/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Leprevost.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 SEE ALSO

L<GD::Simple>

=cut
