# devserver

- nginx (openresty)
- [s6-overlay](https://github.com/just-containers/s6-overlay)
- nodejs:18
- golang
- [task](https://taskfile.dev)

### Usage:

```
FROM jc21/devserver:latest

...
```

You will have to create your own Nginx configration and s6 services.

This image isn't really intended for public use, so I won't be supporting issues or PR's.
