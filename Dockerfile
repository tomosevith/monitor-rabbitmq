FROM python:3.4-alpine3.7
RUN apk update && apk add dcron && rm -rf /var/cache/apk/*
WORKDIR /app
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
