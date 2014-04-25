gulp = require('gulp')
nodemon = require('gulp-nodemon')

gulp.task 'develop', ->
  nodemon({script: './bin/www', ext: 'jade coffee'})
    .on 'restart', ->
      console.log('restarted!')
