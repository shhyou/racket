#lang scribble/doc
@(require "common.rkt" (for-label net/sendurl))

@title[#:tag "sendurl"]{Send URL: Opening a Web Browser}

@defmodule[net/sendurl]{Provides @racket[send-url] for opening a URL
in the user's chosen web browser.}

See also @racketmodname[browser/external #:indirect], which requires
@racket[racket/gui], but can prompt the user for a browser if no
browser preference is set.


@defproc[(send-url [str string?] [separate-window? any/c #t]
                   [#:escape? escape? any/c #t])
         void?]{

Opens @racket[str], which represents a URL, in a platform-specific
manner. For some platforms and configurations, the
@racket[separate-window?] parameter determines if the browser creates
a new window to display the URL or not.

On Mac OS, @racket[send-url] calls @racket[send-url/mac].

If @racket[escape?] is true, then @racket[str] is escaped (by UTF-8
encoding followed by ``%'' encoding) to avoid dangerous shell
characters: single quotes, double quotes, backquotes, dollar signs,
backslashes, non-ASCII characters, and non-graphic characters. Note
that escaping does not affect already-encoded characters in
@racket[str].

On all platforms, the @racket[external-browser] parameter can be set to a
procedure to override the above behavior, and the procedure will be
called with the URL @racket[str].}

@defproc[(send-url/file [path path-string?] [separate-window? any/c #t]
                        [#:fragment fragment (or/c string? false/c) #f]
                        [#:query query (or/c string? false/c) #f])
         void?]{

Similar to @racket[send-url] (with @racket[#:escape? #t]), but accepts
a path to a file to be displayed by the browser, along with optional
@racket[fragment] (with no leading @litchar{#}) and @racket[query]
(with no leading @litchar{?}) strings.  Use @racket[send-url/file] to
display a local file, since it takes care of the peculiarities of
constructing the correct @litchar{file://} URL.

The @racket[path], @racket[fragment], and @racket[query] arguments are
all encoded in the same way as a path provided to @racket[send-url],
which means that already-encoded characters are used as-is.}

@defproc[(send-url/contents [contents string?] [separate-window? any/c #t]
                            [#:fragment fragment (or/c string? false/c) #f]
                            [#:query query (or/c string? false/c) #f]
                            [#:delete-at seconds (or/c number? false/c) #f])
         void?]{

Similar to @racket[send-url/file], but it consumes the contents of a
page to show and displays it from a temporary file.

When @racket[send-url/content] is called, it scans old generated files
(this happens randomly, not on every call) and removes them to avoid
cluttering the temporary directory.  If the @racket[#:delete-at]
argument is a number, then the temporary file is more eagerly removed
after the specified number of seconds; the deletion happens in a
thread, so if Racket exits earlier, the deletion will not happen.  If
the @racket[#:delete-at] argument is @racket[#f], no eager deletion
happens, but old temporary files are still deleted as described
above.}

@defproc[(send-url/mac [url string?]
                       [#:browser browser (or/c string? #f) #f])
         void?]{
 Like @racket[send-url], but only for use on a Mac OS machine.

 The optional @racket[browser] argument, if present, should be the name
 of a browser installed on the system. For example,
 @racketblock[(send-url/mac "https://www.google.com/" #:browser "Firefox")]
 would open the url in Firefox, even if that's not the default browser.
 Passing @racket[#f] means to use the default browser.
}

@include-section["sendurl-pref.scrbl"]
