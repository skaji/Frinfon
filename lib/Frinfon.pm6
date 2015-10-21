use v6;
class Frinfon does Callable {
    use Router::Boost::Method;
    use Crust::Request;
    need Data::Section::Simple;

    has Router::Boost::Method $.router = Router::Boost::Method.new;
    has Hash $.template-file;

    my class Frinfon::Controller {
        use Crust::Response;
        use Template::Mojo;
        has $.request;
        has $.captured;
        has Hash $.template-file;
        method req() { $!request }
        method create-response(Int $status = 200) {
            Crust::Response.new(status => $status, headers => [], body => []);
        }
        method render-json($arg) {
            my $body = to-json($arg).encode;
            my $len  = $body.elems;
            Crust::Response.new(
                status => 200,
                headers => ['Content-Type' => 'application/json; charset=utf-8', 'Content-Length' => $len],
                body => [$body]
            );
        }
        method render-text(Str $text) {
            my $body = $text.encode;
            my $len  = $body.elems;
            Crust::Response.new(
                status => 200,
                headers => ['Content-Type' => 'text/plain; charset=utf-8', 'Content-Length' => $len],
                body => [$body]
            );
        }
        method render(Str $name, *@arg) {
            my $template-file = $!template-file{$name};
            die "Cannot find template file '$name'" unless $template-file;
            my $t = Template::Mojo.new($template-file);
            my $html = $t.render(|@arg).encode('utf-8');
            my $len = $html.elems;
            my $res = self.create-response;
            $res.headers.push( 'Content-Type' => 'text/html; charset=utf-8' );
            $res.headers.push( 'Content-Length' => $len );
            $res.body.push($html);
            $res;
        }
    }

    method CALL-ME(%env) {
        my $dest = self.router.match(%env<REQUEST_METHOD>, %env<PATH_INFO>);
        if !$dest {
            return 404, [], ["Not Found\n"];
        } elsif $dest<is-method-not-allowed> {
            return 405, [], ["Method Not Allowed\n"];
        } else {
            my $c = Frinfon::Controller.new(
                request => Crust::Request.new(%env),
                captured => $dest<captured>,
                template-file => $!template-file,
            );
            my $handler = $dest<stuff>;
            my $res = $handler($c);
            return $res.finalize;
        }
        CATCH {
            default {
                note $_;
                return 500, [], ["Internal Server Error\n"];
            }
        }
    }
    method !init() {
        return if $!template-file;
        if CALLER::CALLER::CALLER::UNIT::<$=finish> -> $content {
            $!template-file = Data::Section::Simple.get-data-section(:$content);
        } else {
            $!template-file = {};
        }
    }

    method get(Pair $p) {
        self!init;
        $!router.add([<GET HEAD>], $p.key, $p.value);
    }
    method post(Pair $p) {
        self!init;
        $!router.add([<POST>], $p.key, $p.value);
    }
    method delete(Pair $p) {
        self!init;
        $!router.add([<DELETE>], $p.key, $p.value);
    }
    method put(Pair $p) {
        self!init;
        $!router.add([<PUT>], $p.key, $p.value);
    }
    method any-method(Pair $p) {
        self!init;
        $!router.add([<GET HEAD POST DELETE PUT>], $p.key, $p.value);
    }

    method start-server(*@args) {
        require Crust::Runner;
        my $r = ::("Crust::Runner").new;
        $r.parse-options(@args);
        $r.run(self);
    }
    method start() {
        if %*ENV<P6SGI_CONTAINER> { # in crustup
            self;
        } else {
            self.start-server(@*ARGS);
        }
    }
}

sub EXPORT {
    my $frinfon = Frinfon.new;
    {
        '&get'        => sub (Pair $p) { $frinfon.get($p) },
        '&post'       => sub (Pair $p) { $frinfon.post($p) },
        '&delete'     => sub (Pair $p) { $frinfon.delete($p) },
        '&put'        => sub (Pair $p) { $frinfon.put($p) },
        '&any-method' => sub (Pair $p) { $frinfon.any-method($p) },
        'app'         => $frinfon,
    }
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

  app;

  # terminal
  > crustup app.psgi

=head1 DESCRIPTION

Frinfon is a minimal sinatra, a well-known ruby web application framework.
You may write a simple web application with Frinfon quickly.

More useful sinatra (or Kossy?) coming soon!

=head1 PROBLEMS

I thought perl6 did not have perl5's C<import> method.
B<It's wrong! perl6 has EXPORT subroutine!>

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
