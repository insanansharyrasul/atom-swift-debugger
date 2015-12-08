{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class SwiftDebuggerView extends View
  @content: ->
    @div class: 'swiftDebuggerView', =>
      @subview 'commandEntryView', new TextEditorView
        mini: true,
        placeholderText: 'po foo'
      @button outlet: 'runBtn', click: 'runApp', class: 'btn', =>
        @span 'run'
      @button outlet: 'cleatBtn', click: 'clearOutput', class: 'btn', =>
        @span 'clear'
      @button outlet: 'stepOver', click: 'stepOverBtnPressed', class: 'btn', =>
        @span 'next line'
      @button outlet: 'resume', click: 'resumeBtnPressed', class: 'btn', =>
        @span 'resume'
      @div class: 'panel-body', outlet: 'outputContainer', =>
        @pre class: 'command-output', outlet: 'output'

  runApp: ->
    @addOutput("Trying to build app...")

  clearOutput: ->
    @output.empty()

  createOutputNode: (text) ->
    node = $('<span />').text(text)
    parent = $('<span />').append(node)

  addOutput: (data) ->
    atBottom = @atBottomOfOutput()
    node = @createOutputNode(data)
    @output.append(node)
    @output.append("\n")
    if atBottom
      @scrollToBottomOfOutput()

  initialize: (lldb) ->
    console.log "initialized lldb? " + lldb
    @lldb = lldb
    @addOutput("Welcome to Swift Debugger")
    @subscriptions = atom.commands.add @element,
      'core:confirm': (event) =>
        @confirmLLDBCommand()
        event.stopPropagation()
      'core:cancel': (event) =>
        @cancelLLDBCommand()
        event.stopPropagation()

  stringIsBlank: (str) ->
    !str or /^\s*$/.test str

  getCommand: ->
    command = @commandEntryView.getModel().getText()
    if(!@stringIsBlank(command))
      command

  cancelLLDBCommand: ->
    @commandEntryView.getModel().setText("")

  confirmLLDBCommand: ->
    command = @getCommand()
    if(command)
      command = @getCommand()
      @lldb.stdin.write(command + "\n")
      # @addOutput(command)
    @commandEntryView.getModel().setText("")

  serialize: ->
    attached: @panel?.isVisible()

  destroy: ->
    @detach()

  toggle: ->
    if @panel?.isVisible()
      @detach()
    else
      @attach()

  atBottomOfOutput: ->
    @output[0].scrollHeight <= @output.scrollTop() + @output.outerHeight()

  scrollToBottomOfOutput: ->
    @output.scrollToBottom()

  attach: ->
    console.log "attach called"
    @panel = atom.workspace.addBottomPanel(item: this)
    @panel.show()
    @scrollToBottomOfOutput()

  detach: ->
    console.log "detach"
    @panel.destroy()
    @panel = null
