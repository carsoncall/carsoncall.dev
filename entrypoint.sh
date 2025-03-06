#!/bin/sh
exec hugo server --bind 0.0.0.0 --port 1313 --baseURL ${HUGO_BASE_URL:-https://carsoncall-dev.fly.dev} 