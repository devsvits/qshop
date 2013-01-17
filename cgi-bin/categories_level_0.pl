#!c:/perl64/bin/perl.exe
##
##  printenv -- demo CGI program which just prints its environment
##

use strict;
use warnings;
use HTML::Template;
use DBI;
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

	
	$row_data {category_0} = $data[1]; 	
	$row_data {URL}="http://localhost/cgi-bin/showClientBills.cgi?clientid=$data[0]";	

	push (@loop_data, \%row_data)	;
	#print $data[1];
}
  	 
$template->param (DB_LOOP => \@loop_data);
  	
# print the template
print $template->output;
$db_handle->disconnect; 
