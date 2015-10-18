use v6;
unit class Frinfon;
use Router::Boost::Method;
use Crust::Request;

has Router::Boost::Method $.router = Router::Boost::Method.new;
has @.static;

my $SELF = Frinfon.new;

my class Frinfon::Controller {
    use Crust::Response;
    has $.request;
    has $.captured;
    method req() { $!request }
    method create-response(Int $status = 200) {
        Crust::Response.new(status => $status, headers => []);
    }
    method render-json($arg) {
        my $body = to-json $arg;
        Crust::Response.new(status => 200, headers => [], body => [$body.encode]);
    }
    method render-text(Str $text) {
        Crust::Response.new(status => 200, headers => [], body => [$text.encode]);
    }
}
sub static(*@root) is export {
    $SELF.static.append(@root);
}

method to-app() {
    # TODO Crust::Middleware::Static
    sub (%env) {
        my $dest = self.router.match(%env<REQUEST_METHOD>, %env<PATH_INFO>);
        if !$dest {
            return 404, [], ["Not Found\n"];
        } elsif $dest<is-method-not-allowed> {
            return 405, [], ["Method Not Allowed\n"];
        } else {
            my $c = Frinfon::Controller.new(
                request => Crust::Request.new(%env),
                captured => $dest<captured>,
            );
            my $handler = $dest<stuff>;
            my $res = $handler($c);
            return $res.finalize;
        }
        CATCH {
            default {
                warn $_;
                return 500, [], ["Internal Server Error\n"];
            }
        }
    }
}
method start() { self.to-app }

multi get(Pair $p) is export { get(|$p.kv) }
multi post(Pair $p) is export { post(|$p.kv) }
multi delete(Pair $p) is export { delete(|$p.kv) }
multi put(Pair $p) is export { put(|$p.kv) }

multi get(Str $pattern, Callable $handler) is export {
    $SELF.router.add([<GET HEAD>], $pattern, $handler);
}
multi post(Str $pattern, Callable $handler) is export {
    $SELF.router.add([<POST>], $pattern, $handler);
}
multi delete(Str $pattern, Callable $handler) is export {
    $SELF.router.add([<DELETE>], $pattern, $handler);
}
multi put(Str $pattern, Callable $handler) is export {
    $SELF.router.add([<PUT>], $pattern, $handler);
}
multi any-method(Str $pattern, Callable $handler) is export {
    $SELF.router.add([<GET HEAD POST DELETE PUT>], $pattern, $handler);
}
sub app() is export {
    $SELF;
}

=begin pod

=head1 NAME

Frinfon - minimal sinatra

=head1 SYNOPSIS

  # app.psgi
  use Frinfon;

  get '/' => sub ($c) {
      $c.render-text("hello world\n");
  };

  get '/:user' => sub ($c) {
      my $user = $c.captured<user>;
      $c.render-json: { message => "hello $user!" };
  };

  app.start;

  # terminal
  > crustup app.psgi

=head1 DESCRIPTION

Frinfon is a minimal sinatra.
More useful sinatra (or Kossy?) coming soon!

Then this module is going to be deprecated.

=head1 PROBLEMS

As far as I know, perl6 does not have C< import > method of perl5.
So we cannot create a B<context> object for each C<app.psgi>.
What can we do?

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
