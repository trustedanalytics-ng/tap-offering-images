# tap-offering-images
Dockerfiles of customized images for TAP offerings

## Adding a new offering image
1. Create a new directory for your image in `images` directory (e.g. `mkdir ./images/my_image`).
2. Place `Dockerfile`, `build.sh` script and all other required files in your image directory.
3. Add a new entry to `tap_offering_images` list in `group_vars/all` file (e.g. `- { name: "my_image", tag: "my_tag", path: "/images/my_image"`).

## Building images using Ansible

Prerequisites:
1. Docker.
2. docker-py (`pip install docker-py`).

Run `build.sh` in order to build all TAP offering images. Modify `tap_offering_images` list in `group_vars/all` file in order to
define specific images to build.

Run `tag.sh`  in order to build all TAP offering images and tag them with `tapimages:8080` prefix, so thay can be used during
build of TAP compoments.
Registry host and port can be defined in `group_vars/all` file.

If you need `sudo` privileges for using Docker, uncomment `#become_root: no` line in `group_vars/all` file and change
`become_root` value to `yes`.

