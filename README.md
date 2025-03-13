# Gopotify - A spotify client for Godot Engine

## Updated to Godot 4
Originally, this project was made and maintained in Godot 3. I have ported it over to Godot 4, everything feature from the original should still be working.

I'll continue to expand upon this as it doesn't quite do everything that I needed for my project, so if anyone comes across this and notices any issues, please feel free to contribute or submit an issue.

Original credit goes to the [original gopotify project](https://github.com/drarbego/gopotify) and [it's author](https://github.com/drarbego)

## Connect to Spotify

- Go to your [Spotify Dashboard](https://developer.spotify.com/dashboard/applications)
- Click on create an app, now you'll be able to see your `Client Id` and `Client Secret`
- Click on `EDIT SETTINGS`
- Add `http://localhost:{port}/callback` to the `Redirect URIs` field, the default port is `8889`
- Click on `SAVE`


## Use the client

After [installing the plugin]() you'll find a new node called `Gopotify`
- Add a `Gopotify` node to your scene
- Select the `Gopotify` node and in the inspector paste the `Client Id` and `Client Secret` in their respective inputs under `Script Variables`

## Implemented Functionality

| Function              | Description                                              |
|-----------------------|---------------------------------------------------------|
| play()                | Resumes music reproduction in the current active device |
| queue()               | Adds a track to the end of the current playing queue    |
| pause()               | Pauses music reproduction in the current active device  |
| next()                | Skips to next song                                      |
| previous()            | Returns to previous song                                |
| search()              | Search on spotify, returns a `GopotifySearch`           |
| update_player_state() | Syncs the Gopotify's `player` to  with spotify          |
