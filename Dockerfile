# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.8-slim

EXPOSE 80 

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Response Message (For security purposes let's include this in a SSM)
ENV RESPONSE="success"

#See if this is needed
WORKDIR /app
COPY ./src /app

# Install pip requirements
COPY requirements.txt /app
RUN python -m pip install -r requirements.txt


# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:80", "main:app"]
