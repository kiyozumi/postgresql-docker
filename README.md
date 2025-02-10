# postgresql-docker
This repository is for creating a local PostgreSQL environment using Docker

## Requirement

* Docker


## Getting Started

```zsh
git clone https://github.com/kiyozumi/postgresql-docker.git
cd postgresql-docker
docker compose up -d
```

## Usage
You can connect to PostgreSQL with the following settings in your favourite DB client.

| ITEM       | VALUE     |
|------------|-----------|
| Host       | localhost |
| Port       | 3307      |
| User       | postgres  |
| Password   | postgres  |
| Datebase   | postgres  |




# Note

If MySQL or MariaDB is running in localhost, the port number is changed to 3307 to avoid duplication.


