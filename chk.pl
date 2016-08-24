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
  my $url = shift($line);
  my $tags = &find_tag_from_content($line->[0], $tag); # htmlをparseして指定タグをリストで返す;
#  warn Dumper "[$url]";

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


#  my @list = &find_tag_from_content($line->[0], $tag); # htmlをparseして指定タグをリストで返す
#  warn Dumper @list;
#  foreach my $a ($line)
#  {
#    warn Dumper $a;
#  }
}

sub find_tag_from_content
{
#    my $url = $_[0];
my $url = 'http://example.com';
    my $tag = $_[1];
    # get content
    my $ua = LWP::UserAgent->new();
    my $res = $ua->get($url);
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

# urlを指定する
#my $url = 'http://qiita.com/m2t9/items/11aea3d8e6ebbeef88c9#%E8%A3%9C%E8%B6%B3';
my $url = 'http://example.com';

# IE8のフリをする
#my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";

# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
my $ua = LWP::UserAgent->new();
my $res = $ua->get($url);
my $content = $res->content;

# HTML::TreeBuilderで解析する
my $tree = HTML::TreeBuilder->new;
my $html = $tree->parse($content);

# aタグを全部抽出
my @items =  $tree->look_down('_tag', 'a');
my @list;
push(@list, $_->as_HTML) for @items;
#

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

