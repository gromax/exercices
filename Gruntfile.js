//Gruntfile
module.exports = function(grunt) {

  //Initializing the configuration object
  grunt.initConfig({
    // Task configuration
    uglify: {
      main: {
        files: {
          'dist/main.min.js': 'dist/main.js',
        }
      }
    },
    concat: {
      js: {
        src: ['app/scripts/functions.js','dist/math.js','dist/exercices.js','dist/manager.js', 'dist/templates.hbs.js'],
        dest: 'dist/main.js'
      },
      js_local: {
        src: ['app/scripts/localConstantes.js','app/scripts/functions.js','dist/math.js','dist/exercices.js','dist/manager.js', 'dist/templates.hbs.js'],
        dest: 'dist/main.local.js'
      }
    },
    less: {
      development: {
          options: {
             compress: false,  // no minification in dev
             },
          files: {
             //compiling base.less into styles.css
             "app/styles/styles.css":"app/styles/base.less"
             }
          },
      production: {
          options: {
             cleancss: true, // minify css
             // compress: true, // minify css
          },
          files: {
             //compiling base.less into main.min.css
             "dist/styles.min.css": "app/styles/base.less"
          }
      }
    },
    cssmin: {
      minify:{
        files: {
          'dist/styles.min.css': ['app/styles/styles.css']
        }
      }
    },
    handlebars: {
      compile: {
        options: {
          namespace: 'Handlebars.templates',
            processName: function(filePath) {
              return filePath.split('\\').pop().split('/').pop().split('.').shift();
            }
        },
        compilerOptions: {
          knownHelpers: {
            'selected': true,
            'colorListItem': true
          },
          knownHelpersOnly: true
        },
        files: {
          'dist/templates.hbs.js' : ['app/templates/exercices/*.handlebars', 'app/templates/manager/*.handlebars', 'app/templates/slide/*.handlebars', 'app/templates/tex/*.handlebars'],
        }
      }
    },
    coffee: {
      development: {
        options: {
          bare:false,
          join:true
        },
        files: {
          'dist/exercices.js': ['app/coffee/exercices/exercice.coffee','app/coffee/exercices/briques.coffee','app/coffee/exercices/aide.coffee','app/coffee/exercices/gestClavier.coffee','app/coffee/exercices/exo__*.coffee'],
          'dist/manager.js': 'app/coffee/manager/*.coffee',
          'dist/math.js': 'app/coffee/math/*.coffee'
        }
      }
    },
    watch: {
        less: {
            // Watch all .lesshandlebars files from styles
            files: ['app/styles/*.less'],
            tasks: ['less'],
            // Reloads the browser
            options: {
              livereload: true
            }
        },
        handlebars: {
            // Watch all .handlebars files from the handlebars directory)
            files: ['app/templates/exercices/*.handlebars', 'app/templates/manager/*.handlebars'],
            tasks: ['handlebars'],
            // Reloads the browser
            options: {
              livereload: true
            }
        },
        coffee: {
            // Watch only main.js so that we do not constantly recompile the .js files
            files: [ 'dev/exercices/coffee/*.coffee', 'dev/manager/coffee/*.coffee', 'dev/math/*.coffee'],
            tasks: [ 'coffee' ],
            // Reloads the browser
            options: {
              livereload: true
            }
        }
    }
  });

  // Plugin loading
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  // Task definition
  grunt.registerTask('default', ['watch']);
};
