# Use an official Node runtime as a parent image
FROM node:20.12.2-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files
COPY app/package.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy the rest of the application code
COPY app/ ./

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the app
CMD ["npm", "start"]