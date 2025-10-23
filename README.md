# YT-DLP: containerisation

Run `yt-dlp` inside a container.



## Table of contents

- [About](#about)
- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [License](#license)



## About

Lightweight, non-root, container image with `yt-dlp` and recommended dependencies `ffmpeg` and `ffprobe`.



## Features

- This image is updated everytime a new version of `yt-dlp` is launched.
- Lightweight Base Image: `python:alpine`.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) version: `2025.10.22`.
- [ffmpeg](https://johnvansickle.com/ffmpeg) version: `6.1`.
- Run as a non-root user.



## Getting Started

This image can be used with [Docker](https://docker.com) and [Podman](https://github.com/containers/podman). You will need one of these installed.



## Usage

### Standard usage
```
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/storage fhfa/yt-dlp [OPTIONS] URL [URL...]
```
```
podman run --rm --userns keep-id -v $(pwd):/storage docker.io/fhfa/yt-dlp [OPTIONS] URL [URL...]
```

- Directory where you run this command will be made available to yt-dlp and files will be written there.
- The entrypoint is set to yt-dlp, so do not put yt-dlp again as argument.
- You can shorten this command with an [alias](#specify-an-alias-command).

### Specify an alias command
You can omit the entire command input by specifying an alias in your shell of choice. The following line can be added to the end of your `.bash_aliases`, `.bashrc` or `.zshrc`. Afterwards you can simply use `yt-dlp [OPTIONS] URL [URL...]` from your shell.

```
alias yt-dlp='docker run --rm -u $(id -u):$(id -g) -v $(pwd):/storage fhfa/yt-dlp'
```
```
alias yt-dlp='podman run --rm --userns keep-id -v $(pwd):/storage docker.io/fhfa/yt-dlp'
```

### Bypass entrypoint and execute arbitrary commands
Check the version of FFmepg
```
docker run --rm --entrypoint '' fhfa/yt-dlp ffmpeg -version | head -n 1
```
```
podman run --rm --entrypoint '' docker.io/fhfa/yt-dlp ffmpeg -version | head -n 1
```

Launch a shell
```
docker run -it --rm --entrypoint '' fhfa/yt-dlp sh
```
```
podman run -it --rm --entrypoint '' docker.io/fhfa/yt-dlp sh
```


## Contributing
Check our [issue tracker](https://github.com/fhfa/yt-dlp/issues) for open issues or create new ones for any problems or feature requests. You can also clone this repository solve issues or implement new features and submit a pull request.

By contributing to this project, you agree that your contributions will be licensed under [Apache License 2.0](LICENSE).



## Acknowledgements
Without the work from the people behind [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [ffmpeg](https://johnvansickle.com/ffmpeg), this container image wouldn't have a purpose. Also, this repository was greatly inspired by the works of [tnk4on/yt-dlp](https://github.com/tnk4on/yt-dlp) and [kijart/docker-youtube-dl](https://github.com/kijart/docker-youtube-dl). Show them some 🤍



## License
[Apache License 2.0](LICENSE)