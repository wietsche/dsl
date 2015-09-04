use Mojolicious::Lite;
use Lib::RE;

get '/' => sub {
  my $c = shift;
  my $code = "Enter code here....";
  $c->stash(html_code => $code);
  my $pc = "";
  $c->stash(html_parsed => $pc);
  $c->render(template => 'form');
    };

post '/' => sub {
  my $c = shift;
  my $code = $c->param('code_text');
  my $node = $c->param('node');

  $c->stash(html_code => $code);
  my $pc = RE::query($code,$node);
  $c->stash(html_parsed => $pc);
  $c->render(template => 'form');
    };

app->start;
