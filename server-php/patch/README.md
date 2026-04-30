# Patch Directory

This directory contains files that override vendor packages after composer install.

## Usage

Place files here that should overwrite files in `vendor/` or elsewhere after dependencies are installed. The entire contents of this directory are copied over the application root.

## Example

To patch a vendor file:
```
patch/vendor/some-package/src/File.php
```

This will overwrite `vendor/some-package/src/File.php` in the built image.

## Empty by Default

For the base image, this directory is empty. Applications using this image should mount or copy their own patches.
