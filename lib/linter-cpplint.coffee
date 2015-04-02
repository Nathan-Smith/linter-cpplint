{CompositeDisposable} = require 'atom'
linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
path = require 'path'

class LinterCpplint extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: ['source.cpp']

  linterName: 'cpplint'

  # A regex pattern used to extract information from the executable's output.
  regex: '.+:(?<line>\\d+):\\s+(?<message>.*).+\\[\\d\\]$'
  regexFlags: 'm'

  defaultLevel: 'warning'

  isNodeExecutable: no

  errorStream: 'stderr'

  constructor: (editor) ->
    super(editor)

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.config.observe 'linter-cpplint.cpplintExecutablePath', =>
      @executablePath = atom.config.get 'linter-cpplint.cpplintExecutablePath'

    @subscriptions.add atom.config.observe 'linter-cpplint.filters', =>
      @updateCommand()

    @subscriptions.add atom.config.observe 'linter-cpplint.extensions', =>
      @updateCommand()

  updateCommand: ->
    filters = atom.config.get 'linter-cpplint.filters'
    extensions = atom.config.get 'linter-cpplint.extensions'
    cmd = "cpplint.py"
    if filters
      cmd = "#{cmd} --filter=#{filters}"
    if extensions
      cmd = "#{cmd} --extensions=#{extensions}"
    @cmd = cmd


  destroy: ->
    @subscriptions.dispose()

  # Private: cpplint outputs line 0 for some errors. This needs to be changed to
  # line 1 otherwise it will break.
  createMessage: (match) ->
    match.line = if match.line > 0 then match.line else 1
    return super match

module.exports = LinterCpplint
