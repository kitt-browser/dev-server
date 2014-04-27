Initializers
============
This is where your code you want run before the server starts goes. Each
initializer is expected to export a function that takes a single argument which
is the `app` object. If the initializer is asynchronous, please return a
promise for completion (otherwise the server wouldn't know to wait).
