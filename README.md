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
