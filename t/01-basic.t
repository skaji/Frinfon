use v6;
use Test;
use Frinfon;
use Crust::Test;
use HTTP::Message::PSGI;

get  '/' => { $^c.render-text("get") };
post '/' => { $^c.render-text("post") };

test-psgi app, -> $cb {
    my $res;
    $res = $cb(HTTP::Request.new(GET => "/"));
    is $res.content, "get".encode;
    $res = $cb(HTTP::Request.new(HEAD => "/"));
    is $res.content, "get".encode;
    $res = $cb(HTTP::Request.new(POST => "/"));
    is $res.content, "post".encode;
    $res = $cb(HTTP::Request.new(PUT => "/"));
    is $res.code, 405;
};

done-testing;
