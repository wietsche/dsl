package RE;

use strict;
use warnings;
use Marpa::R2;
use Data::Dumper;
use File::Slurp;
use Try::Tiny;

use strict;

my %map;
my %info;
my $scope;
my $group = '';

sub query{

my ($code, $node) = @_;
$node = '' unless defined $node;
$node =~ s/\s+//g;
my $dsl = read_file('Lib/rules.dsl'); 
my $grammar = Marpa::R2::Scanless::G->new( { source => \$dsl } );
my $value_ref = $grammar->parse( \$code ,'Actions');

my $res ='';
if ($node eq '') 
    {
        $res = &make_sql(%map);
    }else
    {
        $res = $info{$node}{value};
    }
return $res;
}


sub make_sql{
    #Assuming one source dataset and one target dataset. To be improved.
    my $insert ="";;
    my $select = qq{SELECT };
    my $from = qq{FROM };
    my $tgt_tab; 
    foreach my $key (sort keys %map) {
        $tgt_tab = $info{$key}{'dataset'}; 
        $insert .= "\n\t". $info{$key}{'col'}.",";
        $select .= "\n\t". $map{$key}.",";
    }
    #remove last comma
    $insert = substr($insert,0,-1);
    $select = substr($select,0,-1);

    #look for remaining dataset - assumes this to be the source...improve
    my @sources = ();
    foreach my $key (keys %info) {
        if ( ($info{$key}{'infotype'} eq 'dataset')
            && ($info{$key}{value} ne $tgt_tab))
        { push( @sources, $info{$key}{value});}
    }
    
    my $src_tab = join ',' , @sources;

    $insert = qq{INSERT INTO $tgt_tab ($insert)};
    
    my $sql = qq{ $insert \n $select \n$from $src_tab \n};
    my $where = '';

    $sql = $sql . qq{WHERE $scope \n} if defined $scope;
    $sql = $sql . qq{GROUP BY } .  substr($group,1)  if $group ne '';

    return qq{$sql\n} 
}

#This subroutine will replace a variable with its value
sub Actions::found_InfoVar{
    my $resolved_value;
    my $lkup = '';
    $lkup = lc $_[3] if exists $_[3]; 
    my %param_qualifier = map { $_ => 1 } ('value1','value2','list1','list2');
    if (exists ($param_qualifier{$lkup}) )
    { 
        $resolved_value =  $info{$_[1]}{$lkup};
    }
    else
    {
        $resolved_value =  $info{$_[1]}{value};
    }

    return $resolved_value
}

sub Actions::found_Exp{
    my (undef,$lhs,$op,$rhs)=@_;
    return qq{$lhs  $op  $rhs};
}

sub Actions::found_SubTerm{
    return qq{($_[2])};
}

sub Actions::found_Term{
    return qq{$_[1]};
}

sub Actions::found_funcTerm{
    my $function = $_[1];
    my $operand = $_[3];
    my $paramlist = $_[5];
    $operand .= qq{,$paramlist} if defined $paramlist;
    return qq{$function($operand)} 
}


sub Actions::test{
    print Dumper @_;
    return;
}

sub Actions::add_col{
    my (undef,$dataset,$name,undef,$col)=@_;
    my %c = (infotype => 'column',
            dataset => $dataset,
            col => $col,
            value => $dataset.".".$col,
            );
    $info{$name} = \%c;
    return $dataset;
}

sub Actions::add_dataset{
    my (undef,$name,undef,$dataset)=@_;
    my %d = (infotype => 'dataset',
            value => $dataset,
            );
    $info{$name} = \%d;
    return $dataset
}

sub Actions::add_exp{
    #todo: add lineage for complex expressions
    my(undef,$name,undef,$exp)=@_;
    my %e = (infotype => 'expression',
            exp => $exp,
            value => qq{($exp)},
            );
    $info{$name} = \%e;
    return
}

sub Actions::add_param{
    my(undef,$name,undef,$val1,undef,$val2)=@_;
    
    if(! exists $info{$name})
        {
        my %p = (infotype => "parameter",
                value1 => $val1,
                value2 => $val2,
                value => "@".$name,
                list1 => qq{($val1)},
                list2 => qq{($val2)},
                );
        $info{$name} = \%p;
        } else #if exists we extend the lists
        {
            #remove  brackets 
            my $templist1 = substr($info{$name}{list1}, 1, -1);
            my $templist2 = substr($info{$name}{list2}, 1, -1);
            
            #extend lists
            $info{$name}{list1} = qq{($templist1,$val1)};
            $info{$name}{list2} = qq{($templist2,$val2)};
        }
    

    return
}

sub Actions::add_rule_step{
    my (undef,$rule,$step,undef,undef,$cnd,undef,$res) = @_;

    $info{$rule}{'steps'}{$step} = qq{\tWHEN $cnd \n\t\t\tTHEN $res}; 
    my @steps = keys $info{$rule}{'steps'};
    my $rule_val = "CASE \n";
    
    
    foreach my $step (sort @steps) {
        $rule_val .= "\t" .$info{$rule}{'steps'}{$step} . "\n";
    }
    $rule_val .= qq{\tEND};

    $info{$rule}{'value'} = qq{($rule_val)};

    return
}
sub Actions::add_last_rule_step{
    my (undef,$rule,$step,undef,undef,$res) = @_;

    $info{$rule}{'steps'}{$step} = qq{\tELSE $res}; 
    my @steps = keys $info{$rule}{'steps'};
    my $rule_val = "CASE \n";

    foreach my $step (sort @steps) {
        $rule_val .= "\t" .$info{$rule}{'steps'}{$step} . "\n";
    }
    $rule_val .= qq{\tEND};
    $info{$rule}{'value'} = qq{($rule_val)};
   return
}

sub Actions::add_map {
    my (undef, undef, $source, undef, $target)=@_;
    $map{$target} = $source;
    $source = '' unless defined $source;
    $group .= qq{,$source}  if ((defined $_[5]) &&  $_[5] eq 'GROUP');
    return
};

sub Actions::add_scope {
    $scope = $info{$_[2]}{value}; 
    return;
}

1;
