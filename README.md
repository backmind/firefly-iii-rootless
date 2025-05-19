# Firefly III - Rootless Edition

[![Docker Hub](https://img.shields.io/docker/pulls/backmind/firefly-iii-rootless)](https://hub.docker.com/r/backmind/firefly-iii-rootless)
[![License](https://img.shields.io/github/license/backmind/firefly-iii-rootless)](https://github.com/backmind/firefly-iii-rootless/blob/main/LICENSE)

A Docker image for running [Firefly III](https://www.firefly-iii.org/) in rootless Docker environments, solving permission issues when running Docker with non-root users.

## Why this image?

The official Firefly III Docker image expects to run with root privileges, which can cause permission issues in rootless Docker setups. This image modifies the official image to work properly in such environments by:

1. Adjusting the UID/GID of the `www-data` user to match your system user
2. Setting proper permissions on critical directories
3. Providing a streamlined experience for rootless Docker deployments

## Usage

### With Docker Compose (recommended)

```yaml
version: '3.8'

services:
  db:
    image: mariadb:10.11
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=firefly
      - MYSQL_USER=firefly
      - MYSQL_PASSWORD=firefly
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped
    
  app:
    image: backmind/firefly-iii-rootless:latest
    volumes:
      - firefly_upload:/var/www/html/storage/upload
    ports:
      - '8080:8080'
    environment:
      - DB_HOST=db
      - DB_PORT=3306
      - DB_CONNECTION=mysql
      - DB_DATABASE=firefly
      - DB_USERNAME=firefly
      - DB_PASSWORD=firefly
      - APP_KEY=CHANGEME_32_CHARS
      - APP_URL=http://localhost:8080
      - S6_KEEP_ENV=1
      - S6_BEHAVIOUR_IF_STAGE2_FAILS=2
      # Rest of Firefly III environment variables
    depends_on:
      - db
    restart: unless-stopped

volumes:
  db_data:
  firefly_upload:
```

### With Docker Run

```bash
docker run -d \
  --name firefly-iii \
  -p 8080:8080 \
  -v firefly_upload:/var/www/html/storage/upload \
  -e DB_HOST=your_db_host \
  -e DB_PORT=3306 \
  -e DB_CONNECTION=mysql \
  -e DB_DATABASE=firefly \
  -e DB_USERNAME=firefly \
  -e DB_PASSWORD=firefly \
  -e APP_KEY=CHANGEME_32_CHARS \
  -e APP_URL=http://localhost:8080 \
  -e S6_KEEP_ENV=1 \
  -e S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  backmind/firefly-iii-rootless:latest
```

## UID/GID Considerations

This image is built with `UID:GID` of `1000:1000`, which works for most standard Linux installations where the first non-root user has these IDs. If your user has different IDs, you have the following options:

### Option 1: Adjust permissions on mounted volumes

Before starting the container, prepare your host directories with appropriate permissions:

```bash
# Create the directory if it doesn't exist
sudo mkdir -p /path/to/your/firefly_upload

# Change ownership to match the container's UID:GID (1000:1000)
sudo chown -R 1000:1000 /path/to/your/firefly_upload

# Ensure proper permissions
sudo chmod -R 775 /path/to/your/firefly_upload
```

For example, if your host user is `docker:docker` with UID:GID `1003:994` (as in the author's setup):

```bash
# You need to ensure the volume directory has ownership matching 
# the container's expected 1000:1000, not your host user's 1003:994
sudo mkdir -p /SERV-PROG/dockerFF/firefly3/firefly_iii_upload
sudo chown -R 1000:1000 /SERV-PROG/dockerFF/firefly3/firefly_iii_upload
sudo chmod -R 775 /SERV-PROG/dockerFF/firefly3/firefly_iii_upload
```

### Option 2: Build your own image with custom UID/GID

If you prefer your container to use your specific UID:GID:

```bash
# Clone the repository
git clone https://github.com/backmind/firefly-iii-rootless.git
cd firefly-iii-rootless

# Build with your custom UID/GID
docker build -t firefly-iii-rootless-custom \
  --build-arg PUID=$(id -u) \
  --build-arg PGID=$(id -g) .

# Use your custom image in docker-compose.yml
# Replace: image: backmind/firefly-iii-rootless:latest
# With: image: firefly-iii-rootless-custom
```

This approach requires rebuilding your image whenever the upstream Firefly III image updates, but gives you perfect UID/GID matching.

### Why not use environment variables?

Unfortunately, Docker's architecture doesn't allow modifying file ownership or user IDs after an image is built. The UID/GID must be set during the build process, which is why we use build arguments rather than runtime environment variables for this purpose.

## Docker Image Updates

This image is based on the official [fireflyiii/core](https://hub.docker.com/r/fireflyiii/core) image and tagged to follow its versioning scheme. When a new version of the official image is released, this image will be rebuilt automatically through GitHub Actions.

Tags:
- `latest`: Always points to the most recent stable build
- `x.y.z`: Version-specific builds matching the official Firefly III releases

## Environment Variables

This image supports all environment variables from the official Firefly III image. See the [official Firefly III documentation](https://docs.firefly-iii.org/firefly-iii/advanced-installation/docker/) for the complete list.

Additionally, the following S6 variables are recommended:
- `S6_KEEP_ENV=1`: Ensures environment variables are passed to all services
- `S6_BEHAVIOUR_IF_STAGE2_FAILS=2`: Controls container behavior if a service fails

## Security Considerations

While this image makes Firefly III work in rootless Docker environments, it's important to note that:

1. The image internally uses `chmod 777` on some directories to ensure proper functionality
2. You should still protect your Docker socket and follow other container security best practices
3. This is not an official image from the Firefly III team

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgements

- [Firefly III](https://www.firefly-iii.org/) - The excellent personal finance manager this image is based on
- [Firefly III Docker](https://github.com/firefly-iii/docker) - The official Docker implementation
