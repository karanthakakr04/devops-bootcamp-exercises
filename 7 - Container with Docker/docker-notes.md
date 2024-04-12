# Notes

What is the difference between `RUN`, `CMD`, and `ENTRYPOINT` commands in Dockerfile?

The `RUN`, `CMD`, and `ENTRYPOINT` commands are used in a Dockerfile to define the execution behavior of a container. Here's a breakdown of their differences:

1. `RUN`:
   - The `RUN` command is used to execute commands during the image build process.
   - It creates a new layer in the Docker image for each `RUN` command.
   - Multiple `RUN` commands can be used in a Dockerfile, and each command is executed in a separate shell.
   - The purpose of `RUN` is to install dependencies, set up the environment, or perform any necessary configuration steps.
   - Example: `RUN apt-get update && apt-get install -y nodejs`

2. `CMD`:
   - The `CMD` command specifies the default command and/or arguments to be executed when a container is started from the image.
   - It provides a default command that can be overridden when running the container with a different command.
   - If multiple `CMD` commands are present in a Dockerfile, only the last one takes effect.
   - The `CMD` command is typically used to start the main process or application inside the container.
   - Example: `CMD ["node", "app.js"]`

3. `ENTRYPOINT`:
   - The `ENTRYPOINT` command sets the primary command for the container, which cannot be overridden easily when running the container.
   - It allows you to configure a container that runs as an executable, with any arguments passed to `docker run` appended to the `ENTRYPOINT` command.
   - If both `ENTRYPOINT` and `CMD` are present in a Dockerfile, the `CMD` command acts as default arguments to the `ENTRYPOINT` command.
   - The `ENTRYPOINT` command is useful when you want to define a fixed command that should always be executed when the container starts.
   - Example: `ENTRYPOINT ["node"]` with `CMD ["app.js"]` will run `node app.js` when the container starts.

Here's a summary of their usage:

- Use `RUN` for executing commands and setting up the environment during the image build process.
- Use `CMD` to specify the default command to be executed when a container starts, which can be overridden.
- Use `ENTRYPOINT` to define the main command for the container that cannot be easily overridden, and use `CMD` to provide default arguments to the `ENTRYPOINT` command if needed.

It's important to note that if you specify both `ENTRYPOINT` and `CMD` in a Dockerfile, the `CMD` command will be treated as arguments to the `ENTRYPOINT` command. If you want to use `CMD` independently, make sure to specify it without an `ENTRYPOINT`.
