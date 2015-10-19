#!/usr/bin/env perl6
use v6;

my $app1 = do {
    use Frinfon;
    get '/' => { $^c.render-text("app1") };
    app;
};

my $app2 = do {
    use Frinfon;
    get '/' => { $^c.render-text("app2") };
    app;
};

use Crust::Builder;

builder {
    mount '/app1', $app1;
    mount '/app2', $app2;
};
