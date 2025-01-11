Automated builds of the [cobalt](https://github.com/imputnet/cobalt) web front-end.

### Usage

Fork the repo, and set the following [actions variables](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-a-repository) on your repository:

`COBALT_WEB_DEFAULT_API` - The URL of your cobalt API (ex: `https://api.cobalt.tools`)

`COBALT_WEB_HOST` - Hostname of your cobalt web instance (ex: `cobalt.tools`)

Run the first workflow manually to publish the image: Repository -> Actions -> cobalt-update -> Run workflow.

Once the docker image is published, pull it down using compose or Docker CLI:

```yml
...
 cobalt-web:
    container_name: cobalt-web
    depends_on:
      - cobalt-api
    image: ghcr.io/[your-github-user]/cobalt-web:10.5
    restart: unless-stopped
```

