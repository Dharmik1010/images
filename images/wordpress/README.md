<!--monopod:start-->
# wordpress
| | |
| - | - |
| **OCI Reference** | `cgr.dev/chainguard/wordpress` |


* [View container image in the Chainguard Containers Directory](https://images.chainguard.dev/directory/image/wordpress/overview).
* [View the Container Catalog](https://console.chainguard.dev/images/catalog) for a full list of available tags.
* [Contact Chainguard](https://www.chainguard.dev/contact?utm_source=readmes) for enterprise support, SLAs, and access to older tags.

---
<!--monopod:end-->

<!--overview:start-->
# Chainguard Container for wordpress

Minimalist Wolfi-based WordPress images.

Chainguard Containers are regularly-updated, secure-by-default container images.
<!--overview:end-->

<!--getting:start-->
## Download this Container Image
For those with access, this container image is available on `cgr.dev`:

```
docker pull cgr.dev/ORGANIZATION/wordpress:latest
```

Be sure to replace the `ORGANIZATION` placeholder with the name used for your organization's private repository within the Chainguard Registry.
<!--getting:end-->

<!--body:start-->
This image was designed to work as a drop-in replacement for the official [WordPress FPM-Alpine](https://hub.docker.com/_/wordpress) image, with a distroless variant for increased security on production environments. 

The `latest-dev` variant should be used to install and customize WordPress with themes and plugins. It has the same features from the upstream WordPress image, with an entrypoint script to set up the database via environment variables. The `latest` variant is a production-ready distroless image that should be used to run the WordPress site in a multi-stage build.

### Example Docker Compose Setup

You can use the following `docker-compose.yml` file to set up a **development environment** to install and customize WordPress:

```yaml
services:
  app:
    image: cgr.dev/chainguard/wordpress:latest-dev
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: wp-user
      WORDPRESS_DB_PASSWORD: wp-password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - document-root:/var/www/html
    networks:
      - wolfi

  nginx:
    image: cgr.dev/chainguard/nginx
    restart: unless-stopped
    ports:
      - 8000:8080
    volumes:
      - document-root:/var/www/html
      - ./nginx.conf:/etc/nginx/nginx.conf
    networks:
      - wolfi

  mariadb:
    image: cgr.dev/chainguard/mariadb
    restart: unless-stopped
    environment:
      MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: 1
      MARIADB_USER: wp-user
      MARIADB_PASSWORD: wp-password
      MARIADB_DATABASE: wordpress
    ports:
      - 3306:3306
    networks:
      - wolfi

networks:
  wolfi:
    driver: bridge

volumes:
  document-root:
```

For this setup to work, you'll need an `nginx.conf` file with the following content:

```nginx
pid /var/run/nginx.pid;

events {
  worker_connections  1024;
}

http {
    server {
        listen 8080;
        index index.php index.html;
        root /var/www/html;
        charset utf-8;
        client_max_body_size 100M;
        timeout 300;

        location / {
            include  /etc/nginx/mime.types;
            try_files $uri $uri/ /index.php?$query_string;
        }

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass app:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }

        location ~ /\.(?!well-known).* {
            deny all;
        }
    }
}

```

After running `docker compose up`, your WordPress site will be available at `http://localhost:8000`. You can follow the installation instructions to set up your site and test your setup, but persisting customizations such as themes and plugins will require a different strategy that requires either setting up a volume for your theme and plugins or copying the custom content to the image through a Dockerfile that uses `cgr.dev/chainguard/wordpress:latest-dev` as the base image.


<!--body:end-->

## What are Chainguard Containers?

[Chainguard Containers](https://www.chainguard.dev/containers?utm_source=readmes) are minimal container images that are secure by default. 

In many cases, the Chainguard Containers tagged as `:latest` contain only an open-source application and its runtime dependencies. These minimal container images typically do not contain a shell or package manager. Chainguard Containers are built with [Wolfi](https://edu.chainguard.dev/open-source/wolfi/overview?utm_source=readmes), our Linux _[undistro](https://edu.chainguard.dev/open-source/wolfi/overview/#why-undistro)_ designed to produce container images that meet the requirements of a more secure software supply chain.

The main features of Chainguard Containers include:

* Minimal design, without unnecessary software bloat
* Daily builds to ensure container images are up-to-date with available security patches
* [High quality build-time SBOMs](https://edu.chainguard.dev/chainguard/chainguard-images/working-with-images/retrieve-image-sboms/?utm_source=readmes) attesting to the provenance of all artifacts within the image
* [Verifiable signatures](https://edu.chainguard.dev/chainguard/chainguard-images/working-with-images/retrieve-image-sboms/) provided by [Sigstore](https://edu.chainguard.dev/open-source/sigstore/cosign/an-introduction-to-cosign/?utm_source=readmes)
* Reproducible builds with Cosign and apko ([read more about reproducibility](https://www.chainguard.dev/unchained/reproducing-chainguards-reproducible-image-builds?utm_source=readmes))

For cases where you need container images with shells and package managers to build or debug, most Chainguard Containers come paired with a `-dev` variant.

Although the `-dev` container image variants have similar security features as their more minimal versions, they feature additional software that is typically not necessary in production environments. We recommend using multi-stage builds to leverage the `-dev` variants, copying application artifacts into a final minimal container that offers a reduced attack surface that won’t allow package installations or logins.

## Learn More

To better understand how to work with Chainguard Containers, please visit [Chainguard Academy](https://edu.chainguard.dev/?utm_source=readmes) and [Chainguard Courses](https://courses.chainguard.dev/?utm_source=readmes).

In addition to [Containers](https://www.chainguard.dev/containers?utm_source=readmes), Chainguard offers [VMs](https://www.chainguard.dev/vms?utm_source=readmes) and [Libraries](https://www.chainguard.dev/libraries?utm_source=readmes). [Contact Chainguard](https://www.chainguard.dev/contact?utm_source=readmes) to access additional products. 

## Trademarks

_This software listing is packaged by Chainguard. The trademarks set forth in this offering are owned by their respective companies, and use of them does not imply any affiliation, sponsorship, or endorsement by such companies._