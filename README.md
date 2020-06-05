# Baruch Home Server

## Configuration

You need to create a `.env` file alongside the `docker-compose.yml` file. The `docker-compose` will subtitute the variables into the compose configurations.

### telegram-download-deaemon

Set the next variables in the `.env` file. You need to get this values from [Telegram App Configuration](https://my.telegram.org/apps) page.

 - `TELEGRAM_API_ID`
 - `TELEGRAM_API_HASH`
 - `TELEGRAM_TV_CHANNEL_ID`

## First Running

### telegram-download-daemon

For the first time, you need to authenticate with your phone number. Run only the `telegram-download-daemon` in interactive mode with `docker-compose run --rm telegram-download-daemon` and enter your phone number and then the code you received from Telegram.

You expect to see the message `Signed in successfully as {youe name}`.

### Deluge

 - `Preference -> Plugin -> Label` make sure the `Label` is checked, otherwise, Sonarr will can't contact with the downloads.
 - `Preference -> Downloads -> Download To` set to `/downloads`
 - `Preference -> Queue`
   - **Seeding:** `0`
   - **Share Ratio:** `0`
   - **Time Ratio:** `0`

### Jackett

Add indexers you want.

### Sonarr

Open the settings and check to show advanced settings.

#### Media Management

 - **Rename Episodes:** 
   - **Standard Episode Format:** `{Episode Title} S{season:00}E{episode:00} .`
   - **Series Folder Format:** `{Series TitleYear}`
   - **Season Folder Format:** `Season {season:00}`

#### Indexers

 - `Add Indexer -> Toznab`
    - **URL:** `http://localhost:9117/torznab/all`
    - **API Key:** Get from Jackett interface

#### Doanload Client

`Add Client -> Deluge`

#### Add Series

 - **Configuration**
   - **Root Folder:** `/tv`
   - **Quality Profile:** Select one

Now select seasons and/or episods to monitor. Click on "Search" icon to download monitored.

In **Queue**, make sure you see values in **Inexer**, **Download Client**, **Output Path** and **Progress** columns.

Open **Deluge** and see the downloading torrent.

### Jellyfin

 - **Media Library**
  - **Content type:** `TV Shows`
  - **Folders:** `/media/tv-shows`
