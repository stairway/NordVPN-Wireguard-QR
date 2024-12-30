# Docker Usage Guide

#### IMPORTANT

The `.sh` files in the `bin` directory all `cd` into this folder's parent directory. This means that from within those `.sh`, references to files will be as if the script existed one directory up.

## Step 1: Building the Docker Image (`bin/build.sh`)

The `bin/build.sh` script builds the Docker image locally. 

The built image is **required** before running `bin/run.sh` to generate Wireguard configurations.

(see the [IMPORTANT](#important) note above regarding file references)

### Usage

Basic build:
```bash
./bin/build.sh
```

Build with no cache:
```bash
DEBUG=true ./bin/build.sh
```

### Details

The script:
- Builds the image from the `docker/Dockerfile`
- Tags the image as `nordvpn:local`
- Uses the docker directory as build context
- Supports debug mode to force rebuild with `--no-cache`

### Prerequisites

1. Docker installed and running
2. Build files present in the docker directory
3. Execute permissions on the build script:
   ```bash
   chmod +x bin/build.sh
   ```

### Exit Codes

- `0`: Build successful
- Non-zero: Build failed

## Step 2: Configure Token and Run (`bin/run.sh`)

(see the [IMPORTANT](#important) note above regarding file references)

### Option 1. Environment Variable

Pass the token directly as an environment variable when running the container:

```bash
NORDVPN_TOKEN="your_token_here" ./bin/run.sh
```

### Option 2. Data File

Store your token in `.nordvpn_token`:

1. Create the data directory if it doesn't exist:
   ```bash
   mkdir -p data
   ```

2. Save your token to the file:
   ```bash
   echo "your_token_here" > data/.nordvpn_token
   ```

The token file will be automatically detected and used by the container at runtime.

## Usage

The `bin/run.sh` script handles all necessary container configuration:

- Mounts the `data/.wireguard` directory to `/home/nord/wireguard`
- Mounts the `data` directory to `data`
- Sets up privileged mode and network devices
- Handles token authentication

The `bin/run.sh` script accepts the following arguments:

```bash
./bin/run.sh [COUNTRY] [CITY]
```

### Arguments

- `COUNTRY` (optional): The country to connect to (e.g., United_States, Canada)
- `CITY` (optional): The city to connect to within the specified country

### Environment Variables

- `NORDVPN_TOKEN`: Your NordVPN authentication token
- `DEBUG`: Set to `true` to enable debug mode and keep the container running

### Prerequisites

1. Docker installed and running
2. Valid NordVPN token configured (see Token Configuration Methods above)

### Exit Codes

- `0`: Success
- `1`: Token not found in `.nordvpn_token` file
- Other non-zero values indicate container or NordVPN errors

### Examples

Basic usage:
```bash
./bin/run.sh
```

Connect to specific location:
```bash
./bin/run.sh United_States Chicago
```

Run with debug mode:
```bash
DEBUG=true ./bin/run.sh
```

With token via environment:
```bash
NORDVPN_TOKEN="your_token_here" ./bin/run.sh
```
