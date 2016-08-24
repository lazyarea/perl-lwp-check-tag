#!/usr/bin/env perl -w

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use Text::CSV;
use Data::Dumper;

# load csv from file
my @csv = &load_csv_from_file("./chk.csv");
my $tag = 'a';

foreach my $line (@csv){
  my $url   = shift($line);
  my $realm = shift($line);
  my $user = shift($line);
  my $pass = shift($line);
  my $tags = &find_tag_from_content($url, $realm, $user, $pass, $tag); # htmlをparseして指定タグをリストで返す;

  foreach my $l (@$line){
    my $flag = undef;
    foreach my $t (@$tags){
        if ( $t =~ /$l/){
            $flag = 1;
#            warn Dumper $l." is found.";
        }
    }
    warn Dumper $l." is not found." if !$flag;
  }
}

sub find_tag_from_content
{
    my $url   = $_[0];
    my $realm = $_[1];
    my $user  = $_[2];
    my $pass  = $_[3];
    my $tag   = $_[4];
    # get content
    my $ua = LWP::UserAgent->new();
    my $req = HTTP::Request->new(GET => $url);
    $req->authorization_basic($user, $pass);
    my $res = $ua->request($req);
#    if ($res->is_success) {
#       print $res->content, "\n";
#    } else {
#        print "ERROR.\n";
#        print $res->status_line, "\n";
#    }
    my $content = $res->content;
    # parse with HTML::TreeBuilder
    my $tree = HTML::TreeBuilder->new;
    my $html = $tree->parse($content);
    # collect a-tag
    my @items =  $tree->look_down('_tag', $tag);
    my @list;
    push(@list, $_->as_HTML) for @items;
    return \@list;
}


# laod csv from file
sub load_csv_from_file
{
  my $file = shift;
  my @rows;
  my $csv = Text::CSV->new ( { binary => 1 } )
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

  open my $fh, "<:encoding(utf8)", $file or die "$file: $!";
  while ( my $row = $csv->getline( $fh ) ) {
     push @rows, $row;
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  return @rows;
}

# IE8のフリをする
#my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";
