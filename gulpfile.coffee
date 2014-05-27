gulp = require('gulp')
nodemon = require('gulp-nodemon')
config = require('config')

gulp.task 'develop', ->
  nodemon({
    script: './bin/www'
    ext: 'jade coffee'
    ignore: ['**/node_modules/*', '**./git/*', config.extensions.root]
  })
    .on 'restart', ->
      console.log('restarted!')
