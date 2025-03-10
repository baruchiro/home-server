# Baruch Home Server

## Configuration

You need to create a `.env` file alongside the `docker-compose.yml` file. The `docker-compose` will subtitute the variables into the compose configurations.

### telegram-download-deaemon

Set the next variables in the `.env` file. You need to get this values from [Telegram App Configuration](https://my.telegram.org/apps) page.

- `TELEGRAM_DAEMON_API_ID`
- `TELEGRAM_DAEMON_API_HASH`
- [`TELEGRAM_TV_CHANNEL_ID`](https://stackoverflow.com/a/39943226/839513)

### telegram2twitter

Set the next variables in the `.env` file.

The next values are available in your [Twitter Developer Portal](https://developer.twitter.com/en/portal/projects-and-apps):

- `TELEGRAM_TWITTER_CONSUMER_KEY`
- `TELEGRAM_TWITTER_CONSUMER_SECRET`
- `TELEGRAM_TWITTER_ACCESS_TOKEN`
- `TELEGRAM_TWITTER_TOKEN_SECRET`

You need also to ask Telegram [BotFather](https://t.me/botfather) to give you the *Bot Access Token* for `TELEGRAM_TWITTER_BOT_TOKEN`.

Last variable is your `TELEGRAM_TWITTER_USER_ID`. You can launch the bot without it, and then you can get it by running the command `/id` in the bot.

### node-red

Set the secret in the `.env` file with the key `NODE_RED_CREDENTIAL_SECRET`.

## Register as Service

```bash
sudo cp home-server-compose.service /etc/systemd/system
sudo systemctl enable home-server-compose.service
./pull.sh
```

## First Running

### telegram-download-daemon

For the first time, you need to authenticate with your phone number. Run only the `telegram-download-daemon` in interactive mode with `docker-compose run --rm telegram-download-daemon` and enter your phone number and then the code you received from Telegram.

You expect to see the message `Signed in successfully as {youe name}`.

### Deluge

> **Port:** `8112`
> **Default password:** `deluge`

- `Preference -> Plugin -> Label` make sure the `Label` is checked, otherwise, Sonarr will can't contact with the downloads.
- `Preference -> Downloads -> Download To` set to `/downloads`
- `Preference -> Queue`
  - **Seeding:** `0`
  - **Share Ratio:** `0`
  - **Time Ratio:** `0`

### Jackett

> **Port:** `9117`

Add indexers you want.

### Sonarr

> **Port:** `8989`

Open the settings and check to show advanced settings.

#### Media Management

- **Rename Episodes:**
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

#### Connect

Add **Telegram**.

### Jellyfin

> **Port:** `8096`

- **Media Library**
  - **Content type:** `TV Shows`
  - **Folders:** `/media/tv-shows`

### Bazarr

> **Port:** `6767`

- **Sonarr**
  - **Hostname or IP Address:** `localhost`
  - **API Key:** Get from `Sonarr -> Settings -> General`
- **Notifications:** Telegram

### Paperless-ngx

> **Port:** `3355`

For the first time, you need to create a superuser account:

1. Start the Paperless services:
```bash
docker compose -f paperless-stack.yml up -d
```

2. Open a shell inside the paperless-web container:
```bash
docker compose -f paperless-stack.yml exec paperless-web bash
```

3. Create the superuser account:
```bash
python3 manage.py createsuperuser
```

4. Follow the prompts to set up your admin username, email, and password.

### Nocobase

> **Default login credentials:**
> - **Email:** `admin@nocobase.com`
> - **Password:** `admin123`
