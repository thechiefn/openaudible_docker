# Synology Quick Start Guide

**Goal:** Get OpenAudible running on your Synology NAS with audiobooks accessible via network share.

## What You Need

1. Synology NAS with Container Manager installed
2. 5 minutes and SSH access (for best results)
3. Your Synology user credentials

## Recommended Approach: One Shared Audiobooks Folder

This setup gives you:
- ✅ OpenAudible accessible at `http://YOUR-NAS-IP:3000`
- ✅ All audiobooks accessible at `\\YOUR-NAS-IP\Audiobooks`
- ✅ Simple backup and maintenance
- ✅ Easy sharing with family/friends
- ✅ Compatible with media servers (Plex, Audiobookshelf, etc.)

## Step-by-Step Setup

### 1. Create a Shared Folder for Audiobooks

**Via DSM GUI:**
1. Open **Control Panel** > **Shared Folder**
2. Click **Create**
3. Name: `Audiobooks`
4. Location: Volume 1 (or your preferred volume)
5. Click through wizard, set your user permissions to Read/Write
6. Click **Apply**

**Result:** You now have `/volume1/Audiobooks` on your NAS

### 2. Download and Configure docker-compose.yml

**Via SSH:**
```bash
# SSH into your NAS
ssh admin@YOUR-NAS-IP

# Find your user IDs
id
# Note the uid (usually 1026) and gid (usually 100)

# Create project directory
mkdir -p /volume1/docker/projects/openaudible
cd /volume1/docker/projects/openaudible

# Download the Synology-optimized compose file
wget -O docker-compose.yml https://raw.githubusercontent.com/openaudible/openaudible_docker/main/docker-compose.synology.yml

# Edit it (or download and edit on your computer, then upload)
nano docker-compose.yml
```

**Key changes to make:**
```yaml
volumes:
  # Change this to use your Audiobooks shared folder
  - /volume1/Audiobooks:/config/OpenAudible

environment:
  # Change to your actual IDs from the 'id' command
  - PUID=1026
  - PGID=100
  # Optional: Set your timezone
  - TZ=America/New_York  # or Europe/London, Asia/Tokyo, etc.
```

### 3. Pre-create Directory with Correct Permissions

**IMPORTANT - This prevents permission errors:**

```bash
# Use YOUR PUID and PGID from step 2
sudo chown 1026:100 /volume1/Audiobooks
sudo chmod 755 /volume1/Audiobooks
```

### 4. Deploy the Container

**Option A: Via Container Manager GUI (Easier)**
1. Open **Container Manager** app
2. Go to **Project** tab
3. Click **Create**
4. Choose to upload your edited `docker-compose.yml`
5. Project name: `openaudible`
6. Click **Next**, then **Done**

**Option B: Via SSH (Faster)**
```bash
cd /volume1/docker/projects/openaudible
docker-compose up -d
docker-compose logs -f  # Watch the logs
```

### 5. Access OpenAudible

Open browser: `http://YOUR-NAS-IP:3000`

First launch takes 1-2 minutes while it downloads and installs OpenAudible.

### 6. Access Your Audiobooks via Network

From any device on your network:

- **Windows:** `\\YOUR-NAS-IP\Audiobooks` or `\\YOUR-NAS-NAME\Audiobooks`
- **Mac:** Finder > Go > Connect to Server > `smb://YOUR-NAS-IP/Audiobooks`
- **Linux:** File manager > Network > SMB > `smb://YOUR-NAS-IP/Audiobooks`
- **Mobile:** Use Synology DS file app, browse to Audiobooks folder

## What You'll Find in the Audiobooks Folder

After OpenAudible downloads some books:

```
Audiobooks/
├── books/    - Original downloaded files
├── m4b/      - Converted M4B files (best for audiobook players)
├── mp3/      - Converted MP3 files (if you enable MP3 conversion)
├── aax/      - Original Audible AAX files
├── art/      - Cover artwork
└── books.json - Library database
```

**Pro tip:** Point your audiobook player or media server to `\\YOUR-NAS\Audiobooks\m4b` for the cleanest library.

## Troubleshooting

### Port 3000 shows "Cannot connect"

**This is usually because the security option is missing.**

If you deployed via GUI manually (not docker-compose), the container needs `--security-opt seccomp=unconfined`.

**Solution:** Use the docker-compose method instead, which includes this automatically.

### Permission Errors

Check directory ownership:
```bash
ls -ld /volume1/Audiobooks
# Should show: drwxr-xr-x ... 1026 users ... /volume1/Audiobooks
```

Fix if needed:
```bash
sudo chown -R 1026:100 /volume1/Audiobooks
```

### Container Running but Nothing Happens

Check the logs:
```bash
# Via SSH
docker logs -f openaudible

# Or in Container Manager
# Click on the container > Details > Log tab
```

### Can't Access Network Share

Ensure the shared folder exists:
1. Open **File Station**
2. Look for `Audiobooks` folder
3. If missing, create it via Control Panel > Shared Folder

## Importing Existing Audiobooks

If you already have audiobooks elsewhere on your NAS:

**Add to docker-compose.yml:**
```yaml
volumes:
  - /volume1/Audiobooks:/config/OpenAudible
  - /volume1/Media/MyOldAudiobooks:/import/old:ro  # Read-only
```

**Restart container, then in OpenAudible:**
1. Browse to `/import/old` in the file picker
2. Select books to import
3. OpenAudible copies them to its managed library

## Upgrading

To upgrade to the latest OpenAudible version:

**Via Container Manager:**
1. Project tab > openaudible
2. Click **Stop**
3. Click **Start**

**Via SSH:**
```bash
cd /volume1/docker/projects/openaudible
docker-compose pull
docker-compose up -d
```

**Your books are safe!** They're in the volume and won't be affected.

## Next Steps

1. **Set up backups:** Use Hyper Backup to back up `/volume1/Audiobooks`
2. **Configure OpenAudible:** Log into your Audible account in the app
3. **Download books:** Use OpenAudible to download and convert your audiobooks
4. **Share with family:** Give them access to `\\YOUR-NAS\Audiobooks\m4b`
5. **Optional:** Set up a reverse proxy for HTTPS access
6. **Optional:** Integrate with Plex, Audiobookshelf, or other media servers

## Getting Help

- **Full documentation:** [SYNOLOGY.md](SYNOLOGY.md)
- **Docker Compose reference:** [docker-compose.yml](docker-compose.yml)
- **GitHub Issues:** [Report a problem](https://github.com/openaudible/openaudible_docker/issues)

## Summary: What This Setup Gives You

✅ **Browser-accessible OpenAudible** - Manage your audiobooks from any device
✅ **Network-accessible audiobooks** - Share with all your devices
✅ **Automatic startup** - Container restarts with NAS
✅ **Easy backups** - One folder to back up
✅ **Simple upgrades** - Just restart the container
✅ **No desktop software needed** - Everything runs on your NAS
✅ **24/7 availability** - Access from anywhere on your network

Enjoy your audiobooks! 🎧
