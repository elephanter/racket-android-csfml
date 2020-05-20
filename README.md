# racket-android-csfml

Experimental build racket + r-cade for android.

inspired with https://github.com/jeapostrophe/racket-android but completely rewritten

Used libraries:
* sfml - support android build
* csfml - used my own android build partially copied from sfml
* libffi - racket version of that library is too old and does not build for android.
* racket - build for android with my small fix in patchfile

Android application use activity from sfml to start racket in it's own thread.

