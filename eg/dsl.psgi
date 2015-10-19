#!/usr/bin/env perl6
use v6;
use lib "lib", "../lib";
use Frinfon;

get '/' => sub ($c) {
    $c.render-text("hello world\n");
};

get '/:user' => sub ($c) {
    my $user = $c.captured<user>;
    $c.render-json: { message => "hello $user!" };
};

app;
