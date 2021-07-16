# Session handling with Firestore

* A short App Engine app, which uses [Firestore](https://cloud.google.com/firestore/) to serve a webpage saying `"#{session['views']} views for #{session['greeting']}"`. Here, `session["greeting"]` is one of `["Hello World", "Hallo Welt", "Ciao Mondo", "Salut le Monde", "Hola Mundo"]` which has been randomly assigned to the viewer, and `session["views"]` is the number of times that viewer has loaded the page.
* To run, follow Ruby's [Handling sessions with Cloud Firestore](https://cloud.google.com/ruby/getting-started/session-handling-with-firestore) tutorial.

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)
