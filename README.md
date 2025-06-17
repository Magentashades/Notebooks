# Notebooks

**Notebooks** is a repository for Jupyter notebooks and scripts used in data extraction, cleaning, and manipulation.

## About

This repository supports research and data workflows for the YESS initiative, providing reusable code and documentation for:

- Extracting structured data from Google Docs or .docx files
- Parsing, cleaning, and transforming qualitative and quantitative data
- Exporting ready-to-analyze datasets (CSV, TSV, etc.)

## Repository Structure

- `/notebooks/` – Jupyter notebooks for interactive data work and workflow documentation
- `/data/` – Raw data files (e.g., exported .docx, .csv, or other source materials)
    - (Do not store sensitive or confidential data here)
- `/outputs/` – Cleaned, processed, or exported datasets (e.g., CSVs, TSVs, summary files)
- `/scripts/` – Utility scripts for project maintenance
  - `setup-pre-commit.sh` – Setup script for new users to configure the pre-commit hook
  - `strip-notebooks.sh` – Manual script to strip output from all notebooks
- `docker-compose.yml` – Docker Compose configuration for running the notebook environment
- `jupyter_notebook_config.py` – Jupyter configuration with dark theme setup
- `README.md` – This file

## Getting Started

This project is configured to run using Docker Compose with a pre-built Jupyter environment from quay.io.

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/magentashades/YESS_Notebooks.git
   cd YESS_Notebooks
   ```

2. **Start the Jupyter environment:**
   ```bash
   docker-compose up -d
   ```

3. **Access Jupyter Lab:**
   - Open your web browser and navigate to: `http://localhost:8888`
   - Use the token: `magz-public-token` or password: `magz-public-password`

4. **Stop the environment:**
   ```bash
   docker-compose down
   ```

### Docker Compose Configuration Details

The `docker-compose.yml` file is configured with:
- **Image**: `quay.io/jupyter/scipy-notebook:latest` - A comprehensive Jupyter environment with scientific Python packages
- **Port**: 8888 (Jupyter's default port)
- **Volumes**: 
  - Current directory mounted to `/home/jovyan/work` for persistent data
  - Custom Jupyter configuration for dark theme
- **Environment**: Pre-configured token and password for easy access

### Customizing the Docker Setup

To modify the Docker configuration:

1. **Modify authentication:**
   Update the environment variables in `docker-compose.yml`:
   ```yaml
   environment:
     JUPYTER_TOKEN: "your-custom-token"
     JUPYTER_PASSWORD: "your-custom-password"
   ```

2. **Add additional volumes or environment variables** as needed for your specific use case.

## Git Pre-commit Hook

This repository includes a pre-commit hook that automatically strips output from Jupyter notebooks before committing. This helps keep the repository clean and prevents large output cells from being committed.

### Setup for New Users

If you're new to this project, run the setup script to configure the pre-commit hook:

```bash
# Run the setup script
./scripts/setup-pre-commit.sh
```

This script will:
- Check that Docker and docker-compose are installed and running
- Ensure the pre-commit hook is executable
- Test the pre-commit hook with a sample notebook
- Set up the manual notebook cleaning script

### How it works:
- The pre-commit hook runs automatically when you commit
- It detects any staged `.ipynb` files
- Uses the Docker container to run `jupyter-nbconvert` and remove all output cells
- Re-stages the cleaned notebooks for commit
- Automatically starts/stops the container as needed

### Manual notebook cleaning:
If you want to manually strip output from all notebooks, you can run:
```bash
# Uses the Docker container automatically
./scripts/strip-notebooks.sh
```

The script will automatically start the Docker container if it's not running, process all notebooks, and then stop the container.

## Typical Workflow

1. Place your raw or exported data files in the `/data/` folder.
2. Open the appropriate notebook from `/notebooks/` and follow the steps to extract, clean, and manipulate your data.
3. Export processed datasets and results to `/outputs/` for sharing, reporting, or further analysis.
4. Commit your changes - the pre-commit hook will automatically clean notebook outputs.

## Troubleshooting

### Docker Issues
- **Port already in use**: Change the port mapping in `docker-compose.yml` from `"8888:8888"` to `"8889:8888"`
- **Permission issues**: Ensure Docker has proper permissions to access the project directory
- **Image not found**: Verify your internet connection and that quay.io is accessible

### Jupyter Issues
- **Token not working**: Check the `docker-compose.yml` file for the correct token/password
- **Dark theme not applied**: Verify that `jupyter_notebook_config.py` is properly mounted in the container

### Pre-commit Hook Issues
- **Docker not found**: Install Docker and Docker Compose to use the pre-commit hook
- **Container won't start**: Check that Docker is running and the docker-compose.yml file is valid
- **Hook not running**: Ensure the hook is executable: `chmod +x .git/hooks/pre-commit`
- **Permission issues**: Make sure Docker has access to the project directory

## Contributing

When contributing to this project:
1. Test your changes using the Docker Compose setup
2. Update the README if you modify the Docker configuration
3. Ensure your notebooks work in the containerized environment
4. The pre-commit hook will automatically clean notebook outputs before committing

