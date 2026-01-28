# Lyrion Volume Sync

**A plugin for Lyrion Music Server to sync volume between players.**

This plugin allows you to synchronize volume control between Lyrion players. When you adjust the volume on a source player, all target players will automatically follow. No external UPnP polling required - it uses Lyrion's internal events for instant synchronization.

## Features

*   **Instant Sync:** Volume changes are synchronized immediately via internal events.
*   **Bidirectional Option:** Enable two-way sync so either player can control the other.
*   **Per-Player Configuration:** Select which player each target should follow.
*   **Zero Network Overhead:** No external UPnP calls or polling.

---

## Installation

### Recommended: Via Repository URL

1.  Open your **Lyrion Music Server** web interface.
2.  Navigate to **Settings** → **Plugins**.
3.  Scroll down to the bottom and find **Additional Repositories**.
4.  Add this repository URL:
    ```
    https://raw.githubusercontent.com/Mojopriest88/LyrionVolumeSync/main/repo.xml
    ```
5.  Click **Apply** to save the repository.
6.  Scroll back up to the **Third Party Plugins** section.
7.  Find **Lyrion Volume Sync** in the list and check the box to enable it.
8.  Click **Apply** and restart Lyrion Music Server when prompted.

### Alternative: Manual Installation

1.  Download the latest release from [GitHub Releases](https://github.com/Mojopriest88/LyrionVolumeSync/releases).
2.  Extract the `LyrionVolumeSync` folder to your LMS Plugins directory:
    *   **Windows:** `C:\Program Files\Lyrion\server\Plugins\`
    *   **Linux/Docker:** `/var/lib/squeezeboxserver/Plugins/` (path varies by install)
3.  Restart Lyrion Music Server.
4.  Go to **Settings** → **Plugins** and ensure **Lyrion Volume Sync** is active.

---

## Configuration

1.  Navigate to **Settings** → **Plugins** → **Lyrion Volume Sync** settings page.
2.  You will see a list of your connected players.
3.  **Enabled:** Check to activate volume sync for this player.
4.  **Source Player:** Select which player this one should follow.
5.  **Bidirectional:** Check to enable two-way sync (changes on this player will also update the source).

---

## Use Case Example

**Scenario:** You have a DAC player and a virtual "Volume Control" player.

1.  Set the **DAC player's** Source to **Volume Control**.
2.  Enable **Bidirectional** sync.
3.  Now adjusting volume on either player will sync to the other!

This is perfect for bit-perfect playback where you want the DAC player at fixed 100% while controlling volume from a separate virtual player.

---

## License

MIT License - see [LICENSE](LICENSE) file.
