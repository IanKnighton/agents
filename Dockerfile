FROM python:3.13-slim

WORKDIR /repo
ENTRYPOINT ["python", "scripts/sync-agents.py"]
