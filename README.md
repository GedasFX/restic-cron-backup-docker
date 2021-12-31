# Restic cron backup docker image

This is the backup solution for my personal hobby projects. Not extensible, but it does one job very well. Inspired by and contains code from [itzg/docker-mc-backup](https://github.com/itzg/docker-mc-backup) repository.

## Run modes

### CLI Mode

The CLI usage is identical to the one used in the [base image](https://hub.docker.com/r/instrumentisto/restic/).

Example:

```
docker run --rm -it \
            -v rclone-config:/root/.config/rclone \
            -e RESTIC_REPOSITORY=rclone:config_name:bucket_name \
            -e RESTIC_PASSWORD='' \
        gedasfx/restic-backup init
```

### Backup mode

Backup mode is intended to be run on a schedule. Scheduler is built in to the image and can be configured via `CRON_SCHEDULE` env variable.
Script runs at 3 AM every day by default.

This mode requires data volume to be mounted on `/data`.

Example:

```
docker run --rm \
            -v rclone-config:/root/.config/rclone \
            -v my-precious-data:/data:ro
            -e RESTIC_REPOSITORY=rclone:config_name:bucket_name \
            -e RESTIC_PASSWORD='' \
        gedasfx/restic-backup
```

Docker Compose:

```yml
version: "3.8"

services:
  service:
    image: my-special-service
    volumes:
      - ./data:/data

  service_backups:
    image: gedasfx/restic-backup
    volumes:
      - rclone-config:/root/.config/rclone
      - ./data:/data:ro
    environment:
      RESTIC_REPOSITORY: rclone:config_name:bucket_name
      RESTIC_PASSWORD: hunter2
      RESTIC_BACKUP_EXCLUDES: .jar,logs
      RESTIC_PRUNE_RETENTION: --keep-daily 7 --keep-weekly 10000
    stop_grace_period: 5m # Useful to prevent accidentally killing the container during backup

volumes:
  rclone-config:
    external: true
```

## Environment variables

| Variable               | Default Value | Example                            | Description                                                                                                                                                                                   |
| ---------------------- | ------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CRON_SCHEDULE          | 0 3 \* \* \*  | 0 3 \* \* \*                       | Cron expression of when the backup should take place                                                                                                                                          |
| RESTIC_REPOSITORY      | [Required]    | rclone:config_name:bucket_name     | Restic repository location                                                                                                                                                                    |
| RESTIC_PASSWORD        | [Required]    | hunter2                            | Restic repository password                                                                                                                                                                    |
| RESTIC_BACKUP_FLAGS    |               | -Hoverriden.host                   | Additional flags for restic backup command. [Restic docs](https://restic.readthedocs.io/en/latest/manual_rest.html)                                                                           |
| RESTIC_BACKUP_EXCLUDES |               | .zip,.jar,logs                     | Comma separated list of excludes. [Restic docs](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files)                                                                      |
| RESTIC_PRUNE_RETENTION |               | --keep-daily 7 --keep-weekly 10000 | Snapshot retention policy, passed as command line arguments. [Restic docs](https://restic.readthedocs.io/en/latest/060_forget.html?highlight=forget#removing-snapshots-according-to-a-policy) |

## Configuring rclone

Although not required, this image was created with the intention to use rclone, and thus requires config to be present. You can use the following interactive command to obtain one:

```
docker run -it --rm -v rclone-config:/config/rclone rclone/rclone config
```
