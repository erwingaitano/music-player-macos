- fix the sidebar items
  - when u click on all songs/playlists it should only show and not play them
- do the imageTransition

# TODO
- fix the sidebar items
- should load playlists/songs when launching app so that it doesnt depend on the server
- should add a sync button
- the app should remember its last status whenever it launches:
  - playlist view
- search for music/playlists
- Lyrics
- nice mode to show lyrics and covers

# NICE TO HAVE
- should slide title/subtitle in player if text too long to be shown
- should be able to remove songs from the playlist
- should be able to rearrange songs in the paylists
- should be able to right click songs/playlists (even multiple selections) and add them to the current playing playlist
- should be able to fast forward/backward songs when the respective key is being pressed!

# DONE
- song clocks is corrupted at 10 secs
- better shuffle mechanism
  - when u shuffle, the song selected/playing should become first and the rest shuffled
    (not really, i prefer how it is now)
  - when no shuffle, the song selected/playing should go to his original position
  - play next song should always play the next song showed in the playing songs listview
- you should not use internet to load songs!!!!
- fix the green background on selected cell so text is readable, may also look for the red color on black
  (nah, it's ok)
- the app should remember its last status whenever it launches:
  - save shuffle/repeat options
- fix the player cover
- the app should remember the volume last status
- when u double click on a song in the middle table, it should populate the playing list with those songs
- do notifications
- add an app icon
- change app name to mmmmmmmmmmmmmmmm: Media Player
- make the app icon a litle smaller
- volume slider
- fix the slider styles
- repeat playlist
- shuffle playlist
- fix title song text overlay on player
- indicate the current song in the listViews
- shortcuts for:
  - volume up/down = cmd + up/down
  - prev/next song = cmd + left/right
  - pause/play song = space
  - repeat
  - shuffle
- media keys not working when creating the app manually (using main.swift)
  I solved this by actually using a Xib file because i couldn't make it work without it
