# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.

nxcStatus = 0

updateStatus = (item) ->
  document.querySelector(".nxc-error")?.remove()

  buffer = item.buffer
  if buffer?
    fileNameParts = buffer.file.path.split(".")
    if fileNameParts[fileNameParts.length-1] == "nxc" && fileNameParts.length > 1
      console.log 'We are working on an nxc file!'
      if nxcStatus == -1
        document.querySelector('.status-bar-left').innerHTML = '<div class="nxc-error inline-block">upload failed!</div>' + document.querySelector('.status-bar-left').innerHTML;
      return;

atom.workspace.observeActivePaneItem updateStatus

atom.commands.add 'atom-text-editor', 'nxc:compile', ->

  activeItem = atom.workspace.getActivePaneItem()

  # save the file
  activeItem.buffer.save()

  # this will run `nxc /path/to/file.nxc`
  command = 'nxc '+activeItem.buffer.file.path

  # exec the command
  require('child_process').exec command, (error, stdout, stderr) ->
    # remove error panel, if there is any.
    document.querySelector(".terminal-output")?.remove()

    # do we have an error?
    if error?
      nxcStatus = -1
      updateStatus(activeItem)
      if stderr != ""
        # create an error panel.
        document.querySelector('atom-panel-container.bottom').innerHTML =
          '<atom-panel class="terminal-output">'+stderr.split("\n").join("<br>") +
          '</atom-panel>' +
          document.querySelector('atom-panel-container.bottom').innerHTML
    else
      nxcStatus = 0
