[![Build Status](https://travis-ci.org/shoichikaji/Frinfon.svg?branch=master)](https://travis-ci.org/shoichikaji/Frinfon)

NAME
====

Frinfon - minimal sinatra

SYNOPSIS
========

    # app.psgi
    use Frinfon;

    get '/' => sub ($c) {
        $c.render-text("hello world\n");
    };

    get '/:user' => sub ($c) {
        my $user = $c.captured<user>;
        $c.render-json: { message => "hello $user!" };
    };

    app;

    # terminal
    > crustup app.psgi

DESCRIPTION
===========

Frinfon is a minimal sinatra, a well-known ruby web application framework. You may write a simple web application with Frinfon quickly.

More useful sinatra (or Kossy?) coming soon!

PROBLEMS
========

I thought perl6 did not have perl5's `import` method. **It's wrong! perl6 has EXPORT subroutine!**

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
