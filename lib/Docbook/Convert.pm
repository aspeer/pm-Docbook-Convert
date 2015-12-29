#
#  This file is part of Docbook::Convert.
#
#  This software is copyright (c) 2015 by Andrew Speer <andrew.speer@isolutions.com.au>.
#
#  This is free software; you can redistribute it and/or modify it under
#  the same terms as the Perl 5 programming language system itself.
#
#  Full license text is available at:
#
#  <http://dev.perl.org/licenses/>
#

#
#
package Docbook::Convert;


#  Pragma
#
use strict qw(vars);
use vars qw($VERSION);
use warnings;
no warnings qw(uninitialized);
sub BEGIN {local $^W=0}


#  External modules
#
use Docbook::Convert::Constant;
use Docbook::Convert::Util;


#  External modules
#
use XML::Twig;
use Data::Dumper;


#  Version information in a format suitable for CPAN etc. Must be
#  all on one line
#
$VERSION='0.001';


#  All done, init finished
#
1;


#===================================================================================================


sub process {

    
    #  Get self ref, file to process
    #
    my ($self, $fn, $param_hr)=@_;
    
    
    #  Create a hashed self ref to hold various info
    #
    ref($self) || do {
        $self=bless($param_hr ||= { handler=>$HANDLER_DEFAULT }, ref($self) || $self)
    };
    
    
    #  Array to hold parsed data
    #
    my $data_ar=$self->data_ar();
    
    
    #  Load handler
    #
    my $handler=$param_hr->{'handler'} ||
        return err('no handler supplied');
    my $handler_module=$HANDLER_HR->{$handler} ||
        return err("unable to load handler: $handler, no module found");
    eval("use $handler_module") || do {
        return err("unable to load handler module: $handler_module, $@")
            if $@};
    
    
    #  Get XML::Twig object 
    #
    my $xml_or=XML::Twig->new(
        'twig_handlers' => {
            '_all_'     => sub { $self->handler($data_ar, @_) }
        },
        'start_tag_handlers' => {
            '_all_'     => sub { $self->start_tag_handler($data_ar, @_) }
        }
    );
    
    
    
    #  Parse file which will fill $data_ar;
    #
    $xml_or->parsefile($fn);
    return Dumper($data_ar) if 
        $param_hr->{'dump'};

    
    
    #  And render
    #
    my $output=$self->render($data_ar, $handler_module);
    
    
    #  Output remaining tree if wanted
    #
    if ($param_hr->{'dumprender'}) {
        return Dumper($data_ar)
    }
    
    
    #  Done
    #
    return $output;

}    


sub start_tag_handler {

    my ($self, $data_ar, $twig_or, $elt_or)=@_;
    $elt_or->set_att('_line_no', $twig_or->current_line());
    $elt_or->set_att('_col_no', $twig_or->current_column());
    
}


sub handler {

    
    #  Called by twig
    #
    my ($self, $data_ar, $twig_or, $elt_or)=@_;
    
    
    #  Don't process if not parent (i.e. until we have done all tags).
    #
    return if $elt_or->parent();
    
    
    #  Call parser now as we are on parent.
    #
    return $self->parse($data_ar, $elt_or);

}


sub data_ar {

    #  Container to hold node tree
    #
    my @data=(
        undef,  # NODE_IX
        undef,  # CHLD_IX
        undef,  # ATTR_IX
        undef,  # LINE_IX
        undef,  # COLM_IX
        undef   # PRNT_IX
    );
    return \@data;
    
}


sub parse {


    #  Parse and XML::Twig tree and produce a node tree
    #
    my ($self, $data_ar, $elt_or, $data_parent_ar)=@_;
    
    
    #  Get tag, any node attributes, line and col number
    #
    my $tag=$elt_or->tag();
    my $attr_hr=$elt_or->atts();
    my $line_no=delete $attr_hr->{'_line_no'};
    my $col_no=delete $attr_hr->{'_col_no'};
    $attr_hr=undef unless keys %{$attr_hr};
    
    
    #  Build array data
    #
    @{$data_ar}[$NODE_IX, $CHLD_IX, $ATTR_IX, $LINE_IX, $COLM_IX, $PRNT_IX]=
        ($tag, undef, $attr_hr, $line_no, $col_no, $data_parent_ar); # Name, Child, Attr
        
        
    #  Go through children looking for any text nodes
    #
    foreach my $elt_child_or ($elt_or->children()) {
    
        #  Text ?
        #
        unless ($elt_child_or->tag() eq '#PCDATA') {
            
            # No - recurse. Need new data container
            #
            my $data_child_ar=$self->data_ar();
            $self->parse($data_child_ar, $elt_child_or, $data_ar);
            push @{$data_ar->[$CHLD_IX]}, $data_child_ar;
        }
        else {
        
            # Yes - clean up and store
            my $text=$elt_child_or->text();
            $text=~s/ +/ /g;
            push @{$data_ar->[$CHLD_IX]}, $text;
        }
    }
    

    #  Done - return OK
    #
    return \undef;

}  


sub render {

    
    #  Get self ref, node tree
    # 
    my ($self, $data_ar, $handler)=@_;
    
    
    #  Get hander
    #
    my $render_or=$handler->new() ||
        return err("unable to initialise handler $handler");
    #my $t=$render_or->find_node_text_all($data_ar);
    #die;
    #die Dumper($t);    
    
    #  Call recurive render routine
    #
    #die Dumper($data_ar);
    my $output=$self->render_recurse($data_ar, $render_or) ||
        return err('unable to get ouput from render');
    #die Dumper($data_ar);
    #exit 0;
        
        
    #  Find any unrendered nodes now and render as text
    #
    #my $output=$self->render_recurse_text($data_ar, $render_or);
    #die Dumper($text);    
    
    
    #  Any errors ?
    #
    #die "BANG !";
    if (my $hr=$render_or->{'_autoload'}) {
        my @data_ar=sort { ($a->[$NODE_IX] cmp $b->[$NODE_IX]) or ($a->[$LINE_IX] <=> $b->[$LINE_IX]) } grep {$_} values (%{$hr});
        foreach my $data_ar (@data_ar) {
            my ($tag, $line_no, $col_no)=@{$data_ar}[$NODE_IX, $LINE_IX, $COLM_IX];
            warn ("warning - unrendered tag $tag at line $line_no, column $col_no\n");
        }
        #my %tag=map { $_->[$NODE_IX]=>1 } values (%{$hr});
        #warn ('warning - unrendered tags: ', Dumper([keys %tag]));
    }
    if (my $hr=$render_or->{'_autotext'}) {
        my @data_ar=sort { ($a->[$NODE_IX] cmp $b->[$NODE_IX]) or ($a->[$LINE_IX] <=> $b->[$LINE_IX]) } grep {$_} values (%{$hr});
        foreach my $data_ar (@data_ar) {
            my ($tag, $line_no, $col_no)=@{$data_ar}[$NODE_IX, $LINE_IX, $COLM_IX];
            warn ("warning - autotexted tag $tag at line $line_no, column $col_no\n");
        }
    }
    #die;
    #    
    #die (Dumper($render_or->{'_autoload'}));
    #warn ('warning - unrendered tags: ', Dumper($render_or->{'_autoload'}, $render_or->{'_unrender'})) if
    #    !$self->{'silent'} && $render_or->{'_autoload'};
        
        
    #  Done
    #
    #die Dumper($data_ar);
    return $output;
    
}


sub render_recurse {

    
    #  Get self ref, node
    #
    my ($self, $data_ar, $render_or)=@_;
    
    
    #  Render any children
    #
    if ($data_ar->[$CHLD_IX]) {
        foreach my $data_chld_ix (0 .. $#{$data_ar->[$CHLD_IX]}) {
            my $data_chld_ar=$data_ar->[$CHLD_IX][$data_chld_ix];
            if (ref($data_chld_ar)) {
                my $data=$self->render_recurse($data_chld_ar, $render_or);
                $data_ar->[$CHLD_IX][$data_chld_ix]=$data;
            }
        }
    }
    my $tag=$data_ar->[$NODE_IX];
    my $render=$render_or->$tag($data_ar);
    return $render;
    
}


sub render_recurse_text {

    
    #  Get self ref, node
    #
    my ($self, $data_ar, $render_or)=@_;
    
    
    #  Render any children
    #
    if ($data_ar->[$CHLD_IX]) {
        foreach my $data_chld_ix (0 .. $#{$data_ar->[$CHLD_IX]}) {
            my $data_chld_ar=$data_ar->[$CHLD_IX][$data_chld_ix];
            if (ref($data_chld_ar)) {
                my $data=$self->render_recurse_text($data_chld_ar, $render_or);
                $data_ar->[$CHLD_IX][$data_chld_ix]=$data;
            }
        }
    }
    my $text=$render_or->find_node_text($data_ar, undef, "\n\n");
    return $text;;
    
}

__END__

=head1 NAME

Docbook::Convert - Module Synopsis/Abstract Here

=head1 LICENSE and COPYRIGHT

This file is part of Docbook::Convert.

This software is copyright (c) 2015 by Andrew Speer <andrew.speer@isolutions.com.au>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Full license text is available at:
L<http://dev.perl.org/licenses/>
