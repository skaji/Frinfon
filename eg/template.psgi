use v6;
use lib "lib", "../lib";
use Frinfon;

get '/' => { $^c.render-text("access /your-name\n") };

get '/:user' => sub ($c) {
    $c.render('index.tt', { user => $c.captured<user> });
};

get '/eg/eg' => { $^c.render('eg.tt') };

app;

=finish

@@ index.tt
% my %arg = @_;
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Frinfon</title>
</head>
<body>
  <p>Hello, <%= %arg<user> %></p>
</body>
</html>

@@ eg.tt
% my %arg = @_;
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Frinfon eg</title>
</head>
<body>
  <p>eg</p>
</body>
</html>
