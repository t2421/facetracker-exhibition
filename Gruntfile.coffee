module.exports = (grunt) ->

  grunt.initConfig

    browserify:
      'dist/bundle.js': ['src/main.coffee']
      options:
        transform: ['coffee-reactify']
        debug: false
        shim:
          Stats:
            path: 'src/libs/stats.min.js'
            exports: 'Stats'
          datgui:
            path: 'src/libs/dat.gui.js'
            exports: 'dat'
    coffee:
      options:
        bare: true
        sourceMap: false

    watch:
      html:
        files: ['dist/*']
        options:
          livereload: true
      scripts:
        files: ['src/**/*.coffee']
        tasks: ['browserify', 'coffee']
    connect:
      server:
        options:
          base: 'dist'

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.registerTask('default', ['connect', 'browserify', 'coffee', 'watch'])
