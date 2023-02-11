#!/bin/bash

docker compose -f "kohya-webui.docker-compose.yml" up -d --build
docker exec -it kohya-webui bash