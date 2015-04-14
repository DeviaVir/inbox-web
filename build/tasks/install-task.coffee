path = require 'path'
_ = require 'underscore-plus'
fs = require 'fs-plus'
runas = null
temp = require 'temp'

module.exports = (grunt) ->
  {cp, mkdir, rm} = require('./task-helpers')(grunt)

  grunt.registerTask 'install', 'Install the built application', ->
    installDir = grunt.config.get('atom.installDir')
    shellAppDir = grunt.config.get('atom.shellAppDir')

    if process.platform is 'win32'
      runas ?= require 'runas'
      copyFolder = path.resolve 'script', 'copy-folder.cmd'
      if runas('cmd', ['/c', copyFolder, shellAppDir, installDir], admin: true) isnt 0
        grunt.log.error("Failed to copy #{shellAppDir} to #{installDir}")

      createShortcut = path.resolve 'script', 'create-shortcut.cmd'
      runas('cmd', ['/c', createShortcut, path.join(installDir, 'inbox.exe'), 'Inbox'])
    else if process.platform is 'darwin'
      rm installDir
      mkdir path.dirname(installDir)

      tempFolder = temp.path()
      mkdir tempFolder
      cp shellAppDir, tempFolder
      fs.renameSync(tempFolder, installDir)
