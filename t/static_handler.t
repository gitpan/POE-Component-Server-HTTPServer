# -*- perl -*-
use Test::More 'no_plan';

use HTTP::Status;
use HTTP::Response;

BEGIN { 
  use_ok('POE::Component::Server::HTTPServer');
  use_ok('POE::Component::Server::HTTPServer::Handler');
  use_ok('POE::Component::Server::HTTPServer::StaticHandler');
};

my $h = new_handler( 'StaticHandler', './t' );
ok( defined($h), 'constructor returns defined' );
isa_ok( $h, 'POE::Component::Server::HTTPServer::Handler' );
can_ok( $h, 'handle' );

# this set of tests is dumb

{
  my $req = HTTP::Request->new();
  $req->uri( "http://www.example.com/bogus.doc" );
  $req->method("GET");
  my $resp = HTTP::Response->new( RC_NOT_FOUND ); # this shouldn't get reset
  my $retval = $h->handle( { request => $req, 
			     response => $resp,
			     contextpath => "/bogus.doc",
			   } );
  ok( $retval == H_CONT, "Handler couldn't finalize response (1)" );
  ok( $resp->code == RC_NOT_FOUND, 'Response has correct code' );
}

{
  my $req = HTTP::Request->new();
  $req->uri( "http://www.example.com/static_handler.t" );
  $req->method("GET");
  my $resp = HTTP::Response->new( RC_NOT_FOUND ); # this should get reset
  my $retval = $h->handle( { request => $req, 
			     response => $resp,
			     fullpath => $req->uri->path,
			     contextpath => "/static_handler.t",
			   } );
  ok( $retval == H_FINAL, 'Handler finalized response (2)' );
  ok( $resp->code == RC_OK, 'Response has correct code' );
  ok( $resp->content(), 'Response has content' );
}


