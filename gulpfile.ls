browserify = require \browserify
fs = require \fs
gulp = require \gulp
gulp-connect = require \gulp-connect
gulp-livescript = require \gulp-livescript
gulp-util = require \gulp-util
stylus = require \gulp-stylus
{basename, dirname, extname} = require \path
source = require \vinyl-source-stream
watchify = require \watchify

create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< {debug: true}
    bundler.add entries
    bundler.transform \liveify
    watchify bundler

bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> console.log arguments
        .pipe source file
        .pipe gulp.dest directory
        .pipe gulp-connect.reload!

##
# Example
##
gulp.task \build:example:styles, ->
    gulp.src <[./example/src/App.styl]>
    .pipe stylus!
    .pipe gulp.dest './example/dist'
    .pipe gulp-connect.reload!

gulp.task \watch:example:styles, -> 
    gulp.watch <[./example/src/*.styl ./src/*.styl]>, <[build:example:styles]>    

example-bundler = create-bundler \./example/src/App.ls
bundle-example = -> bundle example-bundler, {file: "App.js", directory: "./example/dist/"}

gulp.task \build:example:scripts, ->
    bundle-example!

gulp.task \watch:example:scripts, ->
    example-bundler.on \update, -> bundle-example!
    example-bundler.on \time, (time) -> gulp-util.log "App.js built in #{time} seconds"

gulp.task \dev:server, ->
    gulp-connect.server do
        livereload: true
        port: 8000
        root: \./example/

##
# Source
##
gulp.task \build:src:styles, ->
    gulp.src <[./src/AutoComplete.styl]>
    .pipe stylus!
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