#!/bin/bash

# Script to strip output from all Jupyter notebooks in the project
# Uses the Docker container to run nbconvert

echo "Stripping output from all Jupyter notebooks..."

# Function to check if Docker is available
check_docker() {
    if command -v docker &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if docker-compose is available
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if Docker and docker-compose are available
if ! check_docker; then
    echo "Error: Docker not found. Please install Docker to use this script."
    exit 1
fi

if ! check_docker_compose; then
    echo "Error: docker-compose not found. Please install docker-compose to use this script."
    exit 1
fi

# Find all .ipynb files in the project
notebooks=$(find . -name "*.ipynb" -not -path "./.ipynb_checkpoints/*" -not -path "./.git/*")

if [ -z "$notebooks" ]; then
    echo "No Jupyter notebooks found."
    exit 0
fi

echo "Found notebooks:"
echo "$notebooks"

# Check if the container is running, if not start it temporarily
container_running=$(docker-compose ps -q jupyter)
if [ -z "$container_running" ]; then
    echo "Starting Jupyter container temporarily for notebook processing..."
    docker-compose up -d jupyter
    
    # Wait a moment for the container to be ready
    sleep 3
    
    # Set flag to stop container after processing
    stop_container=true
else
    stop_container=false
fi

# Process each notebook
for notebook in $notebooks; do
    if [ -f "$notebook" ]; then
        echo "Stripping output from: $notebook"
        
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Use Docker container to strip output using nbconvert
        docker-compose exec -T jupyter jupyter-nbconvert \
            --to notebook \
            --ClearOutputPreprocessor.enabled=True \
            --stdout "/home/jovyan/work/$notebook" > "$temp_file"
        
        # Check if the conversion was successful
        if [ $? -eq 0 ]; then
            # Replace the original file with the stripped version
            mv "$temp_file" "$notebook"
            echo "✓ Successfully stripped output from $notebook"
        else
            echo "✗ Failed to strip output from $notebook"
            rm -f "$temp_file"
        fi
    fi
done

# Stop container if we started it
if [ "$stop_container" = true ]; then
    echo "Stopping temporary Jupyter container..."
    docker-compose stop jupyter
fi

echo "Notebook output stripping completed!" 