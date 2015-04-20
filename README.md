# SBCL Camp

## Development environment

    brew install sbcl
    rehash
    curl -O http://beta.quicklisp.org/quicklisp.lisp

Check that `oh-my-zsh` `sbt`-plugin is not installed, it aliases `sbcl` to `sbt clean`.

    sbcl --load quicklisp.lisp

In the REPL:

    (quicklisp-quickstart:install)
    (ql:add-to-init-file)

It installs quicklisp globally to `$(HOME)/.sbclrc` but we can live with that for now.

    (ql:quickload "quicklisp-slime-helper")

Add the helper in the output to your Emacs' `init.el`

Open a file, type `<esc-x> slime` and off you go!

## Docs

[http://quickdocs.org/](http://quickdocs.org/)

## Next

* [http://www.gigamonkeys.com/book/](http://www.gigamonkeys.com/book/)
* [https://delicious.com/hvrauhal/codecamp](https://delicious.com/hvrauhal/codecamp)
* [https://gist.github.com/shortsightedsid/a760e0d83a9557aaffcc](https://gist.github.com/shortsightedsid/a760e0d83a9557aaffcc)
* [https://sites.google.com/site/sabraonthehill/home/json-libraries](https://sites.google.com/site/sabraonthehill/home/json-libraries)
* [http://thehelpfulhacker.net/2011/07/10/checking-your-reddit-karma-with-common-lisp/](http://thehelpfulhacker.net/2011/07/10/checking-your-reddit-karma-with-common-lisp/)
