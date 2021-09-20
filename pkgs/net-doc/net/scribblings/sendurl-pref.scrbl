#lang scribble/doc
@(require "common.rkt"
          (for-label racket/file racket/contract
                     net/sendurl net/sendurl/preferences))

@title{Preference Configuration}

@defmodule[net/sendurl/preferences]{Provides @tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{parameters}
that configure the external browser and the how @racket[send-url] delivers the URL.

@history[#:added "1.1"]}

@defparam[external-browser cmd browser-preference?]{

A parameter that can hold a procedure to override how a browser is
started, or @racket[#f] to use the default platform-dependent command.

On Unix, the command that is used depends on the @racket[browser-preference-key]
preference.  It's recommended not to use this preference, but to rely on
@tt{xdg-open}.  If the preference is unset, @racket[send-url] uses the first
of the browsers from @racket[browser-list] for which the executable is
found.  Otherwise, the preference should hold a symbol indicating a known
browser (from the @racket[browser-list]), or it a pair of a prefix and
a suffix string that are concatenated around the @racket[url] string to make
up a shell command to run.  In addition, the @racket[external-browser]
paremeter can be set to one of these values, and @racket[send-url] will use
it instead of the preference value.

Note that the URL is encoded to make it work inside shell double-quotes:
URLs can still hold characters like @litchar{#}, @litchar{?}, and
@litchar{&}, so if the @racket[external-browser] is set to a pair of
prefix/suffix strings, they should use double quotes around the url.

If the preferred or default browser can't be launched,
@racket[send-url] fails. See @racket[get-preference] and
@racket[put-preferences] for details on setting preferences.



@history[#:changed "1.1" @elem{Moved to @racketmodname[net/sendurl/preferences].
           Re-provided from @racketmodname[net/sendurl] for backwards compatibility.}]}

@defthing[browser-preference-key symbol?]{

The name of the entry specifying the external browser in the preference file.
Equals @racket['external-browser].

@history[#:added "1.1"]}

@defproc[(available-external-browser)
         browser-preference?]{

Returns @racket[#f] if there are no available external browsers.

@history[#:added "1.1"]}

@defparam[external-browser-trampoline on (or/c #f #t 'dont-care)]{

@history[#:added "1.1"]}

@defthing[trampoline-preference-key symbol?]{

The name of the entry specifying whether @racket[send-url] should avoid
page anchors and query strings in the preference file.

@history[#:added "1.1"]}

@defproc[(external-browser-allow-trampoline?)
         boolean?]{

Returns whether @racket[send-url] should avoid page anchors and query
strings when delivering the URL to the browser.

@history[#:added "1.1"]}

@defproc[(browser-preference? [a any/c]) boolean?]{

Returns @racket[#t] if @racket[v] is a valid browser preference,
@racket[#f] otherwise. See @racket[external-browser] for more
information.

@history[#:changed "1.1" @elem{Moved to @racketmodname[net/sendurl/preferences].
           Re-provided from @racketmodname[net/sendurl] for backwards compatibility.}]}

@deftogether[(@defthing[browser-list (listof symbol?)]
              @defthing[unix-browser-list (listof symbol?)])]{

A list of symbols representing Unix executable names that may be tried
in order by @racket[send-url]. The @racket[send-url] function
internally includes information on how to launch each executable with
a URL.

@racket[unix-browser-list] is an alias of @racket[browser-list].

@history[#:changed "1.1" @elem{Moved to @racketmodname[net/sendurl/preferences].
           Re-provided from @racketmodname[net/sendurl] for backwards compatibility.}]}
