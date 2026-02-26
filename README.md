# OpenAudible for Docker

This container runs [OpenAudible](https://openaudible.org) with its GUI accessible by browser. 

This is an experimental alternative to the supported and recommended desktop binaries available at [openaudible.org](https://openaudible.org). 

This project is hosted on [github](https://github.com/openaudible/openaudible_docker) and [dockerhub](https://hub.docker.com/r/openaudible/openaudible)

This project uses the [LinuxServer.io Selkies base image](https://github.com/linuxserver/docker-baseimage-selkies) for modern web-based desktop containerization.

## Description

OpenAudible runs on Linux, Mac, and Windows. This Docker container runs the latest Linux version with a web-accessible GUI via browser, making it easy to run OpenAudible from a container, on the cloud, or from any Docker-capable system (NAS, VPS, home lab, etc.).

**Key features:**
- **Browser-based access** from any device (desktop, mobile, tablet)
- **Data persistence** - all books, metadata, and settings stored in a persistent volume
- **GPU acceleration support** - hardware acceleration for Intel/AMD GPUs (Wayland mode)
- **No passwords by default** - can be added via reverse proxy or environment variables
- **Single user** - designed for personal use; one user can view sessions at a time

The container stores all OpenAudible data in `/config/OpenAudible`. Map this to a volume on your host system to access downloaded and converted audiobooks. See the Configuration section below for platform-specific instructions.

## Quick Start

```bash
docker run -d --rm -it -p 3000:3000 --security-opt seccomp=unconfined --name openaudible openaudible/openaudible:latest
```

Then open your web browser to **http://localhost:3000**

You'll probably want to map a volume for persistent audiobook storage:

```bash
docker run -d \
  -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

## Configuration

This container is based on [LinuxServer.io's Selkies base image](https://github.com/linuxserver/docker-baseimage-selkies), which provides a powerful web-based desktop environment. Refer to the [baseimage-selkies documentation](https://github.com/linuxserver/docker-baseimage-selkies) for advanced Selkies configuration options and features.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for the container user (abc) |
| `PGID` | `1000` | Group ID for the container user (abc) |
| `TZ` | `Etc/UTC` | Timezone (e.g., `America/New_York`, `Europe/London`) |
| `OA_BETA` | `true` | Download beta (true) or stable (false) OpenAudible versions |
| `OA_KIOSK` | `true` | Enable kiosk mode (disables quit menu) |
| `oa_internal_browser` | `true` | Use internal browser for Audible authentication |
| `UMASK` | `022` | Umask for running applications |
| `LC_ALL` | (unset) | Language/locale setting (e.g., `fr_FR.UTF-8`) |
| `PIXELFLUX_WAYLAND` | `false` | Enable Wayland mode for zero-copy GPU encoding |
| `DRINODE` / `DRI_NODE` | (unset) | Path to GPU device for rendering (e.g., `/dev/dri/renderD128`) |
| `MAX_RESOLUTION` | `16k` | Maximum virtual resolution (e.g., `3840x2160`, `1920x1080`) |
| `CUSTOM_USER` | `abc` | HTTP Basic auth username |
| `PASSWORD` | (unset) | HTTP Basic auth password (no auth if unset) |
| `CUSTOM_PORT` | `3000` | HTTP port |
| `CUSTOM_HTTPS_PORT` | `3001` | HTTPS port |
| `TITLE` | `Selkies` | Web page title |

**Advanced Selkies options:** See the [baseimage-selkies environment variables documentation](https://github.com/linuxserver/docker-baseimage-selkies?tab=readme-ov-file#options) for full Selkies configuration (GPU settings, video encoding, UI customization, hardening, etc.).

**Example with authentication and GPU:**
```bash
docker run -d \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=America/New_York \
  -e CUSTOM_USER=myuser \
  -e PASSWORD=mypassword \
  -e PIXELFLUX_WAYLAND=true \
  -e DRINODE=/dev/dri/renderD128 \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --device /dev/dri:/dev/dri \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

### Hardware Acceleration (GPU)

The container supports GPU acceleration for Intel, AMD, and Nvidia GPUs. Enable Wayland mode for optimal performance with zero-copy encoding.

#### Wayland Mode (Recommended for GPU Acceleration)

Set `PIXELFLUX_WAYLAND=true` to enable Wayland mode with GPU-accelerated rendering:

```bash
docker run -d \
  -e PIXELFLUX_WAYLAND=true \
  -e DRINODE=/dev/dri/renderD128 \
  --device /dev/dri:/dev/dri \
  -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

#### Intel/AMD GPUs (DRI3)

For open-source drivers, pass the GPU device and set the render node:

```bash
docker run -d \
  -e DRINODE=/dev/dri/renderD128 \
  --device /dev/dri:/dev/dri \
  -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

**Note:** To find your GPU device, run: `ls -la /dev/dri/`

#### Nvidia GPUs

Nvidia support requires the proprietary driver and Nvidia Docker runtime:

```bash
docker run -d \
  -e PIXELFLUX_WAYLAND=true \
  -e DRINODE=/dev/dri/renderD128 \
  --gpus all \
  --runtime nvidia \
  -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

**Prerequisites for Nvidia:**
- Proprietary drivers (580+)
- Nvidia Docker runtime configured
- For Wayland headless systems: `nvidia-modprobe --modeset`

See the [baseimage-selkies GPU documentation](https://github.com/linuxserver/docker-baseimage-selkies?tab=readme-ov-file#gpu-acceleration) for full details.

### Language Support

Set the `LC_ALL` environment variable to run the container in different languages:

```bash
# Chinese
-e LC_ALL=zh_CN.UTF-8

# Japanese
-e LC_ALL=ja_JP.UTF-8

# Spanish
-e LC_ALL=es_MX.UTF-8

# German
-e LC_ALL=de_DE.UTF-8

# French
-e LC_ALL=fr_FR.UTF-8
```

### Security Considerations

⚠️ **Important:** This container provides access to a GUI with terminal and sudo access. Use appropriate security measures:

1. **Never expose to the internet without authentication** - Use a reverse proxy (e.g., [SWAG](https://github.com/linuxserver/docker-swag)) with proper authentication
2. **Use HTTPS** - The container supports self-signed HTTPS on port 3001
3. **Authentication** - Add basic auth via `CUSTOM_USER` and `PASSWORD` environment variables (for trusted networks only)
4. **Seccomp** - The `--security-opt seccomp=unconfined` flag is required for OpenAudible to run
5. **Hardening** - For single-application use, consider hardening options: `DISABLE_SUDO`, `DISABLE_TERMINALS`, `DISABLE_CLOSE_BUTTON`

See the [baseimage-selkies security documentation](https://github.com/linuxserver/docker-baseimage-selkies?tab=readme-ov-file#hardening) for additional hardening options.

## Deployment

### Docker Compose (Recommended)

The easiest deployment method is using docker-compose:

**Generic (works everywhere):**
```bash
wget https://raw.githubusercontent.com/openaudible/openaudible_docker/main/docker-compose.yml
docker-compose up -d
```

**Synology-optimized:**
```bash
wget https://raw.githubusercontent.com/openaudible/openaudible_docker/main/docker-compose.synology.yml -O docker-compose.yml
# Edit file, then deploy via Container Manager > Project > Create
```

For detailed Synology instructions, see [SYNOLOGY.md](SYNOLOGY.md).

### Command Line Deployment

```bash
docker run -d \
  --name=openaudible \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/audiobooks:/config/OpenAudible \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  --security-opt seccomp=unconfined \
  --restart unless-stopped \
  openaudible/openaudible:latest
```

**Synology example:**
```bash
docker run -d \
  --name=openaudible \
  -p 3000:3000 \
  -v /volume1/Audiobooks:/config/OpenAudible \
  -e PUID=1026 \
  -e PGID=100 \
  --security-opt seccomp=unconfined \
  --restart unless-stopped \
  openaudible/openaudible:latest
```

### Data Persistence

The container stores all OpenAudible data (books, metadata, settings) in `/config/OpenAudible`. You **must** map a persistent volume for data to survive container restarts.

**Finding your PUID/PGID:**
```bash
id your_user
# Example output: uid=1000(user) gid=1000(user)
```

**Ensuring file permissions:**
```bash
# Pre-create the data directory with correct ownership
mkdir -p /path/to/audiobooks
chown 1000:1000 /path/to/audiobooks  # Use your actual PUID:PGID

# Or use your user's ID
chown $(id -u):$(id -g) /path/to/audiobooks
```

**If you get permission errors after startup:**
```bash
ls -ld /path/to/audiobooks
# Check ownership, fix if needed:
sudo chown -R $(id -u):$(id -g) /path/to/audiobooks
```

## Building from Source

```bash
git clone https://github.com/openaudible/openaudible_docker.git 
cd openaudible_docker
./run.sh
```

The [run.sh](run.sh) script automatically:
- Builds the Docker image
- Creates and starts the container with proper volume mounting
- Maps the audiobooks directory to `$HOME/OpenAudibleDocker`
- Exposes port 3000

Edit `run.sh` to customize the data directory, port mapping, or other settings.

**Manual startup** (if needed):
```bash
./bash.sh           # Exec into running container
OpenAudible         # Start the application manually
```

## Upgrading OpenAudible

To upgrade to the latest OpenAudible version, stop and remove the container, then restart it:

```bash
docker stop openaudible
docker rm openaudible
docker run -d -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --restart unless-stopped \
  openaudible/openaudible:latest
```

**Your books, settings, and data are safe** - they're stored in the volume mount and persist across container restarts. The latest version will be automatically downloaded and installed on the first run.

### Beta vs Stable Versions

By default, the container downloads the latest **beta** version of OpenAudible. To use the **stable** release version instead:

```bash
docker run -d -p 3000:3000 \
  -e OA_BETA=false \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  --name openaudible \
  openaudible/openaudible:latest
```

## Troubleshooting

### Application won't start

1. Ensure `--security-opt seccomp=unconfined` is present in your docker run command
2. Check container logs: `docker logs openaudible`
3. Verify the volume is mounted: `docker exec openaudible ls -la /config/OpenAudible`

### Permission errors

Ensure PUID and PGID match your user:
```bash
docker exec openaudible id abc
id your_user
# Both should show the same uid/gid
```

### Can't access web interface

- HTTP: http://localhost:3000
- HTTPS: https://localhost:3001 (self-signed certificate)
- Check port mapping: `docker port openaudible`

### OpenAudible fails to initialize

Remove the container and volume, then recreate:
```bash
docker stop openaudible
docker rm openaudible
# Keep your audiobooks volume - data persists!
docker run -d -p 3000:3000 \
  -v /path/to/audiobooks:/config/OpenAudible \
  --security-opt seccomp=unconfined \
  openaudible/openaudible:latest
```

## Important Notes

- **Single user sessions** - Only one user can access the GUI at a time
- **Authentication** - Use `CUSTOM_USER` and `PASSWORD` for basic auth (trusted networks only); use a reverse proxy for internet exposure
- **Audible logout** - If you logged into Audible, log out via the GUI before deleting the container to unregister the virtual device
- **Data persistence** - All data in `/config/OpenAudible` persists across container restarts
- **This is experimental** - Not officially supported by OpenAudible; it's a community project

For additional help with Selkies containerization, see the [LinuxServer.io baseimage-selkies documentation](https://github.com/linuxserver/docker-baseimage-selkies).

## Support

- **Issues/Bugs:** Report on [GitHub](https://github.com/openaudible/openaudible_docker/issues)
- **OpenAudible Help:** [openaudible.org](https://openaudible.org)
- **LinuxServer.io:** [linuxserver.io](https://linuxserver.io)

## License

The OpenAudible application is free to try shareware. See [openaudible.org](https://openaudible.org) for license details.


