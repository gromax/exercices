//Gruntfile
module.exports = function(grunt) {

  //Initializing the configuration object
  grunt.initConfig({
    // Task configuration
    less: {
      development: {
          options: {
             compress: false,  // no minification in dev
             },
          files: {
             //compiling base.less into styles.css
             "dist/styles.css":"app/styles/base.less"
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
          'dist/exercices.hbs': 'app/templates/exercices/*.handlebars',
          'dist/manager.hbs': 'app/templates/manager/*.handlebars'
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
          'dist/exercices.js': ['app/coffee/exercices/exercice.coffee', 'app/coffee/exercices/briques.coffee', 'app/coffee/exercices/aide.coffee', 'app/coffee/exercices/gestClavier.coffee', 'app/coffee/exercices/exo__*.coffee'],
          'dist/manager.js': 'app/coffee/manager/*.coffee',
          'dist/math.js': 'app/coffee/math/*.coffee'
        }
      }
    },
    watch: {
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
            files: [ 'app/coffee/exercices/*.coffee', 'app/coffee/manager/*.coffee', 'app/coffee/math/*.coffee'],
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
  //grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  // Task definition
  grunt.registerTask('default', ['watch']);
};