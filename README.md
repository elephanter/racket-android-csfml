# racket-android-csfml

Experimental build racket + r-cade for android.

inspired with https://github.com/jeapostrophe/racket-android but completely rewritten

Used libraries:
* sfml - support android build
* csfml - used my own android build partially copied from sfml
* libffi - racket version of that library is too old and does not build for android.
* racket - build for android with my small fix in patchfile

Android application use activity from sfml to start racket in it's own thread.

There is some little issue: csfml and sfml builded in debug. All library files has -d letter at the end. but racket csfml library loads .so files with names without '-d'. So I manually fix names for .so files in racket csfml library.
