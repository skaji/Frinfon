#!/usr/bin/env perl6
use v6;
use lib "lib", "../lib";
need Frinfon;

my $frinfon = Frinfon.new;
$frinfon.get: "/" => { $^c.render-text("hello world\n") };
$frinfon.get: "/:user" => { $^c.render-json({message => "hello {$c.captured<user>}"}) };
$frinfon;
