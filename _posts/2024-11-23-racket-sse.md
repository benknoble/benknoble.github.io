---
title: 'Server-sent events with Racket'
tags: [racket, frosthaven-manager, web]
category: [ Blog ]
---

A small amount of server-side Racket and client-side JavaScript give me a
passable version of a reactive front-end.

## Background

In my [talk for 14th RacketCon]({% link _workshops/14th-racket-con.md %}) I
mentioned that the Frosthaven Manager can spawn a web-server for my friends and
players to interact with the app on their mobile devices. I run the entire
program on my machine, so all the state is stored in-process in one place. Edits
in the desktop GUI are propagated to my players web pages live, and their
actions translate back to the GUI in turn.

There's no JavaScript framework on either the back-end or front-end. So how does
it all work?

There are 3 pieces to the puzzle:

1. The web-server does all the HTML generation: it embeds `fetch` calls in
   `onclick` handlers that send POST requests back to the server, which the
   server translates into actions the rest of the program knows how to handle
   (but which, as mentioned in the talk, are shunted back to the GUI execution
   loop rather than executed in the concurrent web-server handler threads). So
   while my players mostly _see_ the rendered HTML content returned by the
   servers primary route, it actually supports a limited kind of
   `URLSearchParams`-backed API. If you know what routes to hit, you could write
   your own client to trigger game events. I've done so with
   [`hurl`](https://hurl.dev) when playing with new features just to try it.
1. Because I'm using [GUI
   Easy](https://docs.racket-lang.org/gui-easy/index.html), all my game state is
   [_observable_](https://docs.racket-lang.org/gui-easy/index.html#%28part._.Observables%29).
   This gives me a simple hook to subscribe to all the changes in my game's
   state, [though it risks being too
   fine-grained](https://github.com/benknoble/frosthaven-manager/commit/7b8b4e7ed558454f373d296ca501c2fc3484776b)
   and I've been considering other options for generating notifications of
   game-level events. Whatever mechanism there is, the web-server knows when
   state has changed and it ought to propagate those changes to clients.
1. The client and server agree to a [server-sent
   event](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
   protocol: this does require JavaScript enabled on the client (as do the click
   handlers above). The protocol allows the server to retain a communication
   channel to the client, which the client can use to update its view.

This post focuses on the server-sent event implementation, or primarily the
latter 2 pieces.

**Note**: Rather than embed the full code in those post, I'm going to link to
the implementation as it was at time of writing. Follow the links to get the
full details.

## Server-sent events

> With server-sent events, it's possible for a server to send new data to a web
> page at any time, by pushing messages to the web page.
> ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events))

SSEs are one-way connections from server to client. Clients point a standard
JavaScript API `EventSource` at a URL that will produce a SSE-compatible
response and then attach event listeners. These listeners can operate over
[generic
events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#listening_for_message_events)
or [named
events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#listening_for_custom_events).
Messages can have [arbitrary data
fields](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#data)
which the client must parse to decide how to use.

The server implements SSEs by responding with the correct MIME type and raw
[response
format](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format).

### My SSE protocol for the Frosthaven Manager

Before we look at implementation details, let's get a grasp on the fundamentals
of the protocol my web-server uses atop SSEs.

- All events use JSON as the interchange format for `data` fields. Racket is
  capable of emitting standard JSON and JavaScript of parsing it, so this
  simplifies communication.
- Events that manipulate the DOM _should_ contain an HTML id pointing to the
  node to manipulate. This simplifies the client code for finding the right node
  and requires the server to consistently tag modifiable nodes with an
  identifier (`id` attribute).
- Events that manipulate the DOM _should_ contain strings that encode HTML that
  can replace the `innerHTML` as needed.

The last point is important: it avoids performing duplicate calculations in the
client (when a player's HP changes, we send the new number, not an event
requesting that the HP be incremented or decremented), which makes keeping the
state in sync more reliable.

The simplest events in my protocol are `number` and `text`: they send an id and
a number or string that should replace the named node's `innerHTML`. They
actually have nearly identical [client
implementations](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/static/events.js#L64-L73)
and [server
implementations](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L890-L899).

Other events are more complicated and outside the scope of this article. As an
example, the `player` event is triggered when a player object changes: ignoring
the summon data, it receives an HTML id, a mapping of sub-components to HTML
strings, and a complete HTML node. The complete node is used if the player
doesn't already exist, allowing it to be inserted wholesale into the display.
Otherwise, we update the sub-nodes based on the mapping of HTML strings. The
`monster-group` event is similar.

### Implementation Details

As we said earlier, the [client opens a new event
source](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/static/events.js#L1)
and attaches event handlers. We [include the script on the main
page](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L320).
Sending events is the server's responsibility.

```javascript
const evtSource = new EventSource("events");
evtSource.addEventListener("name", handler);
```

The server subscribes to the GUI observables[^1]: when they change, the subscribers
place structured data in a [multicast
channel](https://docs.racket-lang.org/alexis-multicast/index.html)
([example](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L181-L188)).
We need a multicast channel because we create one per server (usually just one),
but each client request handler needs to be able to be able to read from it
(usually one per event source connection).

```racket
(define ch (make-multicast-channel))
(obs-observe! @state
              (λ (state)
                (multicast-channel-put ch (state-event state))))
```

Then, the server [establishes a route which implements the
SSEs](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L254).
This is the same path that forms part of the URL that the client will connect
to. The route's implementation [responds with appropriate
headers](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L816-L825).
It also [gets an output
port](https://docs.racket-lang.org/web-server/http.html#%28def._%28%28lib._web-server%2Fhttp%2Fresponse-structs..rkt%29._response%2Foutput%29%29)
it can use to write to the client.

```racket
(define ((event-source ch) _req)
  (define receiver (make-multicast-receiver ch))
  (response/output
    #:headers (list (header #"Cache-Control" #"no-store")
                    (header #"Content-Type" #"text/event-stream")
                    ;; Don't use Connection in HTTP/2 or HTTP/3, but Racket's
                    ;; web-server is HTTP/1.1 as confirmed by
                    ;; `curl -vso /dev/null --http2 <addr>`.
                    (header #"Connection" #"keep-alive")
                    ;; Pairs with Connection; since our event source sends data
                    ;; every 5 seconds at minimum, this 10s timeout should be
                    ;; sufficient.
                    (header #"Keep-Alive" #"timeout=10"))
    (sse-output receiver)))
```

The main loop of the response handler is to wait on the channel to produce data:
when it does, [a separate
function](https://github.com/benknoble/frosthaven-manager/blob/4fb7ad6d36890478a078ce5efc97fe06cd6c1520/server.rkt#L833)
transforms that data into SSE format and shoves it through the port. If we don't
get a response in time, we send a [comment to prevent connection
timeout](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format).

```racket
(define (see-output receiver)
  (λ (out)
    (let loop ()
      (cond
        [(sync/timeout 5 receiver) => (event-stream out)]
        [else (displayln ":" out)])
      (loop))))
```

That's all there is to it! I'm hoping to find a way to extract the two pieces
(client-side code and server-side implementation) into a library for other
Racket applications to use to implement server-side events more easily. Ideally
it will handle the basics of SSEs while remaining agnostic to how the
application generates and handles events. We _might_ be able to be
concurrency-agnostic, though: while Racket's `sync` is generic, most
applications probably need a single-producer multi-consumer channel. Still,
allowing any event that produces data a consumer can transform into SSE-data
might work and allow other patterns.

## Notes

[^1]: For performance reasons, some subscribers spawn a thread that sends the
    message. Since GUI Easy subscribers execute serially, moving expensive work
    out of the main loop quickly can help avoid bottlenecks.
