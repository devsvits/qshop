#!c:/perl64/bin/perl.exe
##
##  printenv -- demo CGI program which just prints its environment
##

use strict;
use warnings;
use HTML::Template;
use DBI;
#use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use CGI;
# read the CGI params
my $cgi = CGI->new;
my $cate_id = $cgi->param("category_id");


#send the obligatory Content-Type
print "Content-Type: text/html\n\n"; 
  
my $user = 'root';
my $password = 'Devesh#1';
  
my $db_handle = DBI->connect ('DBI:mysql:database=qshop',$user,$password) 
	or die "Couldn't connect to database: $DBI::errstr\n";
  		
#set the value of SQL query
my $sql_query = "select * from table_categories_level_0 order by category_name";

#prepare your statement for connecting to the databse
my $statement = $db_handle->prepare ($sql_query)
	or die "Couldn't prepare query '$sql_query': $DBI::errstr\n";  
  
#execute youe sql statement
$statement->execute()
	or die "SQL Error: $DBI::errstr\n";  
  	 	
# open the HTML template
my $template = HTML::Template->new(filename => 'categories_level_0.tmpl');
  
my @loop_data = ();
  	
while (my @data = $statement->fetchrow_array())
{
	#print @data;		
	my %row_data; # get a fresh hash for row data

	

	$row_data {clientName} = $data[1]; 	
	$row_data {URL}="http://localhost/cgi-bin/categories_level_0.pl?category_id=$data[0]";
	push (@loop_data, \%row_data)	;
	#print $data[1];
}
  	 
$template->param (DB_LOOP => \@loop_data);

$sql_query = "select * from table_categories_level_1 where category_id = '$cate_id'";
#prepare your statement for connecting to the databse
$statement = $db_handle->prepare ($sql_query) or die "Couldn't prepare query '$sql_query': $DBI::errstr\n";  
#execute youe sql statement
$statement->execute() or die "SQL Error: $DBI::errstr\n";  
  	 	
  
  
my @loop_data = ();            # initialize an array to hold your loop

while (my @data = $statement->fetchrow_array())
{
    my %row_data;               # get a fresh hash for the row data
    # Fill in this row
    $row_data {sub_cate_name} = $data[1]; 
    
	$sql_query = "select * from table_product where sub_cate_id = '$data[0]'";
	my $statement2 = $db_handle->prepare ($sql_query) or die "Couldn't prepare query '$sql_query': $DBI::errstr\n";  
	$statement2->execute() or die "SQL Error: $DBI::errstr\n";  
	
	
    # Here goes the inner loop data
    my @inner_loop_data = ();            # initialize an array to hold your loop
    while (my @data2 = $statement2->fetchrow_array())
	
    {
        my %nested_row_data;               # get a fresh hash for the nested row data
        $nested_row_data{product_name} = $data2[1];
        # The crucial step - push a reference to this row into the inner loop!
        push(@inner_loop_data, \%nested_row_data);
    }
    $row_data{product_loop} = \@inner_loop_data;
    # The crucial step - push a reference to this row into the loop!
    push(@loop_data, \%row_data);
}

# finally, assign the loop data to the loop param, again with a reference:
$template->param(DB_LOOP2 => \@loop_data);
  
		
	
  	 

  	

# print the template
print $template->output;
$db_handle->disconnect; 
