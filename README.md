![tremor-plugin-wraith](http://i.imgur.com/DUomwIl.jpg)

tremor-plugin-wraith is a plugin to [sparkbox/tremor]. It leverages
[BBC-News Wraith], recording results back to Tremor.

## Development

Install the [Docker Platform] to run this image locally.

While developing this image, we have found the following convenient:

2. Build the Docker image using [Docker Platform]:
  ```
  docker build -t sparkbox/tremor-plugin-wraith:local .
  ```

3. Run the Docker image while [mounting] the project directory:
  ```
  docker run -ti sparkbox/tremor-plugin-wraith:local \
    -v ".:/wraith" \
    /bin/bash
  ```

You will now be in a Bash shell within a running container. Changes made to
this repo on your local file system will be reflected within the running
container, because you have mounted the current repo directory into the
container's [WORKDIR]


[BBC-News Wraith]: https://github.com/BBC-News/wraith
[mounting]: https://docs.docker.com/engine/tutorials/dockervolumes/#/mount-a-host-directory-as-a-data-volume
[WORKDIR]: https://docs.docker.com/engine/reference/builder/#workdir
[sparkbox/tremor]: https://github.com/sparkbox/tremor
[Docker Platform]: https://www.docker.com/products/overview

