#!c:/perl64/bin/perl.exe
##
##  printenv -- demo CGI program which just prints its environment
##

use strict;
use warnings;
use HTML::Template;
use DBI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use CGI;

# read the CGI params
my $cgi = CGI->new;

my $user = 'root';
my $password = 'Devesh#1';
  
my $db_handle = DBI->connect ('DBI:mysql:database=qshop',$user,$password) 
	or die "Couldn't connect to database: $DBI::errstr\n";
  		
#set the value of SQL query
my $sql_query = "select sub_cate_name from table_categories_level_1";

#prepare your statement for connecting to the databse
my $statement = $db_handle->prepare ($sql_query)
	or die "Couldn't prepare query '$sql_query': $DBI::errstr\n";  
  
#execute youe sql statement
$statement->execute()  or die "SQL Error: $DBI::errstr\n";  
  	 

my @loop_data = ();
while (my @data = $statement->fetchrow_array())
{
	#print @data;		
	my %row_data; # get a fresh hash for row data

	
	$row_data {sub_cate_name} = $data[1]; 	
	#$row_data {URL}="http://localhost/cgi-bin/showClientBills.cgi?clientid=$data[0]";	

	push (@loop_data, \%row_data)	;
	#print $data[1];
}

# open the HTML template
my $template = HTML::Template->new(filename => 'categories_level_0.tmpl');

$template->param(BOOL => 1);
$template->param (DB_LOOP2 => \@loop_data);

print $template->output;
# return JSON string

# create a JSON string according to the database result
my $json = qq{{"success" : "login is successful", "userid" : @loop_data}} ;


print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;