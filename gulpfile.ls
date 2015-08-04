require! \browserify
require! \fs
require! \gulp
require! \gulp-livescript
require! \gulp-nodemon
require! \gulp-uglify
require! \gulp-util
require! \gulp-streamify
require! \gulp-stylus
io = (require \socket.io)!
    ..listen 8001
{basename, dirname, extname} = require \path
source = require \vinyl-source-stream
require! \watchify

emit-with-delay = (event) ->
    set-timeout do 
        -> io.emit event
        200

create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< {debug: false}
    bundler.add entries
    bundler.transform \liveify
    watchify bundler

bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> console.log arguments
        .pipe source file
        .pipe gulp-streamify gulp-uglify!
        .pipe gulp.dest directory

# Example styles
gulp.task \build:example:styles, ->
    gulp.src <[./example/public/components/App.styl]>
    .pipe gulp-stylus!
    .pipe gulp.dest './example/public/components'
    .on \end, -> emit-with-delay \build-complete if !!io

gulp.task \watch:example:styles, -> 
    gulp.watch <[./example/public/components/*.styl ./src/*.styl]>, <[build:example:styles]>

# Example scripts
example-bundler = create-bundler \./example/public/components/App.ls
bundle-example = -> bundle example-bundler, {file: "App.js", directory: "./example/public/components/"}

gulp.task \build:example:scripts, ->
    bundle-example!

gulp.task \watch:example:scripts, ->
    example-bundler.on \update, -> 
        emit-with-delay \build-start if !!io
        bundle-example!
    example-bundler.on \time, (time) -> 
        emit-with-delay \build-complete if !!io
        gulp-util.log "App.js built in #{time} seconds"

# Example server
gulp.task \dev:server, ->
    gulp-nodemon do
        exec-map: ls: \lsc
        ext: \ls
        ignore: <[.gitignore gulpfile.ls *.sublime-project README.md]>
        script: \./example/server.ls

# Source
gulp.task \build:src:styles, ->
    gulp.src <[./src/AutoComplete.styl]>
    .pipe gulp-stylus!
    .pipe gulp.dest './src'

gulp.task \watch:src:styles, -> 
    gulp.watch <[./src/*.styl]>, <[build:src:styles]>    

gulp.task \build:src:scripts, ->
    gulp.src <[./src/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './src'

gulp.task \watch:src:scripts, ->
    gulp.watch <[./src/*.ls]>, <[build:src:scripts]>

gulp.task \build:src, <[build:src:styles build:src:scripts]>
gulp.task \watch:src, <[watch:src:styles watch:src:scripts]>
gulp.task \build:example, <[build:example:styles build:example:scripts]>
gulp.task \watch:example, <[watch:example:styles watch:example:scripts]>
gulp.task \default, <[build:src watch:src build:example watch:example dev:server]>