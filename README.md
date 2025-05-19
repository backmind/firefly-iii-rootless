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
  backmind/firefly-iii-rootless:latest
```

## Docker Image Updates

This image is based on the official [fireflyiii/core](https://hub.docker.com/r/fireflyiii/core) image and tagged to follow its versioning scheme. When a new version of the official image is released, this image will be rebuilt automatically.

Tags:
- `latest`: Always points to the most recent stable build
- `x.y.z`: Version-specific builds matching the official Firefly III releases

## Building Locally

If you want to build this image locally:

```bash
git clone https://github.com/backmind/firefly-iii-rootless.git
cd firefly-iii-rootless
docker build -t firefly-iii-rootless .
```

## Environment Variables

This image supports all environment variables from the official Firefly III image, with no additional requirements. See the [official Firefly III documentation](https://docs.firefly-iii.org/firefly-iii/advanced-installation/docker/) for the complete list.

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
